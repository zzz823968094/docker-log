<template>
  <el-container class="layout-container">
    <el-header class="layout-header">
      <div class="header-content">
        <h1 class="logo">Docker日志查询服务</h1>
        <div class="user-info">
          <el-dropdown @command="handleCommand">
            <span class="el-dropdown-link">
              <el-icon><User /></el-icon>
              {{ username }}
              <el-icon class="el-icon--right"><ArrowDown /></el-icon>
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="logout">退出登录</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </div>
    </el-header>
    
    <el-main class="layout-main">
      <router-view v-slot="{ Component }">
        <transition name="fade" mode="out-in">
          <component :is="Component" />
        </transition>
      </router-view>
    </el-main>
  </el-container>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessageBox } from 'element-plus'
import { User, ArrowDown } from '@element-plus/icons-vue'
import { useUserStore } from '@/stores/user'
import { logoutApi } from '@/api/auth'

const router = useRouter()
const userStore = useUserStore()

const username = computed(() => {
  return userStore.userInfo?.username || '用户'
})

const handleCommand = async (command: string) => {
  if (command === 'logout') {
    try {
      await ElMessageBox.confirm('确定要退出登录吗？', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      })
      
      await logoutApi()
      userStore.logout()
      router.push('/login')
    } catch (error) {
      console.error('退出登录失败:', error)
    }
  }
}
</script>

<style lang="scss" scoped>
.layout-container {
  height: 100vh;
}

.layout-header {
  background-color: #409eff;
  color: white;
  padding: 0 20px;
  display: flex;
  align-items: center;
  
  .header-content {
    width: 100%;
    display: flex;
    justify-content: space-between;
    align-items: center;
    
    .logo {
      font-size: 20px;
      font-weight: bold;
      margin: 0;
    }
    
    .user-info {
      .el-dropdown-link {
        cursor: pointer;
        display: flex;
        align-items: center;
        gap: 5px;
        color: white;
        
        &:hover {
          opacity: 0.8;
        }
      }
    }
  }
}

.layout-main {
  padding: 20px;
  background-color: #f5f7fa;
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>

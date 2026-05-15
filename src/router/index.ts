import { createRouter, createWebHistory, RouteRecordRaw } from 'vue-router'
import { useUserStore } from '@/stores/user'

const routes: Array<RouteRecordRaw> = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/Login.vue'),
    meta: { title: '登录', requiresAuth: false }
  },
  {
    path: '/',
    name: 'Layout',
    component: () => import('@/layout/Index.vue'),
    redirect: '/containers',
    meta: { requiresAuth: true },
    children: [
      {
        path: '/containers',
        name: 'Containers',
        component: () => import('@/views/Containers.vue'),
        meta: { title: '容器列表', requiresAuth: true }
      },
      {
        path: '/logs/:containerId',
        name: 'Logs',
        component: () => import('@/views/Logs.vue'),
        meta: { title: '容器日志', requiresAuth: true }
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach((to, _from, next) => {
  const userStore = useUserStore()
  
  if (to.meta.requiresAuth && !userStore.token) {
    next('/login')
  } else if (to.path === '/login' && userStore.token) {
    next('/')
  } else {
    next()
  }
})

export default router

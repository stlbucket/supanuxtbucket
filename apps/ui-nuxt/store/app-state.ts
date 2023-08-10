import { defineStore } from 'pinia'

interface AppState {
  navCollapsed: boolean
}

export const useAppStateStore = defineStore('appState', {
  persist: true,
  state: (): AppState => ({
    navCollapsed: true
  }),
  getters: {
    
  },
  actions: {
    setNavCollapsed (navCollapsed: boolean) {
      this.navCollapsed = navCollapsed
    }
  },
})
import { defineStore } from 'pinia'

interface AppState {
  navCollapsed: boolean,
  loggedIn: boolean
}

export const useAppStateStore = defineStore('appState', {
  persist: true,
  state: (): AppState => ({
    navCollapsed: true,
    loggedIn: false
  }),
  getters: {
    
  },
  actions: {
    setNavCollapsed (navCollapsed: boolean) {
      this.navCollapsed = navCollapsed
    },
    async setLoggedIn (loggedIn: boolean) {
      this.loggedIn = loggedIn
    }
  },
})
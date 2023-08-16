// Here is where we will get user session info from anywhere:  redis, our current database, useSupabaseUser(), etc...
import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
  try {
    const appStateCookie: any = getCookie(event, 'appState')
    const appState = appStateCookie ? JSON.parse(appStateCookie) : {
      loggedIn: false
    }
    if (appState.loggedIn) {
      // this is maybe not the ideal way to check for session expiration
      // auth for this repo is not 100% complete
      const client = await serverSupabaseClient(event)
      const session = (await client.auth.getSession()).data.session
      event.context.session = session || 'SESSION EXPIRED'  
    }
  } catch(e: any) {
    console.log('AUTH ERROR', e)
    throw e
  }  
})


// Currently, we use the appState.loggedIn flag in conjunction with supabase session
//   --  if loggedIn, and there is a supabase we expect a supabase session, setting to 'INVALID SESSION' if it does not exist
//   --  if !loggedIn, we are anon
//
// NOTE: https://github.com/nuxt-modules/supabase/issues/246
// The logic here may not change
// But the supabase cookie is present even after logging out
//

import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
  try {
    const appStateCookie: any = getCookie(event, 'appState')
    const appState = appStateCookie ? JSON.parse(appStateCookie) : {
      loggedIn: false
    }
    if (appState.loggedIn) {
      // Here is where we get user session info from anywhere:  redis, our current database, useSupabaseUser(), etc...
      const client = await serverSupabaseClient(event)
      const session = (await client.auth.getSession()).data.session

      // the session will be used later by graphql
      event.context.session = session || 'INVALID SESSION'  
    }
  } catch(e: any) {
    console.log('AUTH ERROR', e)
    throw e
  }  
})


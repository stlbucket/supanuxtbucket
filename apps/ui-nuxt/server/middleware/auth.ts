// Here is where we will get user session info from anywhere:  redis, our current database, useSupabaseUser(), etc...
import { serverSupabaseClient } from '#supabase/server'
export default defineEventHandler(async (event) => {
  try {
    const client = await serverSupabaseClient(event)
    const session = await client.auth.refreshSession()

    // console.log('SESH', session.data.session)
    // console.log('USER', session.data.user)

    event.context.user = session.data.user
  } catch(e: any) {
    if (e.toString().indexOf('invalid claim') > -1) {
      event.context.user = {}
    }
  }
})


// Here is where we will get user session info from anywhere:  redis, our current database, useSupabaseUser(), etc...
import { serverSupabaseUser } from '#supabase/server'
export default defineEventHandler(async (event) => {
  try {
    const user = await serverSupabaseUser(event)
    event.context.user = user
  } catch(e: any) {
    if (e.toString().indexOf('invalid claim') > -1) {
      event.context.user = {}
    }
  }
})


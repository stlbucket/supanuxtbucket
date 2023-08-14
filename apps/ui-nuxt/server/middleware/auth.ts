// Here is where we will get user session info from anywhere:  redis, our current database, useSupabaseUser(), etc...
import { serverSupabaseClient } from '#supabase/server'
export default defineEventHandler(async (event) => {
  try {
    // console.log('HEADERS', event.node.req.headers)
    const client = await serverSupabaseClient(event)
    const session = (await client.auth.getSession()).data.session
    // console.log('SESH', session)

    event.context.session = session
  } catch(e: any) {
    console.log('AUTH ERROR', e)
    throw e
  }  
})


// Here is where we will get user session info from anywhere:  redis, our current database, useSupabaseUser(), etc...
export default defineEventHandler((event) => {
  event.context.user = { user: 'claims' }
})

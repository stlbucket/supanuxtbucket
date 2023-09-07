import { makeWrapPlansPlugin } from "graphile-utils";
import { context, lambda } from "postgraphile/grafast";
import { serverSupabaseClient } from '#supabase/server'

const inviteUserPlugin = makeWrapPlansPlugin({
  Mutation: {
    inviteUser(plan, $user, args, info) {      
      const $result = plan();      
      return lambda(
        $result,
        async (result) => {
          return result
        },
      );
    },
  },
});

export default inviteUserPlugin

// import { makeWrapResolversPlugin } from 'graphile-utils'

// const inviteUserPlugin =  makeWrapResolversPlugin({
//   Mutation: {
//     async inviteUser(resolve: any, source?: any, args?: any, context?: any, resolveInfo?: any) {
//       try {
//         const resolution = await resolve()
//         console.log('invite-user', resolution)
//         return resolution
//       } catch (error) {
//         throw error
//       }
//     },
//   },
// })

// export default inviteUserPlugin



// const myPlugin =  makeWrapResolversPlugin({
//   Mutation: {
//     async inviteUser(resolve: any, source?: any, args?: any, context?: any, resolveInfo?: any) {
//       try {
//         const resolution = await resolve()
        
//         // do something else here like call a cloud function  *************************************

//         return resolution
//       } catch (error) {
//         throw error
//       }
//     },
//   },
// })

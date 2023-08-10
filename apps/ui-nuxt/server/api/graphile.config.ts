// Only needed for TypeScript types support
import "postgraphile";
import { PgSimplifyInflectionPreset } from "@graphile/simplify-inflection";
import { PostGraphileAmberPreset as amber} from "postgraphile/presets/amber";
// Use the 'pg' module to connect to the database
import { makePgService } from "postgraphile/adaptors/pg";

const preset: GraphileConfig.Preset = {
  extends: [
    amber,
    PgSimplifyInflectionPreset
    /* Add more presets here */
  ],

  plugins: [
  ],

  inflection: {
    /* options for the inflection system */
  },
  pgServices: [
    /* list of PG database configurations, e.g.: */
    makePgService({
      // Database connection string:
      connectionString: process.env.SUPABASE_URI || 'postgresql://postgres:postgres@localhost:54322/postgres',

      // List of database schemas to expose:
      schemas: (process.env.GRAPHQL_SCHEMAS || 'public').split(','),

      // Enable LISTEN/NOTIFY:
      pubsub: false,
    }),
  ],
  gather: {
    /* options for the gather phase */
  },
  schema: {
    /* options for the schema build phase */
  },
  grafast: {
    explain: true,  
    /* options for Grafast, including setting GraphQL context*/
    context: (requestContext, args) => {
      // this is where user session data set in /server/middleware/auth is used to pass into the query context
      const additionalSettings = {} // requestContext.nuxtv3?.event.context.

      // const pgSettings = {
      //   role: claims.aud || 'anon',
      //   'request.jwt.claim.sub': claims.sub,
      //   'request.jwt.claim.aud': claims.aud,
      //   'request.jwt.claim.exp': claims.exp,
      //   'request.jwt.claim.email': claims.email,
      //   'request.jwt.claim': JSON.stringify(claims)
      // }
  
      return {
        pgSettings: {
          ...args.contextValue?.pgSettings,
          ...additionalSettings
        }
      }
    }
  },
  grafserv: {
    graphqlPath: '/api/graphql'
  }
};

export default preset;
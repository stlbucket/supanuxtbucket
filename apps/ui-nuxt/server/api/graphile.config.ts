// Only needed for TypeScript types support
import "postgraphile";
// Use the 'pg' module to connect to the database
import { PgSimplifyInflectionPreset } from "@graphile/simplify-inflection";
import { PostGraphileAmberPreset as amber} from "postgraphile/presets/amber";
// Use the 'pg' module to connect to the database
import { makePgService } from "postgraphile/adaptors/pg";
import { makeV4Preset } from "postgraphile/presets/v4";

const preset: GraphileConfig.Preset = {
  extends: [
    amber,
    makeV4Preset({
      simpleCollections: "both",
      disableDefaultMutations: true,
      dynamicJson: true
    }),
    PgSimplifyInflectionPreset,
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
      const session = requestContext.h3v1?.event.context.session
      // if (session === 'SESSION EXPIRED') {
      //   throw new Error(session)
      // }
      const claims = session?.user
      console.log('claims', claims)
      const additionalSettings = {
        role: claims?.aud || 'anon',
        'request.jwt.claim.sub': claims?.id,
        'request.jwt.claim.aud': claims?.aud,
        'request.jwt.claim.exp': claims?.exp,
        'request.jwt.claim.email': claims?.email,
        'request.jwt.claim': JSON.stringify(claims)
      }
      console.log('additionalSettings', additionalSettings)
  
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
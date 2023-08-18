# Postgraphile v5
https://postgraphile.org/
Postgraphile provides an extensible high-performance automatic GraphQL API for PostgresSQL.
## Why postgraphile?
Reasons for using it in place of the Supabase client include:
- Ability to expose custom schemas more easily
- A rich query-builder experience (ruru)
- Author has multiple postgraphile-4 applications that may one day port to Supabase
- Postgraphile v5 is optimized for edge-function deployment and is a natural fit for use with Nuxt3
## How postgraphile?
``` ts
// server/api/graphql.ts
import { postgraphile } from "postgraphile"
import { grafserv } from "grafserv/h3/v1";
import preset from "./graphile.config.js";  

const pgl = postgraphile(preset);
const serv = pgl.createServ(grafserv);

export default defineEventHandler(async (event) => {
  return serv.handleEvent(event)  
})
```
As of this writing, this is how postgraphile is integrated with nuxt in this starter.

Postgraphile v5 is currently in beta.  

The key point here is that the ***grafserv h3*** plugin is exposed by postgraphile, and actually handles things at the nitro level using h3 helpers.  

Special thanks to [benjie](https://github.com/benjie/) for offering to implement this vital component.

Refer to https://postgraphile.org/postgraphile/next/config to understand the accompanying ***graphile.config.ts*** file
# SupaNuxtPhile
Core Techs:
- [Supabase](https://www.supabase.com)
- [Nuxt](https://nuxtjs.com)
- [Postgraphile](https://postgraphile.org/)
- [Nuxt Graphql Client](https://nuxt-graphql-client.web.app/)

This starter repo is intended to provide a quick-start scenario for building MVPs that that can be quickly deployed to Supabase and the related ecosystem.

The core query mechanism is Postgraphile, and part of developing this repository involved working with Benjie, the postgraphile maintainer, to create an h3 plugin.  This component is still evolving, and will hopefully become a Nuxt plugin.  For now, integration is as simple as creating a [server endpoint](/apps/ui-nuxt/server/api/graphql.ts) and associated [graphile.config](/apps/ui-nuxt/server/api/graphile.config.ts) file.
```
import { postgraphile } from "postgraphile"
import { grafserv } from "grafserv/h3/v1";
import preset from "./graphile.config.js";  

const pgl = postgraphile(preset);
const serv = pgl.createServ(grafserv);

export default defineEventHandler(async (event) => {
  return serv.handleEvent(event)  
})
```
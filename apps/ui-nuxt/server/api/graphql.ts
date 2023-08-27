import { postgraphile } from "postgraphile"
import { grafserv } from "grafserv/h3/v1";
import preset from "./graphile.config.js";  

console.log('graphql')
const pgl = postgraphile(preset);
const serv = pgl.createServ(grafserv);

export default defineEventHandler(async (event) => {
  return serv.handleEvent(event)  
})

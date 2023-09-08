import { postgraphile } from "postgraphile"
import { grafserv } from "grafserv/h3/v1";
import preset from "./graphile.config.js";
// utils/grafserv.mjs

const pgl = postgraphile(preset);
const serv = pgl.createServ(grafserv);

export default defineEventHandler(async (event) => {
  return serv.handleEvent(event)  
})

export { serv }
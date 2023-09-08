import { serv } from "@/server/api/graphql";

export default eventHandler((event) => {
  return 'NOT QUITE YET, BRO'
  // return serv.handleGraphiqlEvent(event);
});

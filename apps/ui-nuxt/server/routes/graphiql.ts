import { serv } from "@/server/api/graphql";

export default eventHandler((event) => {
  return serv.handleGraphiqlEvent(event);
});

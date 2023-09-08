import { makeExtendSchemaPlugin, gql } from "postgraphile/utils";
import { context, lambda, listen } from "postgraphile/grafast";
import { jsonParse } from "postgraphile/@dataplan/json";
import { EXPORTABLE } from "graphile-export";

const TopicMessageSubscriptionPlugin = makeExtendSchemaPlugin(() => {
  return {
    typeDefs: /* GraphQL */ gql`
      extend type Subscription {
        topicMessage(topicId: UUID!): TopicMessageSubscriptionPayload
      }

      type TopicMessageSubscriptionPayload {
        event: String
        sub: Int
        id: Int
      }
    `,
    plans: {
      Subscription: {
        topicMessage: {
          subscribePlan: EXPORTABLE(
            (lambda, context, listen, jsonParse) => (_$root, args) => {
              const $pgSubscriber = context().get("pgSubscriber");
              const $topicId = args.get("topicId");
              const $topic = lambda($topicId, (id) => `topic:${id}:message`);
              return listen($pgSubscriber, $topic, jsonParse);
            },
            [lambda, context, listen, jsonParse]
          ),
          plan($event) {
            return $event;
          },
        },
      },
      TopicMessageSubscriptionPayload: {
        event($event) {
          return $event.get("event");
        },
        sub($event) {
          return $event.get("sub");
        },
        id($event) {
          return $event.get("id");
        },
      },
    },
  };
});

export default TopicMessageSubscriptionPlugin;

create schema if not exists msg_fn_api;
create schema if not exists msg_fn;

create type msg_fn.subscription_info as (
  topic_id uuid
  ,subscriber_msg_user_id uuid
);

create type msg_fn.message_info as (
  id uuid
  ,topic_id uuid
  ,content citext
  ,tags citext[]
);

create type msg_fn.topic_info as (
  id uuid
  ,name citext
  ,identifier citext
  ,status msg.topic_status
);
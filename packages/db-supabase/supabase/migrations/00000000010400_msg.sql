drop schema if exists msg cascade;
create schema msg;

create type msg.topic_status as enum (
  'open'
  ,'closed'
  ,'locked'
);

create type msg.message_status as enum (
  'draft',
  'sent',
  'deleted'
);

create type msg.subscription_status as enum (
  'active',
  'inactive',
  'blocked'
);

create table msg.msg_tenant (
  app_tenant_id uuid not null references app.app_tenant(id) primary key
  ,name citext not null
);

create table msg.msg_user (
  id uuid not null references app.app_user_tenancy(id) primary key
  ,app_tenant_id uuid not null references msg.msg_tenant(app_tenant_id)
  ,display_name citext not null
);

create table msg.topic (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  app_tenant_id uuid not null references msg.msg_tenant(app_tenant_id),
  created_at timestamptz not null default current_timestamp,
  name citext not null,
  identifier text,
  tags citext[] not null default '{}'::citext[],
  status msg.topic_status not null default 'open'
);
ALTER TABLE ONLY msg.topic
  ADD CONSTRAINT pk_topic PRIMARY KEY (id);
create index idx_topic_msg_tenant on msg.topic(app_tenant_id);
create unique index idx_topic_app_tenant_identifier on msg.topic (app_tenant_id, identifier);

create table msg.message (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  app_tenant_id uuid not null references msg.msg_tenant(app_tenant_id),
  created_at timestamptz not null default current_timestamp,
  status msg.message_status not null default 'sent',
  topic_id uuid not null references msg.topic(id),
  content citext not null,
  posted_by_msg_user_id uuid not null references msg.msg_user(id),
  tags text[] not null default '{}'::text[]
);
ALTER TABLE ONLY msg.message
    ADD CONSTRAINT pk_message PRIMARY KEY (id);
create index idx_message_app_tenant_id on msg.message(app_tenant_id);
create index idx_message_posted_by_msg_user_id on msg.message(posted_by_msg_user_id);

create table msg.subscription (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  app_tenant_id uuid not null references msg.msg_tenant(app_tenant_id),
  created_at timestamptz not null default current_timestamp,
  status msg.subscription_status not null default 'active',
  topic_id uuid not null references msg.topic(id),
  subscriber_msg_user_id uuid not null references msg.msg_user(id),
  last_read timestamptz not null default current_timestamp
);
ALTER TABLE ONLY msg.subscription
    ADD CONSTRAINT pk_subscription PRIMARY KEY (id);
ALTER TABLE ONLY msg.subscription
    ADD CONSTRAINT uq_subscription unique (topic_id, subscriber_msg_user_id);
create index idx_subscription_app_tenant_id on msg.subscription(app_tenant_id);
create index idx_subscription_subscriber_msg_user_id on msg.subscription(subscriber_msg_user_id);
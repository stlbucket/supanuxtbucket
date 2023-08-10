-- incidents
create schema inc;

create type inc.incident_status as enum (
  'reported'
  ,'open'
  ,'closed'
  ,'pending'
  ,'aborted'
);

create table inc.inc_tenant (
  app_tenant_id uuid not null references app.app_tenant(id) primary key
  ,name citext not null
);

create table inc.inc_user (
  app_user_tenancy_id uuid not null references app.app_user_tenancy(id) primary key
  ,app_tenant_id uuid not null references inc.inc_tenant(app_tenant_id)
  ,display_name citext not null
);

create table inc.incident (
  id uuid NOT NULL DEFAULT gen_random_uuid() primary key,
  app_tenant_id uuid not null references inc.inc_tenant(app_tenant_id),
  todo_id uuid not null references todo.todo(id),
  topic_id uuid not null references msg.topic(id),
  created_by_app_user_tenancy_id uuid not null references inc.inc_user(app_user_tenancy_id),
  created_at timestamptz not null default current_timestamp,
  name citext not null,
  description citext,
  identifier text,
  status inc.incident_status not null default 'reported',
  tags citext[] not null default '{}'::citext[],
  is_template boolean not null default false
);
create unique index idx_uq_incident_identifier on inc.incident(app_tenant_id, identifier) where is_template = false;
create unique index idx_uq_incident_identifier_template on inc.incident(app_tenant_id, identifier) where is_template = true;

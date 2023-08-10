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
  tenant_id uuid not null references app.tenant(id) primary key
  ,name citext not null
);

create table inc.inc_resident (
  resident_id uuid not null references app.resident(id) primary key
  ,tenant_id uuid not null references inc.inc_tenant(tenant_id)
  ,display_name citext not null
);

create table inc.incident (
  id uuid NOT NULL DEFAULT gen_random_uuid() primary key,
  tenant_id uuid not null references inc.inc_tenant(tenant_id),
  todo_id uuid not null references todo.todo(id),
  topic_id uuid not null references msg.topic(id),
  created_by_resident_id uuid not null references inc.inc_resident(resident_id),
  created_at timestamptz not null default current_timestamp,
  name citext not null,
  description citext,
  identifier text,
  status inc.incident_status not null default 'reported',
  tags citext[] not null default '{}'::citext[],
  is_template boolean not null default false
);
create unique index idx_uq_incident_identifier on inc.incident(tenant_id, identifier) where is_template = false;
create unique index idx_uq_incident_identifier_template on inc.incident(tenant_id, identifier) where is_template = true;

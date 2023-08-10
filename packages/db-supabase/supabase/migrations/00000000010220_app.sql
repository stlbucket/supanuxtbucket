-----------------------------------------------
-- script  app schema
-----------------------------------------------
create schema if not exists app;
create schema if not exists app_fn;
----------------------------------------------------------------------------------------------
create type app.app_tenant_type as enum (
    'anchor'
    ,'customer'
    ,'demo'
    ,'test'
    ,'trial'
  );
----------------------------------------------------------------------------------------------
create type app.app_tenant_status as enum (
    'active'
    ,'inactive'
    ,'paused'
  );
----------------------------------------------------------------------------------------------
create type app.app_user_status as enum (
    'active'
    ,'inactive'
    ,'blocked'
  );
----------------------------------------------------------------------------------------------
create type app.app_user_tenancy_status as enum (
    'invited'
    ,'declined'
    ,'active'
    ,'inactive'
    ,'blocked_individual'
    ,'blocked_tenant'
    ,'supporting'
  );
--------------------------------------------------------------------------------------------
create type app.license_type_assignment_scope as enum (
  'user'
  ,'admin'
  ,'superadmin'
  ,'support'
  ,'none'
  ,'all'
);
--------------------------------------------------------------------------------------------
create type app.license_status as enum (
  'active'
  ,'inactive'
  ,'expired'
);
--------------------------------------------------------------------------------------------
create type app.expiration_interval_type as enum (
    'none'
    ,'day'
    ,'week'
    ,'month'
    ,'quarter'
    ,'year'
    ,'explicit'
);
--------------------------------------------------------------------------------------------
CREATE TABLE app.application (
  key citext PRIMARY KEY
  ,name citext not null
);
--------------------------------------------------------------------------------------------
CREATE TABLE app.app_settings (
  key citext PRIMARY KEY
  ,application_key citext not null references app.application(key)
  ,display_name citext not null
  ,value citext not null
);
--------------------------------------------------------------------------------------------
CREATE TABLE app.permission (
  key citext PRIMARY KEY
);
--------------------------------------------------------------------------------------------
CREATE TABLE app.license_type (
  key citext PRIMARY KEY
  ,created_at timestamptz not null default current_timestamp
  ,updated_at timestamptz not null default current_timestamp
  ,application_key citext not null references app.application(key)
  ,display_name citext not null
  ,assignment_scope app.license_type_assignment_scope not null
);
--------------------------------------------------------------------------------------------
CREATE TABLE app.license_pack (
  key citext PRIMARY KEY
  ,created_at timestamptz not null default current_timestamp
  ,updated_at timestamptz not null default current_timestamp
  ,display_name citext not null
);
--------------------------------------------------------------------------------------------
CREATE TABLE app.license_pack_license_type (
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY
  ,license_pack_key citext not null references app.license_pack(key)
  ,license_type_key citext not null references app.license_type(key)
  ,number_of_licenses integer not null default -1 -- (-1=unlimited, 0=tenant-license)
  ,expiration_interval_type app.expiration_interval_type not null default 'none'
  ,expiration_interval_multiplier integer not null default 1
  ,unique(license_pack_key, license_type_key)
);

--------------------------------------------------------------------------------------------
CREATE TABLE app.license_type_permission (
  license_type_key citext not null references app.license_type(key)
  ,permission_key citext not null references app.permission(key)
  ,unique(license_type_key, permission_key)
);
--------------------------------------------------------------------------------------------
create table if not exists app.app_tenant (
    id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY
    ,created_at timestamptz not null default current_timestamp
    ,updated_at timestamptz not null default current_timestamp
    ,identifier citext unique
    ,name citext not null unique
    ,type app.app_tenant_type not null default 'customer'
    ,status app.app_tenant_status not null default 'active'
  );
--------------------------------------------------------------------------------------------
CREATE TABLE app.app_tenant_subscription (
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY
  ,app_tenant_id uuid not null references app.app_tenant(id)
  ,license_pack_key citext not null references app.license_pack(key)
  ,created_at timestamptz not null default current_timestamp
  ,updated_at timestamptz not null default current_timestamp
);
----------------------------------------------------------------------------------------------
create table if not exists app.app_user (
    id uuid not null references auth.users on delete cascade primary key  -- this is for supabase
    ,created_at timestamptz not null default current_timestamp
    ,updated_at timestamptz not null default current_timestamp
    ,email citext not null unique
    ,identifier citext unique
    ,first_name citext null
    ,last_name citext null
    ,phone citext null
    ,display_name citext null unique
    ,avatar_key citext null
    ,status app.app_user_status not null default 'active'
    ,is_public boolean not null default false
    ,full_name citext GENERATED ALWAYS AS (first_name||' '||last_name) STORED
  );
----------------------------------------------------------------------------------------------
create table if not exists app.app_user_tenancy (
    id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY
    ,app_user_id uuid null references app.app_user(id)
    ,invited_by_app_user_id uuid null references app.app_user(id)
    ,invited_by_display_name citext
    ,app_tenant_id uuid not null references app.app_tenant(id)
    ,app_tenant_name citext not null
    ,email text not null
    ,display_name citext null
    ,created_at timestamptz not null default current_timestamp
    ,updated_at timestamptz not null default current_timestamp
    ,status app.app_user_tenancy_status not null default 'invited'
  );
----------------------------------------------------------------------------------------------
CREATE TABLE app.license (
    id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY
    ,app_tenant_id uuid not null references app.app_tenant(id)
    ,app_user_tenancy_id uuid not null references app.app_user_tenancy(id)
    ,app_tenant_subscription_id uuid not null references app.app_tenant_subscription(id)
    ,license_type_key citext not null references app.license_type(key)
    ,created_at timestamptz not null default current_timestamp
    ,updated_at timestamptz not null default current_timestamp
    ,expires_at timestamptz null
    ,status app.license_status NOT NULL default 'active'
  );
----------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION app.application_license_count(_application app.application)
  RETURNS integer
  LANGUAGE plpgsql
  STABLE
  SECURITY INVOKER
  AS $function$
  DECLARE
    _license_count integer;
  BEGIN
    _license_count := (
      select count(*)
      from app.license
      where license_type_key in (
        select key from app.license_type where application_key = _application.key
      )
    );
      
    return _license_count;
  end;
  $function$
  ;
----------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION app.license_pack_license_type_issued_count(_license_pack_license_type app.license_pack_license_type)
  RETURNS integer
  LANGUAGE plpgsql
  STABLE
  SECURITY INVOKER
  AS $function$
  DECLARE
    _license_count integer;
  BEGIN
    _license_count := (
      select count(*)
      from app.license_pack_license_type lplt
      join app.license_pack lp on lp.key = lplt.license_pack_key
      join app.app_tenant_subscription ats on ats.license_pack_key = lp.key
      join app.license l on l.app_tenant_subscription_id = ats.id
      where lplt.license_pack_key = _license_pack_license_type.license_pack_key
      and lplt.license_type_key = _license_pack_license_type.license_type_key
      and l.license_type_key = _license_pack_license_type.license_type_key
    );
      
    return _license_count;
  end;
  $function$
  ;

----------------------------------------------------------------------------------------------
--             CONSTRAINTS AND INDEXES

------------------------------------------------- license_type
create index idx_license_type_application on app.license_type(application_key);

------------------------------------------------- license_type
create index idx_lplt_license_pack on app.license_pack_license_type(license_pack_key);
create index idx_lplt_license_type on app.license_pack_license_type(license_type_key);

------------------------------------------------- license_type_permission
create index idx_ltp_license_type on app.license_type_permission(license_type_key);
create index idx_lplt_permission on app.license_type_permission(permission_key);

------------------------------------------------- license
create index idx_app_license_license_type_key on app.license(license_type_key);
alter table only app.license add constraint uq_tenancy_license unique(app_user_tenancy_id, license_type_key);

------------------------------------------------- license
create index idx_license_app_user_tenancy on app.license(app_user_tenancy_id);
create index idx_license_app_tenant on app.license(app_tenant_id);
create index idx_license_app_tenant_subscription on app.license(app_tenant_subscription_id);
------------------------------------------------- app_tenant_subscription
create index idx_ats_license_pack on app.app_tenant_subscription(license_pack_key);
create index idx_app_app_tenant_subscription_app_tenant_id on app.app_tenant_subscription(app_tenant_id);

------------------------------------------------- app_user_tenancy
create index idx_app_user_tenancy_app_user on app.app_user_tenancy(app_user_id);
create index idx_app_user_tenancy_app_tenant on app.app_user_tenancy(app_tenant_id);
create unique index idx_uq_app_user_tenancy on app.app_user_tenancy(app_user_id) where status = 'active';
create index idx_app_app_user_tenancy_invited_by_app_user_id on app.app_user_tenancy(invited_by_app_user_id);
alter table only app.app_user_tenancy add constraint uq_app_user_tenancy unique(app_tenant_id, app_user_id);

----------------------------------------------------------------------------------------------

--------------  special anchor tenant restrictions
-- these two indexes ensure that only one license pack (anchor) can ever have super admin or support licenses
-- anchor license pack is created when the app is seeded by calling app_fn.install_anchor_application()
create unique index idx_uq_lplt_admin_super on app.license_pack_license_type(license_pack_key) where license_type_key = 'app-admin-super';
create unique index idx_uq_lplt_admin_support on app.license_pack_license_type(license_pack_key) where license_type_key = 'app-admin-support';
-- there can only ever be one subscriber to the anchor license pack, the anchor tenant
create unique index idx_uq_anchor_subscription on app.app_tenant_subscription(id) where license_pack_key = 'anchor';
-- these two are just for extra strictness to doubly enforce there can only be one of each of these.  it will be in the anchor license pack.

--------------- indexes to enforce uniqueness of scoped license types in an application
create unique index idx_uq_app_license_type_scope_superadmin on app.license_type(key, application_key) where assignment_scope = 'superadmin';
create unique index idx_uq_app_license_type_scope_admin on app.license_type(key, application_key) where assignment_scope = 'admin';
create unique index idx_uq_app_license_type_scope_user on app.license_type(key, application_key) where assignment_scope = 'user';
create unique index idx_uq_app_license_type_scope_support on app.license_type(key, application_key) where assignment_scope = 'support';

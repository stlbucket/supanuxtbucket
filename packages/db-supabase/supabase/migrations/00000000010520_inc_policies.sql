--- inc_fn_api policies
grant usage on schema inc_fn_api to anon, authenticated, service_role;
grant all on all tables in schema inc_fn_api to anon, authenticated, service_role;
grant all on all routines in schema inc_fn_api to anon, authenticated, service_role;
grant all on all sequences in schema inc_fn_api to anon, authenticated, service_role;
alter default privileges for role postgres in schema inc_fn_api grant all on tables to anon, authenticated, service_role;
alter default privileges for role postgres in schema inc_fn_api grant all on routines to anon, authenticated, service_role;
alter default privileges for role postgres in schema inc_fn_api grant all on sequences to anon, authenticated, service_role;

--- inc_fn policies
grant usage on schema inc_fn to anon, authenticated, service_role;
grant all on all tables in schema inc_fn to anon, authenticated, service_role;
grant all on all routines in schema inc_fn to anon, authenticated, service_role;
grant all on all sequences in schema inc_fn to anon, authenticated, service_role;
alter default privileges for role postgres in schema inc_fn grant all on tables to anon, authenticated, service_role;
alter default privileges for role postgres in schema inc_fn grant all on routines to anon, authenticated, service_role;
alter default privileges for role postgres in schema inc_fn grant all on sequences to anon, authenticated, service_role;


--- inc policies
grant usage on schema inc to anon, authenticated, service_role;
grant all on all tables in schema inc to anon, authenticated, service_role;
grant all on all routines in schema inc to anon, authenticated, service_role;
grant all on all sequences in schema inc to anon, authenticated, service_role;
alter default privileges for role postgres in schema inc grant all on tables to anon, authenticated, service_role;
alter default privileges for role postgres in schema inc grant all on routines to anon, authenticated, service_role;
alter default privileges for role postgres in schema inc grant all on sequences to anon, authenticated, service_role;


------------------------------------------------------------------------ inc
alter table inc.incident enable row level security;
    CREATE POLICY manage_all_for_tenant ON inc.incident
      FOR ALL
      USING (auth_ext.app_tenant_id()::uuid = app_tenant_id)
      WITH CHECK (auth_ext.app_tenant_id()::uuid = app_tenant_id)
      ;

    -- CREATE POLICY manage_all_super_admin ON inc.inc
    --   FOR ALL
    --   USING (auth_ext.has_permission('p:app-admin-super'))
    --   WITH CHECK (auth_ext.has_permission('p:app-admin-super'))
    --   ;

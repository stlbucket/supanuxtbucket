--- app_fn_api policies
grant usage on schema app_fn_api to anon, authenticated, service_role;
grant all on all tables in schema app_fn_api to anon, authenticated, service_role;
grant all on all routines in schema app_fn_api to anon, authenticated, service_role;
grant all on all sequences in schema app_fn_api to anon, authenticated, service_role;
alter default privileges for role postgres in schema app_fn_api grant all on tables to anon, authenticated, service_role;
alter default privileges for role postgres in schema app_fn_api grant all on routines to anon, authenticated, service_role;
alter default privileges for role postgres in schema app_fn_api grant all on sequences to anon, authenticated, service_role;

--- app_fn policies
grant usage on schema app_fn to anon, authenticated, service_role;
grant all on all tables in schema app_fn to anon, authenticated, service_role;
grant all on all routines in schema app_fn to anon, authenticated, service_role;
grant all on all sequences in schema app_fn to anon, authenticated, service_role;
alter default privileges for role postgres in schema app_fn grant all on tables to anon, authenticated, service_role;
alter default privileges for role postgres in schema app_fn grant all on routines to anon, authenticated, service_role;
alter default privileges for role postgres in schema app_fn grant all on sequences to anon, authenticated, service_role;

--- app policies
grant usage on schema app to anon, authenticated, service_role;
grant all on all tables in schema app to anon, authenticated, service_role;
grant all on all routines in schema app to anon, authenticated, service_role;
grant all on all sequences in schema app to anon, authenticated, service_role;
alter default privileges for role postgres in schema app grant all on tables to anon, authenticated, service_role;
alter default privileges for role postgres in schema app grant all on routines to anon, authenticated, service_role;
alter default privileges for role postgres in schema app grant all on sequences to anon, authenticated, service_role;

------------------------------------------------------------------------ app_user
alter table app.app_user enable row level security;
    CREATE POLICY view_self ON app.app_user
      FOR SELECT
      USING (auth.uid() = id);
    CREATE POLICY update_self ON app.app_user
      FOR UPDATE
      USING (auth.uid() = id)
      WITH CHECK (auth.uid() = id)
      ;
    CREATE POLICY manage_all_super_admin ON app.app_user
      FOR ALL
      USING (auth_ext.has_permission('p:app-admin-super'));
------------------------------------------------------------------------ app_user_tenancy
alter table app.app_user_tenancy enable row level security;
    CREATE POLICY view_own_tenancy_email ON app.app_user_tenancy
      FOR SELECT
      USING (auth.jwt()->>'email' = email);
    CREATE POLICY view_own_tenancy_user_id ON app.app_user_tenancy
      FOR SELECT
      USING (auth.uid() = app_user_id);
    CREATE POLICY update_own_tenancy ON app.app_user_tenancy
      FOR UPDATE
      USING (auth.uid() = app_user_id)
      WITH CHECK (auth.uid() = app_user_id);
    CREATE POLICY manage_app_user_tenancy ON app.app_user_tenancy
      FOR ALL
      USING (auth_ext.has_permission('p:app-admin-super'));
    CREATE POLICY manage_own_tenant_tenancies ON app.app_user_tenancy
      FOR ALL
      USING (auth_ext.has_permission('p:app-admin', app_tenant_id));
------------------------------------------------------------------------ app_tenant
alter table app.app_tenant enable row level security;
    CREATE POLICY view_own_tenant_user ON app.app_tenant
      FOR SELECT
      USING (auth_ext.has_permission('p:app-user', id));
    CREATE POLICY manage_own_tenant_admin ON app.app_tenant
      FOR ALL
      USING (auth_ext.has_permission('p:app-admin', id));
    CREATE POLICY manage_app_tenant ON app.app_tenant
      FOR ALL
      USING (auth_ext.has_permission('p:app-admin-super'));
------------------------------------------------------------------------ app_tenant_subscription
alter table app.app_tenant_subscription enable row level security;
    CREATE POLICY manage_app_tenant_subscription ON app.app_tenant_subscription
      FOR ALL
      USING (auth_ext.has_permission('p:app-admin-super'));
    CREATE POLICY view_own_tenant_subscriptions ON app.app_tenant_subscription
      FOR ALL
      USING (auth_ext.has_permission('p:app-admin', app_tenant_id));
------------------------------------------------------------------------ license
alter table app.license enable row level security;
    CREATE POLICY manage_license ON app.license
      FOR ALL
      USING (auth_ext.has_permission('p:app-admin-super'));
    CREATE POLICY view_own_tenant_licenses ON app.license
      FOR ALL
      USING (auth_ext.has_permission('p:app-admin', app_tenant_id));
------------------------------------------------------------------------ application
alter table app.application enable row level security;
    CREATE POLICY view_all_users ON app.application
      FOR SELECT
      USING (1=1);
------------------------------------------------------------------------ license_pack
alter table app.license_pack enable row level security;
    CREATE POLICY view_all_users ON app.license_pack
      FOR SELECT
      USING (1=1);
------------------------------------------------------------------------ license_pack_license_type
alter table app.license_pack_license_type enable row level security;
    CREATE POLICY view_all_users ON app.license_pack_license_type
      FOR SELECT
      USING (1=1);
------------------------------------------------------------------------ license_type
alter table app.license_type enable row level security;
    CREATE POLICY view_all_users ON app.license_type
      FOR SELECT
      USING (1=1);
------------------------------------------------------------------------ license_type_permission
alter table app.license_type_permission enable row level security;
    CREATE POLICY view_all_users ON app.license_type_permission
      FOR SELECT
      USING (1=1);
------------------------------------------------------------------------ permission
alter table app.permission enable row level security;
    CREATE POLICY view_all_users ON app.permission
      FOR SELECT
      USING (1=1);

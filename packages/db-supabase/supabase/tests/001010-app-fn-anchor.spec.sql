BEGIN;
\set _superadmin_email 'app-admin-super@example.com'
\set _user_email 'anchor-tenant-user@example.com'
------------------------------------
-- THESE TEST EXPLICITLY ENSURE THE BASIC APP USER TENANCY FOR THE INITIAL SUPER ADMIN USER
-- LATER TESTS WILL USE ONLY THE HELPER FUNCTIONS TO SETUP FOR TESTS AS NECESSARY
------------------------------------

-- SELECT plan(12);
SELECT * FROM no_plan();
------------------------------------
select is(
  (
    select count(*)
    from app.app_user_tenancy aut
    join app.app_tenant t on t.id = aut.app_tenant_id
    where t.type = 'demo'::app.app_tenant_type
  )::integer
  ,6::integer
  ,'demo user count'
);

-- Examples: https://pgtap.org/documentation.html
------------------------------------
select is(
  (select count(*) from app.app_tenant where type = 'anchor'::app.app_tenant_type)::integer
  ,1::integer
  ,'should be an anchor app tenant'
);
------------------------------------
-- select is(
--   (select count(*) from app.app_user_tenancy where app_tenant_id = (select id from app.app_tenant where type = 'anchor'))::integer
--   ,3::integer
--   ,'should be an app_user_tenancy'
-- );
------------------------------------
-- select is(
--   (select count(*) from app.app_tenant_subscription where  app_tenant_id = (select id from app.app_tenant where type = 'anchor'))::integer
--   ,3::integer
--   ,'should be 3 app_tenant_subscription'
-- );
-- ------------------------------------
--     select is(
--       (select to_jsonb(array_agg(jsonb_build_object(
--         'license_type_key' ,l.license_type_key
--         ,'email' ,aut.email
--         ,'tenant' ,t.name
--       )))
--         from app.license l
--         join app.app_user_tenancy aut on l.app_user_tenancy_id = aut.id
--         join app.app_tenant t on t.id = aut.app_tenant_id
--       )::jsonb
--       ,'{}'::jsonb
--       ,'licenses'
--     );
-- select is(
--   (select count(*) from app.license where app_user_tenancy_id in (
--     select id from app.app_user_tenancy 
--     where app_tenant_id = (select id from app.app_tenant where type = 'anchor'))
--   )::integer
--   ,6::integer
--   ,'should be 6 licenses'
-- );
------------------------------------
select is(
  (select count(*) from app.app_user where email = :'_superadmin_email'::citext)::integer
  ,0::integer
  ,'should be no app.app_user ---  SUPABASE DB RESET WILL FIX THIS MOST LIKELY'
);
------------------------------------
select is(
  (select count(*) from auth.users where email = :'_superadmin_email'::citext)::integer
  ,0::integer
  ,'should be no auth.users'
);
------------------------------------
select is(
  (select app_user_id is null from app.app_user_tenancy where email = :'_superadmin_email'::citext)::boolean
  ,true
  ,'app_user_id should be null'
);
------------------------------------
select isa_ok(
  test_helpers.create_supabase_user(
    _email => :'_superadmin_email'::citext
    ,_user_metadata => '{"test": "meta"}'::jsonb
    ,_password => 'badpassword'
  )
  ,'uuid'
  ,'create_supabase_user should return uuid'
);
------------------------------------
select is(
  (select count(*) from app.app_user where email = :'_superadmin_email'::citext)::integer
  ,1::integer
  ,'should be 1 app.app_user'
);
------------------------------------
select is(
  (select count(*) from auth.users where email = :'_superadmin_email'::citext)::integer
  ,1::integer
  ,'should be 1 auth.users'
);
------------------------------------ login as anchor user
select test_helpers.login_as_user(
  _email => :'_superadmin_email'::citext
);
------------------------------------
select is(
  (select status from app.app_user_tenancy where email = :'_superadmin_email'::citext)::app.app_user_tenancy_status
  ,'active'::app.app_user_tenancy_status
  ,'tenancy should still be in status of invited'
);
------------------------------------ logout so we can evaluate data as postgres user
select test_helpers.logout();
------------------------------------
select is(
  (select status from app.app_user_tenancy where email = :'_superadmin_email'::citext)::app.app_user_tenancy_status
  ,'active'::app.app_user_tenancy_status
  ,'tenancy should be in status of active'
);
------------------------------------ login as anchor user
select test_helpers.login_as_user(
  _email => :'_superadmin_email'::citext
);
------------------------------------ test permissions
select is(
  (select auth_ext.has_permission('p:app'))
  ,false
  ,'super admin user should not have app permission'
);
------------------------------------ test permissions
select is(
  (select auth_ext.has_permission('p:app-admin'))
  ,false
  ,'super admin user should not have p:app-admin permission'
);
------------------------------------ test permissions
select is(
  (select auth_ext.has_permission('p:app-admin-super'))
  ,true
  ,'super admin user should have p:app-admin-super permission'
);
------------------------------------ logout so we can evaluate data as postgres user
select test_helpers.logout();
select isa_ok(
  test_helpers.create_supabase_user(
    _email => :'_user_email'::citext
    ,_user_metadata => '{"test": "meta"}'::jsonb
    ,_password => 'badpassword'
  )
  ,'uuid'
  ,'create_supabase_user should return uuid'
);
select test_helpers.login_as_user(
  _email => :'_user_email'::citext
);
------------------------------------ test permissions
select is(
  (select auth_ext.has_permission('p:app-admin-super'))
  ,false
  ,'user should not have p:app-admin-super permission'
);
select is(
  (select auth_ext.has_permission('p:app-admin'))
  ,false
  ,'user should not have p:app-admin permission'
);
select is(
  (select auth_ext.has_permission('p:app-user'))
  ,true
  ,'user should have p:app-user permission'
);
select is(
  (select auth_ext.has_permission('p:discussions'))
  ,true
  ,'user should have p:discussions permission'
);
select is(
  (select auth_ext.has_permission(
    _permission_key => 'p:discussions'::citext
    ,_app_tenant_id => (select id from app.app_tenant where type = 'anchor')
  ))
  ,true
  ,'user should have p:discussions permission for tenant'
);

SELECT * FROM finish();
ROLLBACK;




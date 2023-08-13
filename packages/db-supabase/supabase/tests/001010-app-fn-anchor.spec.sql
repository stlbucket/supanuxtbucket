BEGIN;
\set _superadmin_email 'app-admin-super@example.com'
\set _user_email 'anchor-tenant-user@example.com'
------------------------------------
-- THESE TEST EXPLICITLY ENSURE THE BASIC APP USER resident FOR THE INITIAL SUPER ADMIN USER
-- LATER TESTS WILL USE ONLY THE HELPER FUNCTIONS TO SETUP FOR TESTS AS NECESSARY
------------------------------------

-- SELECT plan(12);
SELECT * FROM no_plan();
-- Examples: https://pgtap.org/documentation.html
------------------------------------
select is(
  (select count(*) from app.tenant where type = 'anchor'::app.tenant_type)::integer
  ,1::integer
  ,'should be an anchor app tenant'
);
------------------------------------
select is(
  (select count(*) from app.profile where email = :'_superadmin_email'::citext)::integer
  ,0::integer
  ,'should be no app.profile ---  SUPABASE DB RESET WILL FIX THIS MOST LIKELY'
);
------------------------------------
select is(
  (select count(*) from auth.users where email = :'_superadmin_email'::citext)::integer
  ,0::integer
  ,'should be no auth.users'
);
------------------------------------
select is(
  (select profile_id is null from app.resident where email = :'_superadmin_email'::citext)::boolean
  ,true
  ,'profile_id should be null'
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
  (select count(*) from app.profile where email = :'_superadmin_email'::citext)::integer
  ,1::integer
  ,'should be 1 app.profile'
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
  (select status from app.resident where email = :'_superadmin_email'::citext)::app.resident_status
  ,'active'::app.resident_status
  ,'resident should still be in status of invited'
);
------------------------------------ logout so we can evaluate data as postgres user
select test_helpers.logout();
------------------------------------
select is(
  (select status from app.resident where email = :'_superadmin_email'::citext)::app.resident_status
  ,'active'::app.resident_status
  ,'resident should be in status of active'
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
  app_fn.invite_user(
    _tenant_id => (select id from app.tenant where identifier = 'anchor')::uuid
    ,_email => :'_user_email'::citext
    ,_assignment_scope => 'admin'::app.license_type_assignment_scope
  )
  ,'app.resident'
  ,'invited user should be a resident'
);
select isa_ok(
  (select id from app.license where license_type_key = 'app-admin' and resident_id = (select id from app.resident where email = :'_user_email'::citext))
  ,'uuid'
  ,'_user_email should have app-admin license'
);
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
select app_fn.assume_residency(
  _resident_id => (select id from app.resident where email = :'_user_email'::citext)
  ,_email => :'_user_email'::citext
);
select test_helpers.logout();
select test_helpers.login_as_user(
  _email => :'_user_email'::citext
);
------------------------------------ test permissions
-- select is(
--   (select license_type_key)
-- );
select is(
  (select auth_ext.has_permission('p:app-admin-super'))
  ,false
  ,'user should not have p:app-admin-super permission'
);
select is(
  (select auth_ext.has_permission('p:app-admin'))
  ,true
  ,'user should not have p:app-admin permission'
);
select is(
  (select auth_ext.has_permission('p:app-user'))
  ,false
  ,'user should not have p:app-user permission'
);
select is(
  (select auth_ext.has_permission('p:discussions'))
  ,true
  ,'user should have p:discussions permission'
);
select is(
  (select auth_ext.has_permission(
    _permission_key => 'p:discussions'::citext
    ,_tenant_id => (select id from app.tenant where type = 'anchor')
  ))
  ,true
  ,'user should have p:discussions permission for tenant'
);

SELECT * FROM finish();
ROLLBACK;




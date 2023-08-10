BEGIN;
\set _superadmin_email 'app-admin-super@example.com'

SELECT * FROM no_plan();
------------------------------------
-- THIS CODE BLOCK CREATES THE SUPER ADMIN USER
-- AND REPRESENTS THE CURRENT MINUMUM TO DO SO
--
-- CAN MAYBE BE REFACTORED TO A TEST HELPER
-- BUT IT WILL LIKELY HAVE TO DO DIRECT INSERTS
-- BECAUSE LOGIN/LOGOUT IS REQUIRED MORE THAN ONCE
-- TO MANIPULATE THE USER JWT FOR LATER TESTS
-- 
-- PROCESS IS AS FOLLOWS:
--
--    1 - CREATE SUPABASE USER
--        inserts auth.users record, which triggers insert of app.app_user and association of tenancies
--    2 - LOGIN AS SUPERADMIN USER
--    3 - ASSUME TENANCY
--        - changes app.app_user_tenancy record from 'invited' to 'active'
--    4 and 5 - LOGOUT and LOGIN AS SUPERASMIN USER
--        this is so that the auth.jwt() value gets properly set after assuming tenancy
--        this value will be set thru pgSettings with postgraphile on every request for the actual site
--        but for unit tests, this is necessary
------------------------------------  create a new supabase user, which will insert app.app_user via trigger
select isa_ok(
  test_helpers.create_supabase_user(
    _email => :'_superadmin_email'::citext
    ,_user_metadata => '{"test": "meta"}'::jsonb
    ,_password => 'badpassword'
  )
  ,'uuid'
  ,'create_supabase_user should return uuid'
);
------------------------------------ login as anchor user, this is first-time login for this user, so tenancy gets connected
select test_helpers.login_as_user(
  _email => :'_superadmin_email'::citext
);
------------------------------------ on first login, user will confirm tenancy (can be automatic), which sets tenancy to active
select isa_ok(
  app_fn_api.assume_app_user_tenancy(
    _app_user_tenancy_id => (select id from app.app_user_tenancy where email = :'_superadmin_email'::citext)
  )
  ,'app.app_user_tenancy'
  ,'should assume the tenancy'
);
------------------------------------ logout so we can evaluate data as postgres user
select test_helpers.logout();
------------------------------------ login as anchor user
select test_helpers.login_as_user(
  _email => :'_superadmin_email'::citext
);
    -------------------------------- this test should fail.  comment out to run tests.
    -------------------------------- its purpose is to print out the super admin licenses
    -- select is(
    --   (select to_jsonb(array_agg(jsonb_build_object(
    --     'license_type_key' ,l.license_type_key
    --     ,'email' ,aut.email
    --     ,'tenant' ,t.name
    --   )))
    --     from app.license l
    --     join app.app_user_tenancy aut on l.app_user_tenancy_id = aut.id
    --     join app.app_tenant t on t.id = aut.app_tenant_id
    --     where aut.email = :'_superadmin_email'::citext
    --   )::jsonb
    --   ,null::jsonb
    --   ,'licenses'
    -- );
------------------------------------
-- END SUPER ADMIN SETUP CODE BLOCK
------------------------------------

SELECT * FROM finish();
ROLLBACK;




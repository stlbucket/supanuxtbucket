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
--        inserts auth.users record, which triggers insert of app.profile and association of tenancies
--    2 - LOGIN AS SUPERADMIN USER
--    3 - ASSUME resident
--        - changes app.resident record from 'invited' to 'active'
--    4 and 5 - LOGOUT and LOGIN AS SUPERASMIN USER
--        this is so that the auth.jwt() value gets properly set after assuming resident
--        this value will be set thru pgSettings with postgraphile on every request for the actual site
--        but for unit tests, this is necessary
------------------------------------  create a new supabase user, which will insert app.profile via trigger
select isa_ok(
  test_helpers.create_supabase_user(
    _email => :'_superadmin_email'::citext
    ,_user_metadata => '{"test": "meta"}'::jsonb
    ,_password => 'badpassword'
  )
  ,'uuid'
  ,'create_supabase_user should return uuid'
);
------------------------------------ login as anchor user, this is first-time login for this user, so resident gets connected
select test_helpers.login_as_user(
  _email => :'_superadmin_email'::citext
);
------------------------------------ on first login, user will confirm resident (can be automatic), which sets resident to active
  select isa_ok(
    app_fn.assume_residency(
      _resident_id => (select id from app.resident where email = :'_superadmin_email'::citext)
      ,_email => :'_superadmin_email'
    )
    ,'app.resident'
    ,'should assume the resident'
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
    --     join app.resident aut on l.resident_id = aut.id
    --     join app.tenant t on t.id = aut.tenant_id
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




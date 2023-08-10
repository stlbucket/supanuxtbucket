BEGIN;
-- SELECT plan(7);
SELECT * FROM no_plan();

-- Examples: https://pgtap.org/documentation.html
\set _app_tenant_name 'msg-test-tenant'
\set _app_tenant_admin_email 'msg-test-tenant1-admin@example.com'
-- \set _license_pack_key 'msg'
\set _identifier 'msg-test-tenant'
------------------------------------------------------------------------
-- SETUP TEST TENANT
------------------------------------------------------------------------ 
  select isa_ok(
    (select app_fn.create_app_tenant(
      :'_app_tenant_name'::citext
      ,:'_identifier'::citext
      ,:'_app_tenant_admin_email'::citext
    ))
    ,'app.app_tenant'
    ,'should create an app_tenant'
  );
  -- select isa_ok(
  --   (select app_fn.subscribe_tenant_to_license_pack(
  --     _app_tenant_id => (select id from app.app_tenant where name = :'_app_tenant_name'::citext)
  --     ,_license_pack_key => :'_license_pack_key'::citext
  --   ))
  --   ,'app.app_tenant_subscription'
  --   ,'should subscribe tenant to license pack'
  -- );
  select isa_ok(
    test_helpers.create_supabase_user(
      _email => :'_app_tenant_admin_email'::text
      ,_user_metadata => '{"test": "meta"}'::jsonb
      ,_password => 'badpassword'
    )
    ,'uuid'
    ,'create_supabase_user should return uuid'
  );
  select test_helpers.login_as_user(
    _email => :'_app_tenant_admin_email'::citext
  );
  select isa_ok(
    app_fn.assume_app_user_tenancy(
      _app_user_tenancy_id => (select id from app.app_user_tenancy where email = :'_app_tenant_admin_email'::citext)
      ,_email => :'_app_tenant_admin_email'::citext
    )
    ,'app.app_user_tenancy'
    ,'should assume the tenancy'
  );
  select test_helpers.logout();
------------------------------------------------------------------------
-- END SETUP TEST TENANT
------------------------------------------------------------------------ 

------------------------------------------------------------------------ 
-- EXERCISE MSG FUNCTIONS
------------------------------------------------------------------------ 
  \set _topic_name "test msg topic name"
  \set _msg_1 "test msg 1"
  \set _msg_2 "test msg 2"

  select test_helpers.login_as_user(
    _email => :'_app_tenant_admin_email'::citext
  );
  ------------------------------------ test permissions
  select is(
    (select auth_ext.has_permission('p:app'))
    ,false
    ,'_app_tenant_admin_email user should not have app permission'
  );
  ------------------------------------ test permissions
  select is(
    (select auth_ext.has_permission('p:app-admin'))
    ,true
    ,'_app_tenant_admin_email user should have p:app-admin permission'
  );
  ------------------------------------ test permissions
  select is(
    (select auth_ext.has_permission('p:app-admin-super'))
    ,false
    ,'_app_tenant_admin_email user should not have p:app-admin-super permission'
  );
------------------------------------------------------------------------ 
-- END EXERCISE MSG FUNCTIONS
------------------------------------------------------------------------ 

SELECT * FROM finish();
ROLLBACK;

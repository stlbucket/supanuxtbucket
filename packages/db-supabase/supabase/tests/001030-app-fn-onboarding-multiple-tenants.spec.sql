BEGIN;
-- SELECT plan(7);
SELECT * FROM no_plan();
-- -- Examples: https://pgtap.org/documentation.html
-- \set _license_pack_key 'todo'
\set _superadmin_email 'app-admin-super@example.com'
------------------------------------------------------------------------
-- SETUP APP TENANT 1
------------------------------------------------------------------------ create_app_tenant
\set _app_tenant_name_1 'todo-test-tenant-1'
\set _app_tenant_admin_email_1 'todo-test-tenant-1-admin@example.com'
\set _identifier_1 'todo-test-tenant-1'
------------------------------------------------------------------------
select isa_ok(
  (select app_fn.create_app_tenant(
    :'_app_tenant_name_1'::citext
    ,:'_identifier_1'::citext
    ,:'_app_tenant_admin_email_1'::citext
  ))
  ,'app.app_tenant'
  ,'should create an app_tenant'
);
-- select isa_ok(
--   (select app_fn.subscribe_tenant_to_license_pack(
--     _app_tenant_id => (select id from app.app_tenant where identifier = :'_identifier_1'::citext)
--     ,_license_pack_key => :'_license_pack_key'::citext
--   ))
--   ,'app.app_tenant_subscription'
--   ,'should subscribe tenant to license pack'
-- );
-- ------------------------------------------------------------------------
-- ------------------------------------------------------------------------ create_supabase_user
select isa_ok(
  test_helpers.create_supabase_user(
    _email => :'_app_tenant_admin_email_1'::text
    ,_user_metadata => '{"test": "meta"}'::jsonb
    ,_password => 'badpassword'
  )
  ,'uuid'
  ,'create_supabase_user should return uuid'
);
-- ------------------------------------------------------------------------
-- ------------------------------------------------------------------------ login as test user 1
select test_helpers.login_as_user(
  _email => :'_app_tenant_admin_email_1'::citext
);
-- ------------------------------------------------------------------------
-- ------------------------------------------------------------------------ assume_app_user_tenancy
select isa_ok(
  app_fn.assume_app_user_tenancy(
    _app_user_tenancy_id => (select id from app.app_user_tenancy where email = :'_app_tenant_admin_email_1'::citext)
    ,_email => :'_app_tenant_admin_email_1'
  )
  ,'app.app_user_tenancy'
  ,'should assume the tenancy'
);
    ------------------------------------------------------------------------
    select is(
      (select status from app.app_user_tenancy where email = :'_app_tenant_admin_email_1'::citext)::app.app_user_tenancy_status
      ,'active'::app.app_user_tenancy_status
      ,'tenancy should be in status of active'
    );
----------------------------------------------------------------------
-- END SETUP APP TENANT 1
------------------------------------------------------------------------

------------------------------------------------------------------------
-- SETUP APP TENANT 2
------------------------------------------------------------------------ create_app_tenant
\set _app_tenant_name_2 'todo-test-tenant-2'
\set _app_tenant_admin_email_2 'todo-test-tenant-2-admin@example.com'
\set _identifier_2 'todo-test-tenant-2'
------------------------------------------------------------------------
select test_helpers.logout();
select isa_ok(
  (select app_fn.create_app_tenant(
    :'_app_tenant_name_2'::citext
    ,:'_identifier_2'::citext
    ,:'_app_tenant_admin_email_2'::citext
  ))
  ,'app.app_tenant'
  ,'should create an app_tenant'
);
-- select isa_ok(
--   (select app_fn.subscribe_tenant_to_license_pack(
--     _app_tenant_id => (select id from app.app_tenant where identifier = :'_identifier_2'::citext)
--     ,_license_pack_key => :'_license_pack_key'::citext
--   ))
--   ,'app.app_tenant_subscription'
--   ,'should subscribe tenant to license pack'
-- );
------------------------------------------------------------------------
------------------------------------------------------------------------ create_supabase_user
select test_helpers.logout();
select isa_ok(
  test_helpers.create_supabase_user(
    _email => :'_app_tenant_admin_email_2'::text
    ,_user_metadata => '{"test": "meta"}'::jsonb
    ,_password => 'badpassword'
  )
  ,'uuid'
  ,'create_supabase_user should return uuid'
);
------------------------------------------------------------------------
------------------------------------------------------------------------ login as test user 2
select test_helpers.login_as_user(
  _email => :'_app_tenant_admin_email_2'::citext
);
------------------------------------------------------------------------
------------------------------------------------------------------------ assume_app_user_tenancy
select isa_ok(
  app_fn.assume_app_user_tenancy(
    _app_user_tenancy_id => (select id from app.app_user_tenancy where email = :'_app_tenant_admin_email_2'::citext)
    ,_email => :'_app_tenant_admin_email_2'::citext
  )
  ,'app.app_user_tenancy'
  ,'should assume the tenancy'
);
select test_helpers.logout();
select test_helpers.login_as_user(
  _email => :'_app_tenant_admin_email_2'::citext
);
  ------------------------------------------------------------------------
    select is(
      (select status from app.app_user_tenancy where email = :'_app_tenant_admin_email_2'::citext)::app.app_user_tenancy_status
      ,'active'::app.app_user_tenancy_status
      ,'tenancy should be in status of active'
    );
----------------------------------------------------------------------
-- END SETUP APP TENANT 2
------------------------------------------------------------------------

------------------------------------------------------------------------
----------------------------------------------------------------------
-- CROSS-TENANT INVITATIONS
-- this test suite invite user 1 to tenant 2, then switches that user to tenant 2, then back to tenant 1
-- verifying that they are properly switch via app_user_tenancy.status and RLS visibility to app.app_tenant
------------------------------------------------------------------------
------------------------------------------------------------------------ invite test user 1 to tenant 2
select isa_ok(
  app_fn_api.invite_user(
    _email => :'_app_tenant_admin_email_1'::citext
  )
  ,'app.app_user_tenancy'
  ,'should create a tenancy'
);
  ------------------------------------------------------------------------
    select is(
      (
        select auth_ext.has_permission('p:app-admin', id) from app.app_tenant where identifier = :'_identifier_2'::citext
      )::boolean
      ,true::boolean
      ,'admin_email_2 should have app-admin permission'
    );
  ------------------------------------------------------------------------
    select is(
      (
        select status from app.app_user_tenancy where email = :'_app_tenant_admin_email_1'::citext 
        and app_tenant_id = (
          select id from app.app_tenant where identifier = :'_identifier_2'::citext
        )
      )::app.app_user_tenancy_status
      ,'invited'::app.app_user_tenancy_status
      ,'admin_email_1 tenancy should be in status of invited'
    );
  ------------------------------------------------------------------------
    select is(
      (select count(*) from app.app_user_tenancy where email = :'_app_tenant_admin_email_1'::citext)::integer
      ,1::integer
      ,'admin_email_1 tenancy count in tenant 2 should be 1'
    );
  ------------------------------------------------------------------------
    select is(
      (select count(*) from app.app_user_tenancy where email = :'_app_tenant_admin_email_2'::citext)::integer
      ,1::integer
      ,'admin_email_2 tenancy count in tenant 2 should be 1'
    );
------------------------------------ become _app_tenant_admin_email_1
select test_helpers.logout();
select test_helpers.login_as_user(
  _email => :'_app_tenant_admin_email_1'::citext
);
  ------------------------------------------------------------------------
    select is(
      (
        select status from app.app_user_tenancy where email = :'_app_tenant_admin_email_1'::citext 
        and app_tenant_id != (
          select id from app.app_tenant where identifier = :'_identifier_1'::citext
        )
      )::app.app_user_tenancy_status
      ,'invited'::app.app_user_tenancy_status
      ,'admin_email_1 tenancy should be in status of invited'
    );
  -- ------------------------------------------------------------------------
    select is(
      (select count(*) from app.app_user_tenancy where email = :'_app_tenant_admin_email_1'::citext)::integer
      ,2::integer
      ,'admin_email_1 should have 2 total tenancies'
    );
select test_helpers.logout();
select test_helpers.login_as_user(
  _email => :'_app_tenant_admin_email_1'::citext
);
------------------------------------------------------------------------
select isa_ok(
  app_fn.assume_app_user_tenancy(
    _app_user_tenancy_id => (
      select id from app.app_user_tenancy where email = :'_app_tenant_admin_email_1'::citext
      and app_tenant_id != (
        select id from app.app_tenant where identifier = :'_identifier_1'::citext
      )
    ),
    _email => :'_app_tenant_admin_email_1'::citext
  )
  ,'app.app_user_tenancy'
  ,'admin_email_1 should assume the tenancy for _identifier_2'
);
    ------------------------------------------------------------------------ check tenant 1 status now inactive
    select is(
      (
        select status from app.app_user_tenancy where email = :'_app_tenant_admin_email_1'::citext 
        and app_tenant_id = (
          select id from app.app_tenant where identifier = :'_identifier_1'::citext
        )
      )::app.app_user_tenancy_status
      ,'inactive'::app.app_user_tenancy_status
      ,'first tenancy should be in status of inactive'
    );
    ------------------------------------------------------------------------
    select is(
      (
        select identifier from app.app_tenant
      )::citext
      ,:'_identifier_1'::citext
      ,'app tenant identifier should be _identifier_1'
    );
------------------------------------------------------------------------ switch to tenant 2 and verify active
select test_helpers.logout();
select test_helpers.login_as_user(
  _email => :'_app_tenant_admin_email_1'::citext
);
    select is(
      (
        select status from app.app_user_tenancy where email = :'_app_tenant_admin_email_1'::citext 
        and app_tenant_id = (
          select id from app.app_tenant where identifier = :'_identifier_2'::citext
        )
      )::app.app_user_tenancy_status
      ,'active'::app.app_user_tenancy_status
      ,'second tenancy should be in status of active'
    );
    ------------------------------------------------------------------------
    select is(
      (
        select identifier from app.app_tenant
      )::citext
      ,:'_identifier_2'::citext
      ,'app tenant identifier should be _identifier_2'
    );
------------------------------------------------------------------------ assume tenant 1 tenancy
select isa_ok(
  app_fn.assume_app_user_tenancy(
    _app_user_tenancy_id => (
      select id from app.app_user_tenancy where email = :'_app_tenant_admin_email_1'::citext
      and app_tenant_id != (
        select id from app.app_tenant where identifier = :'_identifier_2'::citext
      )
    ),
    _email => :'_app_tenant_admin_email_1'
  )
  ,'app.app_user_tenancy'
  ,'admin_email_1 should assume the tenancy for _identifier_1'
);
------------------------------------------------------------------------ switch to tenant 1 and verify active
select test_helpers.logout();
select test_helpers.login_as_user(
  _email => :'_app_tenant_admin_email_1'::citext
);
    select is(
      (
        select status from app.app_user_tenancy where email = :'_app_tenant_admin_email_1'::citext 
        and app_tenant_id = (
          select id from app.app_tenant where identifier = :'_identifier_1'::citext
        )
      )::app.app_user_tenancy_status
      ,'active'::app.app_user_tenancy_status
      ,'second tenancy should be in status of active'
    );
    ------------------------------------------------------------------------
    select is(
      (
        select identifier from app.app_tenant
      )::citext
      ,:'_identifier_1'::citext
      ,'app tenant identifier should be _identifier_1'
    );
------------------------------------------------------------------------
-- use this to look at current licenses or other info as needed
    ------------------------------------------------------------------------
    -- select is(
    --   (select to_jsonb(array_agg(jsonb_build_object(
    --     'license_type_key' ,l.license_type_key
    --     ,'email' ,au.email
    --     ,'tenant' ,t.name
    --   )))
    --     from app.license l
    --     join app.app_user_tenancy aut on l.app_user_tenancy_id = aut.id
    --     join app.app_user au on au.id = aut.app_user_id
    --     join app.app_tenant t on t.id = aut.app_tenant_id
    --   )::jsonb
    --   ,'{}'::jsonb
    --   ,'licenses'
    -- );
-- select test_helpers.login_as_user(
--   _email => :'_app_tenant_admin_email_1'::citext
-- );
SELECT * FROM finish();
ROLLBACK;




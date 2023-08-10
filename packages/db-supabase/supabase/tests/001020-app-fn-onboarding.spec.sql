BEGIN;
-- SELECT plan(7);
SELECT * FROM no_plan();

-- Examples: https://pgtap.org/documentation.html
\set _superadmin_email 'app-admin-super@example.com'
\set _app_tenant_name 'todo-test-tenant'
\set _app_tenant_admin_email 'todo-test-tenant1-admin@example.com'
-- \set _license_pack_key 'todo'
\set _identifier 'todo-test-tenant'
------------------------------------------------------------------------
------------------------------------------------------------------------ create_app_tenant
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
    ------------------------------------
    select is(
      (select count(*) from app.app_tenant where name = :'_app_tenant_name'::citext)::integer
      ,1::integer
      ,'should be an app tenant'
    );
    ------------------------------------
    select is(
      (select count(*) from app.app_user_tenancy where email = :'_app_tenant_admin_email'::citext)::integer
      ,1::integer
      ,'should be an app_user_tenancy'
    );
    ------------------------------------
    select is(
      (select count(*) from app.app_tenant_subscription where app_tenant_id = (select id from app.app_tenant where identifier = :'_identifier'::citext))::integer
      ,2::integer
      ,'should be 2 app_tenant_subscriptions'
    );
    ------------------------------------
    -- select is(
    --   (select to_jsonb(array_agg(jsonb_build_object(
    --     'license_type_key' ,l.license_type_key
    --     ,'email' ,aut.email
    --     ,'tenant' ,t.name
    --   )))
    --     from app.license l
    --     join app.app_user_tenancy aut on l.app_user_tenancy_id = aut.id
    --     join app.app_tenant t on t.id = aut.app_tenant_id
    --     where aut.email = :'_app_tenant_admin_email'::citext
    --   )::jsonb
    --   ,'{}'::jsonb
    --   ,'licenses'
    -- );
    -- select is(
    --   (select count(*) from app.license where app_user_tenancy_id = (select id from app.app_user_tenancy where email = :'_app_tenant_admin_email'::citext))::integer
    --   ,2::integer
    --   ,'should be 2 licenses'
    -- );
    ------------------------------------
    select is(
      (select count(*) from app.app_user where email = :'_app_tenant_admin_email'::citext)::integer
      ,0::integer
      ,'should be no app.app_user'
    );
    ------------------------------------
    select is(
      (select count(*) from auth.users where email = :'_app_tenant_admin_email'::citext)::integer
      ,0::integer
      ,'should be no auth.users'
    );
------------------------------------------------------------------------
------------------------------------------------------------------------ create_supabase_user
select isa_ok(
  test_helpers.create_supabase_user(
    _email => :'_app_tenant_admin_email'::text
    ,_user_metadata => '{"test": "meta"}'::jsonb
    ,_password => 'badpassword'
  )
  ,'uuid'
  ,'create_supabase_user should return uuid'
);
    ------------------------------------
    select is(
      (select count(*) from app.app_user where email = :'_app_tenant_admin_email'::citext)::integer
      ,1::integer
      ,'should be 1 app.app_user'
    );
    ------------------------------------
    select is(
      (select count(*) from auth.users where email = :'_app_tenant_admin_email'::citext)::integer
      ,1::integer
      ,'should be 1 auth.users'
    );
    ------------------------------------
    select is(
      (select status from app.app_user_tenancy where email = :'_app_tenant_admin_email'::citext and app_tenant_id = (select id from app.app_tenant where identifier = :'_identifier'::citext))::app.app_user_tenancy_status
      ,'active'::app.app_user_tenancy_status
      ,'app_user_tenancy should be active'
    );
    ------------------------------------
    select is(
      (select app_user_id is not null from app.app_user_tenancy where email = :'_app_tenant_admin_email'::citext)::boolean
      ,true
      ,'app_user_id should not be null'
    );
------------------------------------------------------------------------
------------------------------------------------------------------------ login as test user
select test_helpers.login_as_user(
  _email => :'_app_tenant_admin_email'::citext
);
------------------------------------------------------------------------
------------------------------------------------------------------------ assume_app_user_tenancy
select isa_ok(
  app_fn.assume_app_user_tenancy(
    _app_user_tenancy_id => (select id from app.app_user_tenancy where email = :'_app_tenant_admin_email'::citext)
    ,_email => :'_app_tenant_admin_email'
  )
  ,'app.app_user_tenancy'
  ,'should assume the tenancy'
);
------------------------------------
select is(
  (select status from app.app_user_tenancy where email = :'_app_tenant_admin_email'::citext)::app.app_user_tenancy_status
  ,'active'::app.app_user_tenancy_status
  ,'tenancy should be in status of active'
);
------------------------------------------------------------------------
------------------------------------------------------------------------ logout
select test_helpers.logout();
------------------------------------------------------------------------ test address book
select test_helpers.login_as_user(
  _email => :'_app_tenant_admin_email'::citext
);
  select isa_ok(
    (select app_fn_api.join_address_book())
    ,'app.app_user'
    ,'should join address book'
  );
  select is(
    (select is_public from app.app_user where email = :'_app_tenant_admin_email'::citext)
    ,true
    ,'_app_tenant_admin_email should be public'
  );
  select is(
    (select m.email from app_fn_api.get_myself() m)
    ,:'_app_tenant_admin_email'
    ,'should get myself'
  );
select test_helpers.logout();
------------------------------------------------------------------------ test address book

SELECT * FROM finish();
ROLLBACK;




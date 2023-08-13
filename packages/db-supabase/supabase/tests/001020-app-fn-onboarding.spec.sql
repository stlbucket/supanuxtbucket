BEGIN;
-- SELECT plan(7);
SELECT * FROM no_plan();

-- Examples: https://pgtap.org/documentation.html
\set _superadmin_email 'app-admin-super@example.com'
\set _tenant_name 'todo-test-tenant'
\set _tenant_admin_email 'todo-test-tenant1-admin@example.com'
-- \set _license_pack_key 'todo'
\set _identifier 'todo-test-tenant'
------------------------------------------------------------------------
------------------------------------------------------------------------ create_tenant
select isa_ok(
  (select app_fn.create_tenant(
    :'_tenant_name'::citext
    ,:'_identifier'::citext
    ,:'_tenant_admin_email'::citext
  ))
  ,'app.tenant'
  ,'should create an tenant'
);
-- select isa_ok(
--   (select app_fn.subscribe_tenant_to_license_pack(
--     _tenant_id => (select id from app.tenant where name = :'_tenant_name'::citext)
--     ,_license_pack_key => :'_license_pack_key'::citext
--   ))
--   ,'app.tenant_subscription'
--   ,'should subscribe tenant to license pack'
-- );
    ------------------------------------
    select is(
      (select count(*) from app.tenant where name = :'_tenant_name'::citext)::integer
      ,1::integer
      ,'should be an app tenant'
    );
    ------------------------------------
    select is(
      (select count(*) from app.resident where email = :'_tenant_admin_email'::citext)::integer
      ,1::integer
      ,'should be an resident'
    );
    ------------------------------------
    select is(
      (select count(*) from app.tenant_subscription where license_pack_key = 'app' and tenant_id = (select id from app.tenant where identifier = :'_identifier'::citext))::integer
      ,1::integer
      ,'should be 1 app tenant_subscriptions'
    );
    ------------------------------------
    -- select is(
    --   (select to_jsonb(array_agg(jsonb_build_object(
    --     'license_type_key' ,l.license_type_key
    --     ,'email' ,aut.email
    --     ,'tenant' ,t.name
    --   )))
    --     from app.license l
    --     join app.resident aut on l.resident_id = aut.id
    --     join app.tenant t on t.id = aut.tenant_id
    --     where aut.email = :'_tenant_admin_email'::citext
    --   )::jsonb
    --   ,'{}'::jsonb
    --   ,'licenses'
    -- );
    -- select is(
    --   (select count(*) from app.license where resident_id = (select id from app.resident where email = :'_tenant_admin_email'::citext))::integer
    --   ,2::integer
    --   ,'should be 2 licenses'
    -- );
    ------------------------------------
    select is(
      (select count(*) from app.profile where email = :'_tenant_admin_email'::citext)::integer
      ,0::integer
      ,'should be no app.profile'
    );
    ------------------------------------
    select is(
      (select count(*) from auth.users where email = :'_tenant_admin_email'::citext)::integer
      ,0::integer
      ,'should be no auth.users'
    );
------------------------------------------------------------------------
------------------------------------------------------------------------ create_supabase_user
select isa_ok(
  test_helpers.create_supabase_user(
    _email => :'_tenant_admin_email'::text
    ,_user_metadata => '{"test": "meta"}'::jsonb
    ,_password => 'badpassword'
  )
  ,'uuid'
  ,'create_supabase_user should return uuid'
);
    ------------------------------------
    select is(
      (select count(*) from app.profile where email = :'_tenant_admin_email'::citext)::integer
      ,1::integer
      ,'should be 1 app.profile'
    );
    ------------------------------------
    select is(
      (select count(*) from auth.users where email = :'_tenant_admin_email'::citext)::integer
      ,1::integer
      ,'should be 1 auth.users'
    );
    ------------------------------------
    select is(
      (select status from app.resident where email = :'_tenant_admin_email'::citext and tenant_id = (select id from app.tenant where identifier = :'_identifier'::citext))::app.resident_status
      ,'active'::app.resident_status
      ,'resident should be active'
    );
    ------------------------------------
    select is(
      (select profile_id is not null from app.resident where email = :'_tenant_admin_email'::citext)::boolean
      ,true
      ,'profile_id should not be null'
    );
------------------------------------------------------------------------
------------------------------------------------------------------------ login as test user
select test_helpers.login_as_user(
  _email => :'_tenant_admin_email'::citext
);
------------------------------------------------------------------------
------------------------------------------------------------------------ assume_residency
select isa_ok(
  app_fn.assume_residency(
    _resident_id => (select id from app.resident where email = :'_tenant_admin_email'::citext)
    ,_email => :'_tenant_admin_email'
  )
  ,'app.resident'
  ,'should assume the resident'
);
------------------------------------
select is(
  (select status from app.resident where email = :'_tenant_admin_email'::citext)::app.resident_status
  ,'active'::app.resident_status
  ,'resident should be in status of active'
);
------------------------------------------------------------------------
------------------------------------------------------------------------ logout
select test_helpers.logout();
------------------------------------------------------------------------ test address book
select test_helpers.login_as_user(
  _email => :'_tenant_admin_email'::citext
);
  select isa_ok(
    (select app_api.join_address_book())
    ,'app.profile'
    ,'should join address book'
  );
  select is(
    (select is_public from app.profile where email = :'_tenant_admin_email'::citext)
    ,true
    ,'_tenant_admin_email should be public'
  );
  select is(
    (select m.email from app_api.get_myself() m)
    ,:'_tenant_admin_email'
    ,'should get myself'
  );
select test_helpers.logout();
------------------------------------------------------------------------ test address book

SELECT * FROM finish();
ROLLBACK;




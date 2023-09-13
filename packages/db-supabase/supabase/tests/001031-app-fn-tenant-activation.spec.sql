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
  ,'should create a tenant'
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
select isa_ok(
  test_helpers.create_supabase_user(
    _email => :'_superadmin_email'::citext
    ,_user_metadata => '{"test": "meta"}'::jsonb
    ,_password => 'badpassword'
  )
  ,'uuid'
  ,'create_supabase_user should return uuid'
);
select test_helpers.login_as_user(
  _email => :'_superadmin_email'::citext
);
  select isa_ok(
    app_fn.assume_residency(
      _resident_id => (select id from app.resident where email = :'_superadmin_email'::citext)
      ,_email => :'_superadmin_email'
    )
    ,'app.resident'
    ,'should assume the resident'
  );
  select isa_ok(
    (select app_fn.deactivate_tenant(id) from app.tenant where identifier = :'_identifier'::citext)
    ,'app.tenant'
    ,'should deactivate app tenant'
  );
  -- select is(
  --   -- (select to_jsonb(t.*)from app.tenant t where identifier = :'_identifier'::citext)::jsonb
  --   -- (select to_jsonb(t.*)from app.resident t where email = :'_superadmin_email'::citext)::jsonb
  --   (select to_jsonb(t.*)from app_api.current_profile_claims() t)::jsonb
  --   ,'{}'::jsonb
  --   ,'tacos'
  -- );
-- select test_helpers.logout();
  -- select is(
  --   (select status from app.tenant where identifier = :'_identifier'::citext)
  --   ,'inactive'::app.tenant_status
  -- );
-- select test_helpers.login_as_user(
--   _email => :'_superadmin_email'::citext
-- );
  select is(
    (select count(*) from app.resident where tenant_id = (select id from app.tenant where identifier = :'_identifier'::citext) and status = 'active')::integer
    ,0::integer
  );
  select is(
    (select count(*) from app.license where tenant_id = (select id from app.tenant where identifier = :'_identifier'::citext))::integer
    ,0::integer
  );
  select is(
    (select app_fn.current_profile_claims(id) from app.profile where email = :'_tenant_admin_email')
    ,null::app_fn.profile_claims
  );
select test_helpers.logout();
------------------------------------------------------------------------ test address book

SELECT * FROM finish();
ROLLBACK;




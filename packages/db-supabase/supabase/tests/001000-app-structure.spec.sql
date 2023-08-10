BEGIN;
SELECT plan(2);

-- Examples: https://pgtap.org/documentation.html
-- \set tablespaces = 

SELECT schemas_are(ARRAY[ 
  -- first all schemas associated with this application
  'auth_ext'
  ,'app'
  ,'app_fn'
  ,'app_fn_api'
  -- delete this if you don't want todo
  ,'todo'
  ,'todo_fn'
  ,'todo_fn_api'
  ,'msg'
  ,'msg_fn'
  ,'msg_fn_api'
  ,'inc'
  ,'inc_fn'
  ,'inc_fn_api'
  -- put your app here

  -- below here are supabase-specific schemas
  ,'_analytics'
  ,'_realtime'
  ,'auth'
  ,'extensions'
  ,'graphql'
  ,'graphql_public'
  ,'net'
  ,'public'
  ,'realtime'
  ,'storage'
  ,'supabase_functions'
  ,'supabase_migrations'
  ,'test_helpers'
  ,'vault'
 ]);

select tables_are(
  'app'
  ,array[
    'app_settings'
    ,'app_tenant'
    ,'app_user'
    ,'app_user_tenancy'
    ,'app_tenant_subscription'
    ,'application'
    ,'license'
    ,'license_pack'
    ,'license_pack_license_type'
    ,'license_type'
    ,'license_type_permission'
    ,'permission'
  ]
  ,'app schema tables'
);

-- additional tests for all structure could be added
--
-- has_column, has_pk, etc.

SELECT * FROM finish();
ROLLBACK;
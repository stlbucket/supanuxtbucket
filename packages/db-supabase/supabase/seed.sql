------------------------ CREATE ANCHOR TENANT AND SUPER ADMIN USER ---------------------------------------------
--- change parameters as appropriate
  select app_fn.create_anchor_tenant(
    _name => 'Anchor Tenant'::citext
    ,_email => 'app-admin-super@example.com'::citext
  );

  insert into app.app_settings(application_key, key, display_name, value) values ('app', 'support-email', 'Site Support Email', 'site-support@example.com');
  insert into app.app_settings(application_key, key, display_name, value) values ('app', 'support-display-name', 'Site Support Display Name', 'Site Support');

------------------------ INSTALL APPLICATIONS AND SUBSCRIBE ANCHOR TENANT TO EACH ------------------------------

  -- select todo_fn.install_todo_application();
  -- select app_fn.subscribe_tenant_to_license_pack(
  --   _app_tenant_id => (select id from app.app_tenant where identifier = 'anchor')::uuid
  --   ,_license_pack_key => 'todo'
  -- );
      -- select your_app_fn.install_your_application();
      -- select app_fn.subscribe_tenant_to_license_pack(
      --   _app_tenant_id => (select id from app.app_tenant where identifier = 'anchor')::uuid
      --   ,_license_pack_key => 'YOUR LICENSE PACK NAME FROM your_app_fn.install_your_application()'
      -- );

      -- take a look todo_fn.install_todo_application for an example

------------------------------------------------------------------------------------------------------------
------------------------------------- DEMO AND INITIAL TENANTS -------------------------------------------------
--
-- These app_tenants and users are to support local development as they are currently configured. They are
-- used in conjuction with the DemoAppUserTenancies component to allow for quick context switching between
-- tenants and users in conjunction with the Inbucket service
-- 
-- When starting a new project, these can all be leveraged for unit tests and for local UI development
--
-- When deploying to an initial prototype environment (maybe your free project), these can be changed
-- to actual users to allow for easy rebasing of the entire database while maintaining a core set of users.
--
-- Usage in other environments is at the discretion of the developer

-- Note that changes to these demo tenants will break unit tests that check for these to be here
-- those tests can be commented out, adjusted, or deleted as appropriate

-------------------------------  ANCHOR TENANT
  BEGIN;
    select app_fn.invite_user(
      _app_tenant_id => (select id from app.app_tenant where identifier = 'anchor')::uuid
      ,_email => 'anchor-tenant-admin@example.com'::citext
      ,_assignment_scope => 'admin'::app.license_type_assignment_scope
    );
    select app_fn.invite_user(
      _app_tenant_id => (select id from app.app_tenant where identifier = 'anchor')::uuid
      ,_email => 'anchor-tenant-user@example.com'::citext
      ,_assignment_scope => 'user'::app.license_type_assignment_scope
    );
  COMMIT;

-------------------------------  DEMO TENANT 1
  BEGIN;
    select app_fn.create_app_tenant(
      _name =>'Demo Tenant 1'::citext
      ,_identifier =>'demo-tenant-1'::citext
      ,_email => 'demo-tenant-1-admin@example.com'::citext
      , _type => 'demo'::app.app_tenant_type
    );
    -- select app_fn.subscribe_tenant_to_license_pack(
    --   _app_tenant_id => (select id from app.app_tenant where identifier = 'demo-tenant-1')::uuid
    --   ,_license_pack_key => 'todo'
    -- );
    select app_fn.invite_user(
      _app_tenant_id => (select id from app.app_tenant where identifier = 'demo-tenant-1')::uuid
      ,_email => 'demo-tenant-1-user-1@example.com'::citext
      ,_assignment_scope => 'user'::app.license_type_assignment_scope
    );
    select app_fn.invite_user(
      _app_tenant_id => (select id from app.app_tenant where identifier = 'demo-tenant-1')::uuid
      ,_email => 'demo-tenant-1-user-2@example.com'::citext
      ,_assignment_scope => 'user'::app.license_type_assignment_scope
    );
  COMMIT;

-------------------------------  DEMO TENANT 2
  BEGIN;
    select app_fn.create_app_tenant(
      _name =>'Demo Tenant 2'::citext
      ,_identifier =>'demo-tenant-2'::citext
      ,_email => 'demo-tenant-2-admin@example.com'::citext
      , _type => 'demo'::app.app_tenant_type
    );
    -- select app_fn.subscribe_tenant_to_license_pack(
    --   _app_tenant_id => (select id from app.app_tenant where identifier = 'demo-tenant-2')::uuid
    --   ,_license_pack_key => 'todo'
    -- );
    select app_fn.invite_user(
      _app_tenant_id => (select id from app.app_tenant where identifier = 'demo-tenant-2')::uuid
      ,_email => 'demo-tenant-2-user-1@example.com'::citext
      ,_assignment_scope => 'user'::app.license_type_assignment_scope
    );
    select app_fn.invite_user(
      _app_tenant_id => (select id from app.app_tenant where identifier = 'demo-tenant-2')::uuid
      ,_email => 'demo-tenant-2-user-2@example.com'::citext
      ,_assignment_scope => 'user'::app.license_type_assignment_scope
    );

  COMMIT;


  select inc_fn.create_incident(
    _incident_info => row(
      aut.display_name||' Demo Incident'::citext
      ,'This is a demo incident'::citext
      ,aut.display_name||'-demo'::citext
      ,'{}'::citext[]
      ,false::boolean
    )::inc_fn.incident_info
    ,_app_user_tenancy_id => aut.id::uuid
  )
  from app.app_user_tenancy aut;

  select msg_fn.upsert_subscription(
    row(
      t.id
      ,mu.id
    )
  )
  from msg.topic t
  join msg.msg_user mu on mu.app_tenant_id = t.app_tenant_id
  ;

  select msg_fn.upsert_message(
    row(
      null
      ,t.id
      ,('tacos are yummy...')::citext
      ,null
    )
    ,mu.id
  )
  from msg.topic t
  join msg.msg_user mu on mu.app_tenant_id = t.app_tenant_id
  ;

------------------------------- TODO DEMO DATA
    select todo_fn.create_todo(
      _app_user_tenancy_id => id::uuid
      ,_name => (display_name||' todo list')::citext
      ,_options => row(
        'a list just for demos'::citext
        ,null
      )::todo_fn.create_todo_options
    ) from app.app_user_tenancy
    ;

    select todo_fn.create_todo(
      _app_user_tenancy_id => app_user_tenancy_id::uuid
      ,_name => 'This is a subtask'::citext
      ,_options => row(
        'it''s a tree, really....'::citext
        ,id::uuid
      )::todo_fn.create_todo_options
    ) from todo.todo
    ;

  select todo_fn.create_todo(
    _app_user_tenancy_id => app_user_tenancy_id::uuid
    ,_name => 'This is a subtask'::citext
    ,_options => row(
      'it''s a tree, really....'::citext
      ,id::uuid
    )::todo_fn.create_todo_options
  ) from todo.todo
  ;

COMMIT;


\x on
\pset pager off
------------------------------------- DEMO AND INITIAL TENANTS -------------------------------------------------
--
-- These tenants and users are to support local development as they are currently configured. They are
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
    select app_fn.invite_user(
      _tenant_id => (select id from app.tenant where identifier = 'anchor')::uuid
      ,_email => 'anchor-tenant-admin@example.com'::citext
      ,_assignment_scope => 'admin'::app.license_type_assignment_scope
    );
    select app_fn.invite_user(
      _tenant_id => (select id from app.tenant where identifier = 'anchor')::uuid
      ,_email => 'anchor-tenant-user@example.com'::citext
      ,_assignment_scope => 'user'::app.license_type_assignment_scope
    );

-------------------------------  DEMO TENANT 1
    select app_fn.create_tenant(
      _name =>'Demo Tenant 1'::citext
      ,_identifier =>'demo-tenant-1'::citext
      ,_email => 'demo-tenant-1-admin@example.com'::citext
      , _type => 'demo'::app.tenant_type
    );
    -- select app_fn.subscribe_tenant_to_license_pack(
    --   _tenant_id => (select id from app.tenant where identifier = 'demo-tenant-1')::uuid
    --   ,_license_pack_key => 'todo'
    -- );
    select app_fn.invite_user(
      _tenant_id => (select id from app.tenant where identifier = 'demo-tenant-1')::uuid
      ,_email => 'demo-tenant-1-user-1@example.com'::citext
      ,_assignment_scope => 'user'::app.license_type_assignment_scope
    );
    select app_fn.invite_user(
      _tenant_id => (select id from app.tenant where identifier = 'demo-tenant-1')::uuid
      ,_email => 'demo-tenant-1-user-2@example.com'::citext
      ,_assignment_scope => 'user'::app.license_type_assignment_scope
    );

-------------------------------  DEMO TENANT 2
    select app_fn.create_tenant(
      _name =>'Demo Tenant 2'::citext
      ,_identifier =>'demo-tenant-2'::citext
      ,_email => 'demo-tenant-2-admin@example.com'::citext
      , _type => 'demo'::app.tenant_type
    );
    -- select app_fn.subscribe_tenant_to_license_pack(
    --   _tenant_id => (select id from app.tenant where identifier = 'demo-tenant-2')::uuid
    --   ,_license_pack_key => 'todo'
    -- );
    select app_fn.invite_user(
      _tenant_id => (select id from app.tenant where identifier = 'demo-tenant-2')::uuid
      ,_email => 'demo-tenant-2-user-1@example.com'::citext
      ,_assignment_scope => 'user'::app.license_type_assignment_scope
    );
    select app_fn.invite_user(
      _tenant_id => (select id from app.tenant where identifier = 'demo-tenant-2')::uuid
      ,_email => 'demo-tenant-2-user-2@example.com'::citext
      ,_assignment_scope => 'user'::app.license_type_assignment_scope
    );

  select inc_fn.create_incident(
    _incident_info => row(
      aut.display_name||' Demo Incident'::citext
      ,'This is a demo incident.  A long-winded way of saying
      
      
      that we want to see

      what happens when we put a lot of text in here. Blah blah blah
      blah blahblah blahblah blahblah blahblah blahblah blahblah blahblah blahblah blahblah blahblah blah
      '::citext
      ,aut.display_name||'-demo'::citext
      ,'{}'::citext[]
      ,false::boolean
      ,array[
        row(
          'Space Needle',
          '400 Broad St',
          null,
          'Seattle',
          'WA',
          '98109',
          'US',
          '47.6205131',
          '-122.34930359883187'
        ),
        row(
          'Gas Works Park',
          '2101 N Northlake Way',
          null,
          'Seattle',
          'WA',
          '98103',
          'US',
          '47.64570',
          '-122.33434'
        )
      ]::inc_fn.location_info[]
    )::inc_fn.incident_info
    ,_resident_id => aut.id::uuid
  )
  from app.resident aut;

  select msg_fn.upsert_subscriber(
    row(
      t.id
      ,mu.id
    )
  )
  from msg.topic t
  join msg.msg_resident mu on mu.tenant_id = t.tenant_id
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
  join msg.msg_resident mu on mu.tenant_id = t.tenant_id
  ;

------------------------------- TODO DEMO DATA
    select todo_fn.create_todo(
      _resident_id => id::uuid
      ,_name => ('TODO: '||display_name)::citext
      ,_options => row(
        'a todo just for demos'::citext
        ,null
        ,false
      )::todo_fn.create_todo_options
    ) from app.resident
    ;

      select todo_fn.create_todo(
        _resident_id => resident_id::uuid
        ,_name => 'This is a subtask'::citext
        ,_options => row(
          'it''s a tree, really....'::citext
          ,id::uuid
          ,false
        )::todo_fn.create_todo_options
      ) from todo.todo
      -- where description = 'a todo just for demos'::citext
      ;

      select todo_fn.create_todo(
        _resident_id => resident_id::uuid
        ,_name => 'Subtask milestone'::citext
        ,_options => row(
          'treeeeeedom,  treeedom!!!!'::citext
          ,id::uuid
          ,false
        )::todo_fn.create_todo_options
      ) from todo.todo
      -- where description = 'a todo just for demos'::citext
      ;

        select todo_fn.create_todo(
          _resident_id => resident_id::uuid
          ,_name => 'Subtask milestone submilestask'::citext
          ,_options => row(
            'the tree tops hear...'::citext
            ,id::uuid
            ,false
          )::todo_fn.create_todo_options
        ) from todo.todo
        where description = 'treeeeeedom,  treeedom!!!!'::citext
        ;

        select todo_fn.create_todo(
          _resident_id => resident_id::uuid
          ,_name => 'Subtask milestone submilestone'::citext
          ,_options => row(
            'treeeeeeeeally....'::citext
            ,id::uuid
            ,false
          )::todo_fn.create_todo_options
        ) from todo.todo
        where description = 'treeeeeedom,  treeedom!!!!'::citext
        ;

          select todo_fn.create_todo(
            _resident_id => resident_id::uuid
            ,_name => 'getting deep'::citext
            ,_options => row(
              'whoa....'::citext
              ,id::uuid
              ,false
            )::todo_fn.create_todo_options
          ) from todo.todo
          where description = 'treeeeeeeeally....'::citext
        ;

          select todo_fn.create_todo(
            _resident_id => resident_id::uuid
            ,_name => 'deep milestone'::citext
            ,_options => row(
              'always more stuff'::citext
              ,id::uuid
              ,false
            )::todo_fn.create_todo_options
          ) from todo.todo
          where description = 'treeeeeeeeally....'::citext
        ;

          select todo_fn.create_todo(
            _resident_id => resident_id::uuid
            ,_name => 'deep task gotta expand for it'::citext
            ,_options => row(
              'turtles all the way down'::citext
              ,id::uuid
              ,false
            )::todo_fn.create_todo_options
          ) from todo.todo
          where description = 'always more stuff'::citext
          ;


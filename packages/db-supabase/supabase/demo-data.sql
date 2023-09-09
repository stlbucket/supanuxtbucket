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
    DO $$
    DECLARE 
      _user_info jsonb;
    BEGIN
      select ((to_json(http_get('https://randomuser.me/api/'))->>'content')::jsonb->'results')->0 into _user_info;
      raise notice '%', _user_info->>'email';
      perform app_fn.invite_user(
        _tenant_id => (select id from app.tenant where identifier = 'anchor')::uuid
        ,_email => ('admin-'||(_user_info->>'email'))::citext
        ,_assignment_scope => 'admin'::app.license_type_assignment_scope
      );

      select ((to_json(http_get('https://randomuser.me/api/'))->>'content')::jsonb->'results')->0 into _user_info;
      raise notice '%', _user_info->'email';
      perform app_fn.invite_user(
        _tenant_id => (select id from app.tenant where identifier = 'anchor')::uuid
        ,_email => ('user-'||(_user_info->>'email'))::citext
        ,_assignment_scope => 'user'::app.license_type_assignment_scope
      );
    END $$;

-- -------------------------------  DEMO TENANTS
    DO $$
    DECLARE
      _i integer;
      _j integer;
      _tenant_name citext;
      _tenant_identifier citext;
      _users jsonb;
      _user_info jsonb;
      _address jsonb;
      _tenant app.tenant;
    BEGIN
      for _i in 1..2 loop
        -- SETUP THE TENANT
        _users := (to_json(http_get('https://random-data-api.com/api/v2/users?size=3&response_type=json'))->>'content')::jsonb;
        _tenant_name = ('Demo Tenant '||(select count(*) from app.tenant))::citext;
        _tenant_identifier = ('demo-tenant-'||(select count(*) from app.tenant))::citext;

        _user_info := _users->0;
        raise notice '%: %', _tenant_identifier, _user_info->>'email';
        _tenant := app_fn.create_tenant(
          _name => _tenant_name::citext
          ,_identifier => _tenant_identifier::citext
          ,_email => ('admin-'||(_user_info->>'email'))::citext
          , _type => 'demo'::app.tenant_type
        );
        raise notice '%: %', _tenant.id, _tenant.name;

        -- ADDITIONAL USERS
        for _j in 1..2 loop
          _user_info := _users->_j;
          raise notice '%: %', _tenant_identifier, _user_info->>'email';
          perform app_fn.invite_user(
            _tenant_id => _tenant.id::uuid
            ,_email => ('user-'||(_user_info->>'email'))::citext
            ,_assignment_scope => 'admin'::app.license_type_assignment_scope
          );
        end loop;
      end loop;
    END $$;

-- -------------------------------  DEMO LOCATIONS
    DO $$
    DECLARE
      _i integer;
      _j integer;
      _tenant_name citext;
      _tenant_identifier citext;
      _users jsonb;
      _user_info jsonb;
      _address jsonb;
      _tenant app.tenant;
      _min_lat numeric(20,14);
      _max_lat numeric(20,14);
      _min_lon numeric(20,14);
      _max_lon numeric(20,14);
      _lat numeric(20,14);
      _lon numeric(20,14);
      _location loc.location;
      _incident inc.incident;
    BEGIN
      -- roughly the seattle area --
      _max_lat := 47.66538735632654;
      _min_lat := 47.523692641902485;
      _max_lon := -122.38632202148439;
      _min_lon := -122.27920532226564;

      for _tenant in select * from app.tenant loop
        _users := (to_json(http_get('https://random-data-api.com/api/v2/users?size=5&response_type=json'))->>'content')::jsonb;
        for _i in 0..4 loop
            _address := _users->_i->'address';
  
            _lat = ((random()+_i/1e39)*(_max_lat-_min_lat))+_min_lat;
            _lon = ((random()+_i/1e39)*(_max_lon-_min_lon))+_min_lon;

            _location := loc_fn.create_location(
              _resident_id => (select id from app.resident where tenant_id = _tenant.id order by random() limit 1)
              ,_location_info => row(
                null,
                _address->>'street_name',
                _address->>'street_address',
                null,
                _address->>'city',
                _address->>'state',
                _address->>'zip_code',
                _address->>'country',
                _lat::citext,
                _lon::citext
              )::loc_fn.location_info
            );

            _incident := inc_fn.create_incident(
              _incident_info => row(
                aut.display_name||' Demo Incident'::citext
                ,'This is a demo incident.  A long-winded way of saying
                      
                that we want to see

                what happens when we put a lot of text in here. Blah blah blah
                blah blahblah blahblah blahblah blahblah blahblah
                
                blahblah blahblah blahblah blahblah blahblah blah
                '::citext
                ,aut.display_name||'-demo'::citext
                ,'{}'::citext[]
                ,false::boolean
                ,array[
                  row(
                    _location.id,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null
                  )
                ]::loc_fn.location_info[]
              )::inc_fn.incident_info
              ,_resident_id => aut.id::uuid
            )
            from app.resident aut
            where tenant_id = _tenant.id
            order by random()
            limit 1
            ;

        end loop;
      end loop;
    END $$;

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


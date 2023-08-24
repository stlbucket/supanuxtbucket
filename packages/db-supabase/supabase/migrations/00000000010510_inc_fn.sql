----------------------------------- install_incidents_application ---  NO API
CREATE OR REPLACE FUNCTION inc_fn.install_incidents_application()
  RETURNS app.application
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $function$
  DECLARE
    _application app.application;
  BEGIN
    _application := app_fn.install_application(
      _application_info => row(
        'inc'::citext
        ,'Incidents'::citext
        ,array[
          row(
            'incidents-user'::citext
            ,'Incidents User'::citext
            ,'{"p:incidents"}'::citext[]
            ,'user'::app.license_type_assignment_scope
          )::app_fn.license_type_info
          ,row(
            'incidents-admin'::citext
            ,'Incidents Admin'::citext
            ,'{"p:incidents","p:incidents-admin"}'::citext[]
            ,'admin'::app.license_type_assignment_scope
          )::app_fn.license_type_info
        ]::app_fn.license_type_info[]
        ,array[
          row(
            'inc'::citext
            ,'Incidents'::citext
            ,array[
              row(
                'incidents-user'::citext
                ,0::integer
                ,'none'::app.expiration_interval_type
                ,0::integer
              )::app_fn.license_pack_license_type_info
              ,row(
                'incidents-admin'::citext
                ,0::integer
                ,'none'::app.expiration_interval_type
                ,0::integer
              )::app_fn.license_pack_license_type_info
            ]::app_fn.license_pack_license_type_info[]
            ,true
          )::app_fn.license_pack_info
        ]::app_fn.license_pack_info[]
      )::app_fn.application_info
    );

    return _application;
  end;
  $function$
  ;
-------------------------------------- ensure_inc_resident
CREATE OR REPLACE FUNCTION inc_fn.ensure_inc_resident(
    _resident_id uuid
  ) RETURNS inc.inc_resident
    LANGUAGE plpgsql VOLATILE SECURITY DEFINER
    AS $$
  DECLARE
    _inc_tenant inc.inc_tenant;
    _inc_resident inc.inc_resident;
  BEGIN
    -- ensure that the resident has a inc_resident and inc_tenant.  add them if not.
    select t.* 
    into _inc_tenant 
    from inc.inc_tenant t 
    join app.resident aut on t.tenant_id = aut.tenant_id and aut.id = _resident_id
    ;

    if _inc_tenant.tenant_id is null then
      insert into inc.inc_tenant(tenant_id, name)
        select tenant_id, tenant_name
        from app.resident 
        where id = _resident_id
      returning * into _inc_tenant;
    end if;

    select * into _inc_resident from inc.inc_resident where resident_id = _resident_id;
    if _inc_resident.resident_id is null then
      insert into inc.inc_resident(resident_id, display_name, tenant_id)
        select id, display_name, tenant_id
        from app.resident 
        where id = _resident_id 
      returning * into _inc_resident;
    end if;
    return _inc_resident;
  end;
  $$;
------------------------------------ create_incident
CREATE OR REPLACE FUNCTION inc_api.create_incident(
    _incident_info inc_fn.incident_info
  ) RETURNS inc.incident
    LANGUAGE plpgsql VOLATILE
    AS $$
  DECLARE
    _incident inc.incident;
  BEGIN
    _incident := inc_fn.create_incident(
      _incident_info
      ,auth_ext.resident_id()
    );
    return _incident;
  end;
  $$;

CREATE OR REPLACE FUNCTION inc_fn.create_incident(
    _incident_info inc_fn.incident_info
    ,_resident_id uuid
  ) RETURNS inc.incident
    LANGUAGE plpgsql VOLATILE
    AS $$
  DECLARE
    _inc_resident inc.inc_resident;
    _incident inc.incident;
    _topic msg.topic;
    _todo todo.todo;
    _location_info inc_fn.location_info;
  BEGIN
    _inc_resident := inc_fn.ensure_inc_resident(_resident_id);

    if _incident_info.identifier is not null then
      select * into _incident from inc.incident where identifier = _incident_info.identifier; -- this supports nonce from external sources
    end if;

    if _incident.id is null then
      _todo := todo_fn.create_todo(
        _resident_id => _inc_resident.resident_id::uuid
        ,_name => _incident_info.name::citext
        ,_options => row(
          _incident_info.description::citext
          ,null
          ,coalesce(_incident_info.is_template, false)
        )::todo_fn.create_todo_options
      );

      _topic := msg_fn.upsert_topic(
        row(
          null::uuid
          ,_incident_info.name||' topic'::citext
          ,_incident_info.identifier::citext
          ,null::msg.topic_status
        )::msg_fn.topic_info
        ,_inc_resident.resident_id::uuid
      );


      insert into inc.incident(
        tenant_id
        ,created_by_resident_id
        ,todo_id
        ,topic_id
        ,name
        ,description
        ,identifier
        ,tags
        ,is_template
      ) values (
        _inc_resident.tenant_id
        ,_inc_resident.resident_id
        ,_todo.id
        ,_topic.id
        ,_incident_info.name
        ,_incident_info.description
        ,_incident_info.identifier
        ,_incident_info.tags
        ,coalesce(_incident_info.is_template, false)
      )
      returning * into _incident;
    end if;

    foreach _location_info in array(coalesce(_incident_info.locations, '{}'::inc_fn.location_info[]))
    loop
      perform inc_fn.create_incident_location(
        _incident.id
        ,_location_info
      );
    end loop;

    return _incident;
  end;
  $$;
---------------------------------------------- update_incident
CREATE OR REPLACE FUNCTION inc_api.update_incident(
    _incident_id uuid
    ,_name citext
    ,_description citext default null
  )
  RETURNS inc.incident
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $$
  DECLARE
    _retval inc.incident;
  BEGIN
    _retval := inc_fn.update_incident(
      _incident_id
      ,_name
      ,_description
    );
    return _retval;
  end;
  $$;

CREATE OR REPLACE FUNCTION inc_fn.update_incident(
    _incident_id uuid
    ,_name citext
    ,_description citext default null
  )
  RETURNS inc.incident
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $$
  DECLARE
    _retval inc.incident;
  BEGIN
    update inc.incident set
      name = _name
      ,description = _description
    where id = _incident_id
    returning * into _retval
    ;

    return _retval;
  end;
  $$;

---------------------------------------------- update_incident_status
CREATE OR REPLACE FUNCTION inc_api.update_incident_status(
    _incident_id uuid
    ,_status inc.incident_status
  )
  RETURNS inc.incident
  VOLATILE
  SECURITY INVOKER
  LANGUAGE plpgsql
  AS $function$
  DECLARE
    _incident inc.incident;
  BEGIN
    _incident := inc_fn.update_incident_status(_incident_id, _status);
    return _incident;
  end;
  $function$
  ;

CREATE OR REPLACE FUNCTION inc_fn.update_incident_status(
    _incident_id uuid
    ,_status inc.incident_status
  )
  RETURNS inc.incident
  VOLATILE
  SECURITY INVOKER
  LANGUAGE plpgsql
  AS $function$
  DECLARE
    _incident inc.incident;
  BEGIN
      update inc.incident set 
        status = _status
      where id = _incident_id
      returning * into _incident
      ;

    return _incident;
  end;
  $function$
  ;

---------------------------------------------- delete_incident
CREATE OR REPLACE FUNCTION inc_api.delete_incident(_incident_id uuid)
  RETURNS boolean
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $$
  DECLARE
    _retval boolean;
  BEGIN
    _retval := inc_fn.delete_incident(_incident_id);
    return _retval;
  end;
  $$;

CREATE OR REPLACE FUNCTION inc_fn.delete_incident(_incident_id uuid)
  RETURNS boolean
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $$
  DECLARE
    _parent_child_count integer;
    _incident inc.incident;
  BEGIN
    select * into _incident from inc.incident where id = _incident_id;

    perform inc_fn.delete_incident_location(id) from inc.location where incident_id = _incident.id;
    
    delete from inc.incident where id = _incident_id;

    perform todo_fn.delete_todo(_incident.todo_id);
    perform msg_fn.delete_topic(_incident.topic_id);

    return true;
  end;
  $$;

---------------------------------------------- search_incidents
CREATE OR REPLACE FUNCTION inc_api.search_incidents(_options inc_fn.search_incidents_options)
  RETURNS setof inc.incident
  LANGUAGE plpgsql
  stable
  SECURITY INVOKER
  AS $$
  DECLARE
  BEGIN
    return query select * from inc_fn.search_incidents(_options);
  end;
  $$;

CREATE OR REPLACE FUNCTION inc_fn.search_incidents(_options inc_fn.search_incidents_options)
  RETURNS setof inc.incident
  LANGUAGE plpgsql
  stable
  SECURITY INVOKER
  AS $$
  DECLARE
    _use_options inc_fn.search_incidents_options;
  BEGIN
    -- incident: add paging options

    return query
    select i.* 
    from inc.incident i
    where (
      _options.search_term is null 
      or i.name like '%'||_options.search_term||'%'
      or i.description like '%'||_options.search_term||'%'
    )
    and (_options.incident_status is null or i.status = _options.incident_status)
    and (i.is_template = coalesce(_options.is_template, false))  -- default is_template to false
    ;
  end;
  $$;

---------------------------------------------- templatize_incident
CREATE OR REPLACE FUNCTION inc_api.templatize_incident(
    _incident_id uuid
  )
  RETURNS inc.incident
  VOLATILE
  SECURITY INVOKER
  LANGUAGE plpgsql
  AS $function$
  DECLARE
    _template inc.incident;
  BEGIN
    _template := inc_fn.templatize_incident(_incident_id, auth_ext.resident_id()::uuid);
    return _template;
  end;
  $function$
  ;

CREATE OR REPLACE FUNCTION inc_fn.templatize_incident(
    _incident_id uuid
    ,_resident_id uuid
  )
  RETURNS inc.incident
  VOLATILE
  SECURITY INVOKER
  LANGUAGE plpgsql
  AS $function$
  DECLARE
    _template inc.incident;
    _incident inc.incident;
    _todo todo.todo;
  BEGIN

    select * into _incident from inc.incident where id = _incident_id;

    _template := inc_fn.create_incident(
      row(
        ('TEMPLATE: '||_incident.name)::citext
        ,_incident.description::citext
        ,null::citext
        ,'{}'::citext[]
        ,true::boolean
        ,'{}'::inc_fn.location_info[]
      )
      ,_resident_id
    );

    _todo := todo_fn.deep_copy_todo(
      _resident_id::uuid
      ,_incident.todo_id::uuid
      ,true
      ,null::uuid
    );

    update inc.incident set todo_id = _todo.id where id = _template.id;
    delete from todo.todo where id = _template.todo_id;

    select * into _template from inc.incident where id = _template.id;

    return _template;
  end;
  $function$
  ;

---------------------------------------------- clone_incident_template
CREATE OR REPLACE FUNCTION inc_api.clone_incident_template(
    _incident_id uuid
  )
  RETURNS inc.incident
  VOLATILE
  SECURITY INVOKER
  LANGUAGE plpgsql
  AS $function$
  DECLARE
    _clone inc.incident;
  BEGIN
    _clone := inc_fn.clone_incident_template(_incident_id, auth_ext.resident_id()::uuid);
    return _clone;
  end;
  $function$
  ;

CREATE OR REPLACE FUNCTION inc_fn.clone_incident_template(
    _incident_id uuid
    ,_resident_id uuid
  )
  RETURNS inc.incident
  VOLATILE
  SECURITY INVOKER
  LANGUAGE plpgsql
  AS $function$
  DECLARE
    _template inc.incident;
    _clone inc.incident;
    _todo todo.todo;
  BEGIN

    select * into _template from inc.incident where id = _incident_id;

    _clone := inc_fn.create_incident(
      row(
        ('CLONE FROM: '||_template.name)::citext
        ,_template.description::citext
        ,null::citext
        ,'{}'::citext[]
        ,false::boolean
        ,'{}'::inc_fn.location_info[]
      )
      ,_resident_id
    );

    _todo := todo_fn.deep_copy_todo(
      _resident_id::uuid
      ,_template.todo_id::uuid
      ,false
      ,null::uuid
    );

    update inc.incident set todo_id = _todo.id where id = _clone.id;
    delete from todo.todo where id = _clone.todo_id;

    select * into _clone from inc.incident where id = _clone.id;

    return _clone;
  end;
  $function$
  ;
---------------------------------------------- create_incident_location
CREATE OR REPLACE FUNCTION inc_api.create_incident_location(
    _incident_id uuid
    ,_location_info inc_fn.location_info
  )
  RETURNS inc.location
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $$
  DECLARE
    _retval inc.incident;
  BEGIN
    _retval := inc_fn.create_incident_location(
      _incident_id
      ,_location_info
    );
    return _retval;
  end;
  $$;

CREATE OR REPLACE FUNCTION inc_fn.create_incident_location(
    _incident_id uuid
    ,_location_info inc_fn.location_info
  )
  RETURNS inc.location
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $$
  DECLARE
    _incident inc.incident;
    _retval inc.location;
  BEGIN
    select * into _incident from inc.incident where id = _incident_id;

    insert into inc.location(
      incident_id,
      tenant_id,
      name,
      address1,
      address2,
      city,
      state,
      postalCode,
      country,
      lat,
      lon
    ) values (
      _incident.id,
      _incident.tenant_id,
      _location_info.name,
      _location_info.address1,
      _location_info.address2,
      _location_info.city,
      _location_info.state,
      _location_info.postalCode,
      _location_info.country,
      _location_info.lat,
      _location_info.lon
    )
    on conflict (incident_id, name) do nothing
    ;

    return _retval;
  end;
  $$;
---------------------------------------------- delete_incident_location
CREATE OR REPLACE FUNCTION inc_api.delete_incident_location(_location_id uuid)
  RETURNS boolean
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $$
  DECLARE
    _retval boolean;
  BEGIN
    _retval := inc_fn.delete_incident_location(_location_id);
    return _retval;
  end;
  $$;

CREATE OR REPLACE FUNCTION inc_fn.delete_incident_location(_location_id uuid)
  RETURNS boolean
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $$
  DECLARE
  BEGIN
    delete from inc.location where id = _location_id;
    return true;
  end;
  $$;



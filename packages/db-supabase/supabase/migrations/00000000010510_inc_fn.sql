create schema if not exists inc_api;
create schema if not exists inc_fn;

create type inc_fn.incident_info as (
  name citext
  ,description citext
  ,identifier citext
  ,tags citext[]
  ,is_template boolean
);
----------------------------------- install_anchor_application ---  NO API
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
        ,_incident_info.is_template
      )
      returning * into _incident;
    end if;

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
        ,updated_at = current_timestamp
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
    delete from inc.incident where id = _incident_id;
    return true;
  end;
  $$;

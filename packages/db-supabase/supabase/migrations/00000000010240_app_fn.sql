----------------------------------- install_application ---  NO API
CREATE OR REPLACE FUNCTION app_fn.install_application(_application_info app_fn.application_info)
  RETURNS app.application
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $function$
  DECLARE
    _application app.application;
    _license_pack app.license_pack;
    _license_type_info app_fn.license_type_info;
    _license_pack_license_type_info app_fn.license_pack_license_type_info;
    _license_pack_info app_fn.license_pack_info;
    _permission_key citext;
  BEGIN
    insert into app.application(
        key
        ,name
      ) values (
        _application_info.key::citext
        ,_application_info.name::citext
      )
      on conflict(key)
      do update set
        name = _application_info.name
      returning *
      into _application
      ;

    foreach _license_type_info in array(_application_info.license_type_infos)
    loop
      insert into app.license_type(
          application_key
          ,key
          ,display_name
          ,assignment_scope
        )
        values (
          _application_info.key
          ,_license_type_info.key
          ,_license_type_info.display_name
          ,_license_type_info.assignment_scope
        )
        on conflict(key)
        do nothing
        ;

      foreach _permission_key in array(_license_type_info.permissions)
      loop
        insert into app.permission(key)
          values (_permission_key)
          on conflict(key)
          do nothing
          ;

        insert into app.license_type_permission(license_type_key, permission_key)
          values
            (_license_type_info.key, _permission_key)
          on conflict(license_type_key, permission_key)
          do nothing
          ;
      end loop;
    end loop;

    foreach _license_pack_info in array(_application_info.license_pack_infos)
    loop
      insert into app.license_pack(key, display_name)
        values 
          (_license_pack_info.key, _license_pack_info.display_name)
        on conflict(key)
        do update set display_name = _license_pack_info.display_name
        returning * into _license_pack
        ;

      foreach _license_pack_license_type_info in array(_license_pack_info.license_pack_license_type_infos)
      loop
        insert into app.license_pack_license_type(
            license_pack_key
            ,license_type_key
            ,number_of_licenses
            ,expiration_interval_type
            ,expiration_interval_multiplier
          )
          values
            (
              _license_pack.key
              ,_license_pack_license_type_info.license_type_key
              ,_license_pack_license_type_info.number_of_licenses
              ,_license_pack_license_type_info.expiration_interval_type
              ,_license_pack_license_type_info.expiration_interval_multiplier
            )
          on conflict(license_pack_key, license_type_key)
          do nothing
          ;
      end loop;
    
    end loop;

    return _application;
  end;
  $function$
  ;

----------------------------------- install_anchor_application ---  NO API
CREATE OR REPLACE FUNCTION app_fn.install_anchor_application()
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
        'app'::citext
        ,'App'::citext
        ,array[
          row(
            'app-user'::citext
            ,'App User'::citext
            ,'{"p:app-user"}'::citext[]
            ,'user'::app.license_type_assignment_scope
          )::app_fn.license_type_info
          ,row(
            'app-admin'::citext
            ,'App Admin'::citext
            ,'{"p:app-admin"}'::citext[]
            ,'admin'::app.license_type_assignment_scope
          )::app_fn.license_type_info
          ,row(
            'app-admin-super'::citext
            ,'App Super Admin'::citext
            ,'{"p:app-admin-super","p:app-admin-support"}'::citext[]
            ,'superadmin'::app.license_type_assignment_scope
          )::app_fn.license_type_info
          ,row(
            'app-admin-support'::citext
            ,'App Support Admin'::citext
            ,'{"p:app-admin-support","p:app-admin"}'::citext[]
            ,'support'::app.license_type_assignment_scope
          )::app_fn.license_type_info
          ,row(
            'app-todo'::citext
            ,'Todo'::citext
            ,'{"p:todo"}'::citext[]
            ,'all'::app.license_type_assignment_scope
          )::app_fn.license_type_info
          ,row(
            'app-discussions'::citext
            ,'Discussions'::citext
            ,'{"p:discussions"}'::citext[]
            ,'all'::app.license_type_assignment_scope
          )::app_fn.license_type_info
          ,row(
            'app-address-book'::citext
            ,'Address Book'::citext
            ,'{"p:address-book"}'::citext[]
            ,'all'::app.license_type_assignment_scope
          )::app_fn.license_type_info
        ]::app_fn.license_type_info[]
        ,array[
          row(
            'anchor'::citext
            ,'Anchor'::citext
            ,array[
              row(
                'app-admin-super'::citext
                ,0::integer
                ,'none'::app.expiration_interval_type
                ,0::integer
              )::app_fn.license_pack_license_type_info
              ,row(
                'app-admin-support'::citext
                ,0::integer
                ,'none'::app.expiration_interval_type
                ,0::integer
              )::app_fn.license_pack_license_type_info
            ]::app_fn.license_pack_license_type_info[]
          )::app_fn.license_pack_info
          ,row(
            'app'::citext
            ,'App'::citext
            ,array[
              row(
                'app-user'::citext
                ,0::integer
                ,'none'::app.expiration_interval_type
                ,0::integer
              )::app_fn.license_pack_license_type_info
              ,row(
                'app-admin'::citext
                ,0::integer
                ,'none'::app.expiration_interval_type
                ,0::integer
              )::app_fn.license_pack_license_type_info
              ,row(
                'app-todo'::citext
                ,0::integer
                ,'none'::app.expiration_interval_type
                ,0::integer
              )::app_fn.license_pack_license_type_info
              ,row(
                'app-discussions'::citext
                ,0::integer
                ,'none'::app.expiration_interval_type
                ,0::integer
              )::app_fn.license_pack_license_type_info
              ,row(
                'app-address-book'::citext
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

----------------------------------- create_anchor_tenant ---  NO API
CREATE OR REPLACE FUNCTION app_fn.create_anchor_tenant(_name citext, _email citext default null)
  RETURNS app.app_tenant
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $function$
  DECLARE
    _application app.application;
    _app_tenant app.app_tenant;
  BEGIN
    select * into _app_tenant from app.app_tenant where type = 'anchor';
    if _app_tenant.id is null then
      _application := (select app_fn.install_anchor_application());
    --   -- create the app tenant
      insert into app.app_tenant(
        name
        ,identifier
        ,type
      ) values (
        _name
        ,'anchor'
        ,'anchor'
      ) returning * into _app_tenant
      ;

      perform app_fn.subscribe_tenant_to_license_pack(_app_tenant.id, 'anchor');
      perform app_fn.subscribe_tenant_to_license_pack(_app_tenant.id, 'app');

      perform app_fn.invite_user(_app_tenant.id, _email, 'superadmin');
    end if;
    
    return _app_tenant;
  end;
  $function$
  ;

----------------------------------- current_app_user_claims
CREATE OR REPLACE FUNCTION app_fn_api.current_app_user_claims()
  RETURNS app_fn.app_user_claims
  LANGUAGE plpgsql
  STABLE
  SECURITY INVOKER
  AS $function$
  DECLARE
    _app_user_claims app_fn.app_user_claims;
  BEGIN
    _app_user_claims = (select app_fn.current_app_user_claims(auth.uid()));
    return _app_user_claims;
  end;
  $function$
  ;

CREATE OR REPLACE FUNCTION app_fn.current_app_user_claims(_app_user_id uuid)
  RETURNS app_fn.app_user_claims
  LANGUAGE plpgsql
  STABLE
  SECURITY INVOKER
  AS $function$
  DECLARE
    _app_user app.app_user;
    _app_user_tenancy app.app_user_tenancy;
    _app_user_claims app_fn.app_user_claims;
  BEGIN
    select * into _app_user from app.app_user where id = _app_user_id;
    select * into _app_user_tenancy from app.app_user_tenancy where app_user_id = _app_user_id and status = 'active';

    _app_user_claims.email = _app_user.email;
    _app_user_claims.app_user_status = (select status from app.app_user where id = _app_user_id);
    if _app_user_tenancy.id is not null then
      _app_user_claims.display_name = _app_user_tenancy.display_name;
      _app_user_claims.app_user_id = _app_user_tenancy.app_user_id;
      _app_user_claims.app_tenant_id = _app_user_tenancy.app_tenant_id;
      _app_user_claims.app_tenant_name = _app_user_tenancy.app_tenant_name;
      _app_user_claims.app_user_tenancy_id = _app_user_tenancy.id;
      _app_user_claims.permissions = (
        select array_agg(ltp.permission_key) 
        from app.license_type_permission ltp 
        join app.license_type lt on lt.key = ltp.license_type_key
        join app.license l on l.license_type_key = lt.key
        where l.app_user_tenancy_id = _app_user_tenancy.id
      );
    else
      _app_user_claims.app_user_id = _app_user_id;
    end if;
    
    return _app_user_claims;
  end;
  $function$
  ;

----------------------------------- decline_invitation
CREATE OR REPLACE FUNCTION app_fn_api.decline_invitation(_app_user_tenancy_id uuid)
  RETURNS app.app_user_tenancy
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $function$
  DECLARE
    _app_user_tenancy app.app_user_tenancy;
  BEGIN
    _app_user_tenancy := app_fn.decline_invitation(_app_user_tenancy_id);
    return _app_user_tenancy;
  end;
  $function$
  ;

CREATE OR REPLACE FUNCTION app_fn.decline_invitation(_app_user_tenancy_id uuid)
  RETURNS app.app_user_tenancy
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $function$
  DECLARE
    _app_user_tenancy app.app_user_tenancy;
  BEGIN
    update app.app_user_tenancy set 
      status = 'declined'
      ,updated_at = current_timestamp 
    where id = _app_user_tenancy_id 
    returning * 
    into _app_user_tenancy;

    return _app_user_tenancy;
  end;
  $function$
  ;

----------------------------------- create_app_tenant
CREATE OR REPLACE FUNCTION app_fn_api.create_app_tenant(_name citext, _identifier citext default null, _email citext default null, _type app.app_tenant_type default 'customer'::app.app_tenant_type)
  RETURNS app.app_tenant
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $function$
  DECLARE
    _app_tenant app.app_tenant;
  BEGIN
    _app_tenant := app_fn.create_app_tenant(_name, _identifier, _email, _type);
    return _app_tenant;
  end;
  $function$
  ;

CREATE OR REPLACE FUNCTION app_fn.create_app_tenant(_name citext, _identifier citext default null, _email citext default null, _type app.app_tenant_type default 'customer'::app.app_tenant_type)
  RETURNS app.app_tenant
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $function$
  DECLARE
    _app_tenant app.app_tenant;
  BEGIN
    -- check for an existing tenant by this name
    select * into _app_tenant from app.app_tenant where name = _name or (_identifier is not null and identifier = _identifier);
    if _app_tenant.id is not null then
      raise exception '30002: APP TENANT WITH THIS NAME OR IDENTIFIER ALREADY EXISTS';
    end if;

    -- create the app tenant
    insert into app.app_tenant(
      name
      ,identifier
      ,type
    ) values (
      _name
      ,_identifier
      ,_type
    ) returning * into _app_tenant
    ;

    perform app_fn.subscribe_tenant_to_license_pack(_app_tenant.id, 'app');
    perform app_fn.invite_user(_app_tenant.id, _email, 'admin');

    return _app_tenant;
  end;
  $function$
  ;

----------------------------------- subscribe_tenant_to_license_pack
CREATE OR REPLACE FUNCTION app_fn_api.subscribe_tenant_to_license_pack(_app_tenant_id uuid, _license_pack_key citext)
  RETURNS app.app_tenant_subscription
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $function$
  DECLARE
    _app_tenant_subcription app.app_tenant_subscription;
  BEGIN
    _app_tenant_subcription := app_fn.subscribe_tenant_to_license_pack(_app_tenant_id, _license_pack_key);
    return _app_tenant_subcription;
  end;
  $function$
  ;

CREATE OR REPLACE FUNCTION app_fn.subscribe_tenant_to_license_pack(_app_tenant_id uuid, _license_pack_key citext)
  RETURNS app.app_tenant_subscription
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $function$
  DECLARE
    _app_tenant_subcription app.app_tenant_subscription;
    _app_user app.app_user;
    _app_user_tenancy app.app_user_tenancy;
    _license_pack_license_type app.license_pack_license_type;
    _license_type_key citext;
  BEGIN
    insert into app.app_tenant_subscription(
      app_tenant_id
      ,license_pack_key
    ) values (
      _app_tenant_id
      ,_license_pack_key
    )
    returning * into _app_tenant_subcription
    ;

    for _license_type_key in
      select lplt.license_type_key
        from app.license_pack_license_type lplt
        join app.license_type lt on lt.key = lplt.license_type_key
        where lplt.license_pack_key = _license_pack_key
        and lt.assignment_scope = 'admin'
    loop
      insert into app.license(
        app_tenant_id
        ,app_user_tenancy_id
        ,app_tenant_subscription_id
        ,license_type_key
      )
      select
        _app_tenant_id
        ,aut.id
        ,_app_tenant_subcription.id
        ,_license_type_key
      from app.app_user_tenancy aut
      join app.license l on l.app_user_tenancy_id = aut.id
      where l.license_type_key = 'app-admin'
      and l.app_tenant_id = _app_tenant_id
      on conflict (app_user_tenancy_id, license_type_key) DO UPDATE SET updated_at = EXCLUDED.updated_at
      ;
    end loop;
      
    return _app_tenant_subcription;
  end;
  $function$
  ;

----------------------------------- grant_user_license
CREATE OR REPLACE FUNCTION app_fn_api.grant_user_license(_app_user_tenancy_id uuid, _license_type_key citext)
  RETURNS app.license
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $function$
  DECLARE
    _license app.license;
  BEGIN
    if auth_ext.has_permission('p:app-admin') != true then raise exception '30000: NOT AUTHORIZED'; end if;

    _license := app_fn.grant_user_license(_app_user_tenancy_id, _license_type_key, auth_ext.app_user_tenancy_id());
    return _license;
  end;
  $function$
  ;

CREATE OR REPLACE FUNCTION app_fn.grant_user_license(_app_user_tenancy_id uuid, _license_type_key citext, _current_user_app_tenancy_id uuid)
  RETURNS app.license
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $function$
  DECLARE
    _app_tenant_subcription app.app_tenant_subscription;
    _app_user_tenancy app.app_user_tenancy;
    _license_pack app.license_type;
    _license app.license;
    _license_type app.license_type;
  BEGIN
    select aut.* into _app_user_tenancy from app.app_user_tenancy aut where id = _app_user_tenancy_id;

    select ats.* 
    into _app_tenant_subcription 
    from app.app_tenant_subscription ats 
    join app.license_pack lp on lp.key = ats.license_pack_key
    join app.license_pack_license_type lplt on lplt.license_pack_key = lp.key
    where ats.app_tenant_id = _app_user_tenancy.app_tenant_id
    and lplt.license_type_key = _license_type_key
        -- OPTIONAL TODO: check for license availablity
        -- here would go more filters to enforce license availability
        -- for now we just make a new license
        -- the lplt.number_of_licenses is meant to support this 
        -- (# = number purchased, 0 = unlimited, -1 = implied tenant-level license)
        -- really you can do whatever you would like
        -- even refactory this statement out into a more complex function
    ;
    
    select lp.* into _license_pack from app.license_pack lp where lp.key = _app_tenant_subcription.license_pack_key;
    select lt.* into _license_type from app.license_type lt where key = _license_type_key;

    -- if license type is scoped as ('superadmin', 'admin', 'support', 'user') then remove any other scoped
    -- licenses for this application
    -- users should only ever have one of these four license scopes per application
    if _license_type.assignment_scope in ('superadmin', 'admin', 'support', 'user') then
      if _current_user_app_tenancy_id = _app_user_tenancy.id then
        raise exception '30025: USERS CANNOT ALTER OWN SCOPE LICENSE STATUS';
      end if;

      delete from app.license l
      where l.app_user_tenancy_id = _app_user_tenancy.id
      and license_type_key in (
        select key from app.license_type where application_key = _license_type.application_key and assignment_scope in ('superadmin', 'admin', 'support', 'user')
      )
      ;
    end if;

    insert into app.license(
      app_tenant_id
      ,app_user_tenancy_id
      ,app_tenant_subscription_id
      ,license_type_key
    ) values (
      _app_user_tenancy.app_tenant_id
      ,_app_user_tenancy.id
      ,_app_tenant_subcription.id
      ,_license_type_key
    )
    on conflict (app_user_tenancy_id, license_type_key) do update set
      updated_at = current_timestamp
    returning * into _license;

    perform app_fn.configure_user_metadata(_app_user_tenancy.app_user_id);

    return _license;
  end;
  $function$
  ;
----------------------------------- revoke_user_license
CREATE OR REPLACE FUNCTION app_fn_api.revoke_user_license(_license_id uuid)
  RETURNS boolean
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $function$
  DECLARE
    _retval boolean;
  BEGIN
    if auth_ext.has_permission('p:app-admin') != true then raise exception '30000: NOT AUTHORIZED'; end if;

    _retval := app_fn.revoke_user_license(_license_id);
    return _retval;
  end;
  $function$
  ;

CREATE OR REPLACE FUNCTION app_fn.revoke_user_license(_license_id uuid)
  RETURNS boolean
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $function$
  DECLARE
    _license app.license;
  BEGIN
    select * into _license from app.license where id = _license_id;

    delete from app.license where id = _license_id;

    -- raise exception '%', _license.app_user_tenancy_id;
    perform app_fn.configure_user_metadata(app_user_id) from app.app_user_tenancy where id = _license.app_user_tenancy_id;

    return true;
  end;
  $function$
  ;

----------------------------------- block_app_user_tenancy
CREATE OR REPLACE FUNCTION app_fn_api.block_app_user_tenancy(_app_user_tenancy_id uuid)
  RETURNS app.app_user_tenancy
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $function$
  DECLARE
    _app_user_tenancy app.app_user_tenancy;
  BEGIN
    if auth_ext.has_permission('p:app-admin') != true then raise exception '30000: NOT AUTHORIZED'; end if;

    _app_user_tenancy := app_fn.block_app_user_tenancy(_app_user_tenancy_id);
    return _app_user_tenancy;
  end;
  $function$
  ;

CREATE OR REPLACE FUNCTION app_fn.block_app_user_tenancy(_app_user_tenancy_id uuid)
  RETURNS app.app_user_tenancy
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $function$
  DECLARE
    _app_user_tenancy app.app_user_tenancy;
  BEGIN
    update app.app_user_tenancy set status = 'blocked_individual' where id = _app_user_tenancy_id returning * into _app_user_tenancy;

    perform app_fn.configure_user_metadata(_app_user_tenancy.app_user_id);

    return _app_user_tenancy;
  end;
  $function$
  ;

----------------------------------- unblock_app_user_tenancy
CREATE OR REPLACE FUNCTION app_fn_api.unblock_app_user_tenancy(_app_user_tenancy_id uuid)
  RETURNS app.app_user_tenancy
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $function$
  DECLARE
    _app_user_tenancy app.app_user_tenancy;
  BEGIN
    if auth_ext.has_permission('p:app-admin') != true then raise exception '30000: NOT AUTHORIZED'; end if;

    _app_user_tenancy := app_fn.unblock_app_user_tenancy(_app_user_tenancy_id);
    return _app_user_tenancy;
  end;
  $function$
  ;

CREATE OR REPLACE FUNCTION app_fn.unblock_app_user_tenancy(_app_user_tenancy_id uuid)
  RETURNS app.app_user_tenancy
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $function$
  DECLARE
    _app_user_tenancy app.app_user_tenancy;
  BEGIN
    update app.app_user_tenancy set status = 'invited' where id = _app_user_tenancy_id returning * into _app_user_tenancy;

    if (
      select count(id) 
      from app.app_user_tenancy 
      where email = _app_user_tenancy.email 
      and id != _app_user_tenancy.id 
      and status = 'active'
    ) = 0 and _app_user_tenancy.app_user_id is not null then
      update app.app_user_tenancy set status = 'active' where id = _app_user_tenancy_id returning * into _app_user_tenancy;
      perform app_fn.configure_user_metadata(_app_user_tenancy.app_user_id);
    end if;

    return _app_user_tenancy;
  end;
  $function$
  ;
----------------------------------- deactivate_app_tenant
CREATE OR REPLACE FUNCTION app_fn_api.deactivate_app_tenant(_app_tenant_id uuid)
  RETURNS app.app_tenant
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $function$
  DECLARE
    _app_tenant app.app_tenant;
  BEGIN
    if auth_ext.has_permission('p:app-admin-super') != true then raise exception '30000: NOT AUTHORIZED'; end if;

    _app_tenant := app_fn.deactivate_app_tenant(_app_tenant_id);
    return _app_tenant;
  end;
  $function$
  ;

CREATE OR REPLACE FUNCTION app_fn.deactivate_app_tenant(_app_tenant_id uuid)
  RETURNS app.app_tenant
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $function$
  DECLARE
    _app_tenant app.app_tenant;
    _active_user_tenancy_ids uuid[];
  BEGIN
    select array_agg(aut.id) into _active_user_tenancy_ids from app.app_user_tenancy aut where app_tenant_id = _app_tenant_id and status = 'active';

    update app.app_tenant set status = 'inactive' where id = _app_tenant_id;
    update app.app_user_tenancy set status = 'blocked_tenant' where app_tenant_id = _app_tenant_id and status in ('invited', 'active', 'inactive');

    perform app_fn.configure_user_metadata(aut.id) from app.app_user_tenancy aut where id = any(_active_user_tenancy_ids);

    return _app_tenant;
  end;
  $function$
  ;

----------------------------------- activate_app_tenant
CREATE OR REPLACE FUNCTION app_fn_api.activate_app_tenant(_app_tenant_id uuid)
  RETURNS app.app_tenant
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $function$
  DECLARE
    _app_tenant app.app_tenant;
  BEGIN
    if auth_ext.has_permission('p:app-admin-super') != true then raise exception '30000: NOT AUTHORIZED'; end if;

    _app_tenant := app_fn.activate_app_tenant(_app_tenant_id);
    return _app_tenant;
  end;
  $function$
  ;

CREATE OR REPLACE FUNCTION app_fn.activate_app_tenant(_app_tenant_id uuid)
  RETURNS app.app_tenant
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $function$
  DECLARE
    _app_tenant app.app_tenant;
  BEGIN
    update app.app_tenant set status = 'active' where id = _app_tenant_id;
    update app.app_user_tenancy 
      set status = 'inactive' 
    where app_tenant_id = _app_tenant_id 
    and status in ('blocked_tenant')
    and app_user_id is not null
    ;

    update app.app_user_tenancy 
      set status = 'invited' 
    where app_tenant_id = _app_tenant_id 
    and status in ('blocked_tenant')
    and app_user_id is null
    ;

    return _app_tenant;
  end;
  $function$
  ;


---------------------------------------------------------------------- queries

----------------------------------- my_app_user_tenancies
CREATE OR REPLACE FUNCTION app_fn_api.my_app_user_tenancies()
  RETURNS setof app.app_user_tenancy
  LANGUAGE plpgsql
  STABLE
  SECURITY INVOKER
  AS $function$
  DECLARE
    
  BEGIN
    return query select * from app_fn.my_app_user_tenancies(auth_ext.email());
  end;
  $function$
  ;

CREATE OR REPLACE FUNCTION app_fn.my_app_user_tenancies(_email text)
  RETURNS setof app.app_user_tenancy
  LANGUAGE plpgsql
  STABLE
  SECURITY INVOKER
  AS $function$
  DECLARE
    
  BEGIN
    return query
    select aut.*
    from app.app_user_tenancy aut
    where email = _email
    ;
  end;
  $function$
  ;

----------------------------------- app_tenant_app_user_tenancies
CREATE OR REPLACE FUNCTION app_fn_api.app_tenant_app_user_tenancies()
  RETURNS setof app.app_user_tenancy
  LANGUAGE plpgsql
  STABLE
  SECURITY INVOKER
  AS $function$
  DECLARE
    
  BEGIN
    -- raise exception 'blah %', auth_ext.app_tenant_id();
    return query select * from app_fn.app_tenant_app_user_tenancies(auth_ext.app_tenant_id());
  end;
  $function$
  ;

CREATE OR REPLACE FUNCTION app_fn.app_tenant_app_user_tenancies(_app_tenant_id uuid)
  RETURNS setof app.app_user_tenancy
  LANGUAGE plpgsql
  STABLE
  SECURITY INVOKER
  AS $function$
  DECLARE
    
  BEGIN
    return query
    select distinct aut.*
    from app.app_user_tenancy aut
    where aut.app_tenant_id = _app_tenant_id
    and not exists(
      select l.id from app.license l where app_user_tenancy_id = aut.id and l.license_type_key = 'app-admin-support'
    )
    ;
  end;
  $function$
  ;

----------------------------------- app_tenant_licenses
CREATE OR REPLACE FUNCTION app_fn_api.app_tenant_licenses()
  RETURNS setof app.license
  LANGUAGE plpgsql
  STABLE
  SECURITY INVOKER
  AS $function$
  DECLARE
    
  BEGIN
    return query select * from app_fn.app_tenant_licenses(auth_ext.app_tenant_id());
  end;
  $function$
  ;

CREATE OR REPLACE FUNCTION app_fn.app_tenant_licenses(_app_tenant_id uuid)
  RETURNS setof app.license
  LANGUAGE plpgsql
  STABLE
  SECURITY INVOKER
  AS $function$
  DECLARE
    
  BEGIN
    return query
    select l.*
    from app.license l
    where l.license_Type_key != 'app-admin-support'
    and app_tenant_id = _app_tenant_id
    and not exists (
      select id from app.license where app_user_tenancy_id = l.app_user_tenancy_id and license_type_key = 'app-admin-support'
    )
    ;
  end;
  $function$
  ;

----------------------------------------------------------------- join_address_book
CREATE OR REPLACE FUNCTION app_fn_api.join_address_book()
  RETURNS app.app_user
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $$
  DECLARE
    _app_user app.app_user;
  BEGIN
    _app_user := app_fn.join_address_book(auth.uid());
    return _app_user;
  end;
  $$;  

CREATE OR REPLACE FUNCTION app_fn.join_address_book(_app_user_id uuid)
  RETURNS app.app_user
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $$
  DECLARE
    _app_user app.app_user;
  BEGIN
    -- raise notice '_app_user_id: %', _app_user_id;
    -- raise notice 'email: %', (select email from app.app_user where id = _app_user_id);
    
    update app.app_user set
      is_public = true
    where id = _app_user_id
    returning *
    into _app_user
    ;

    -- raise notice '_app_user: %', _app_user;

    return _app_user;
  end;
  $$;  
----------------------------------------------------------------- get_ab_listings
CREATE OR REPLACE FUNCTION app_fn_api.get_ab_listings(_app_user_id uuid)
  RETURNS SETOF app_fn.ab_listing
  LANGUAGE plpgsql
  STABLE
  SECURITY INVOKER
  AS $$
  DECLARE
  BEGIN
    return query select * from app_fn.get_ab_listings(auth.uid(), auth_ext.app_tenant_id());
  end;
  $$;  
----------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION app_fn.get_ab_listings(_app_user_id uuid, _user_app_tenant_id uuid)
  RETURNS SETOF app_fn.ab_listing
  LANGUAGE plpgsql
  STABLE
  SECURITY INVOKER
  AS $$
  DECLARE
    _can_invite boolean;
  BEGIN
    _can_invite := auth_ext.has_permission('p:app-admin');

    return query
      select 
        u.id as app_user_id
        ,u.email
        ,u.phone
        ,u.full_name
        ,u.display_name
        ,(
          select _can_invite 
          and (u.id != _app_user_id)
          and not exists (select id from app.app_user_tenancy where app_tenant_id = _user_app_tenant_id and app_user_id = u.id)
        ) as _can_invite
      from app.app_user u
      where is_public = true
      and exists(select id from app.app_user where id = _app_user_id and is_public = true)
      ;
  end;
  $$;  
----------------------------------------------------------------- leave_address_book
CREATE OR REPLACE FUNCTION app_fn_api.leave_address_book()
  RETURNS app.app_user
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $$
  DECLARE
    _app_user app.app_user;
  BEGIN
    _app_user := app_fn.leave_address_book(auth.uid());
    return _app_user;
  end;
  $$;  

CREATE OR REPLACE FUNCTION app_fn.leave_address_book(_app_user_id uuid)
  RETURNS app.app_user
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $$
  DECLARE
    _app_user app.app_user;
  BEGIN
    update app.app_user set
      is_public = false
    where id = _app_user_id
    returning *
    into _app_user
    ;

    return _app_user;
  end;
  $$;  
----------------------------------------------------------------- get_myself ---  API ONLY
CREATE OR REPLACE FUNCTION app_fn_api.get_myself()
  RETURNS app.app_user
  LANGUAGE plpgsql
  STABLE
  SECURITY INVOKER
  AS $$
  DECLARE
    _app_user app.app_user;
  BEGIN
    select * into _app_user from app.app_user where id = auth.uid();
    return _app_user;
  end;
  $$;  

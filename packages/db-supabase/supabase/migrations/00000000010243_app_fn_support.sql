----------------------------------------------------------------- become_support
CREATE OR REPLACE FUNCTION app_api.become_support(_tenant_id uuid)
  RETURNS app.resident
  LANGUAGE plpgsql
  VOLATILE
  SECURITY DEFINER
  AS $$
  DECLARE
    _resident app.resident;
  BEGIN
    if 
      auth_ext.has_permission('p:app-admin-super') = false 
      and
      auth_ext.has_permission('p:app-admin-support') = false 
    then
      raise exception '30000: PERMISSION DENIED';
    end if;

    _resident := (select app_fn.become_support(_tenant_id, auth.uid()));
    return _resident;
  end;
  $$;  

CREATE OR REPLACE FUNCTION app_fn.become_support(_tenant_id uuid, _profile_id uuid)
  RETURNS app.resident
  LANGUAGE plpgsql
  VOLATILE
  SECURITY DEFINER
  AS $$
  DECLARE
    _tenant app.tenant;
    _resident app.resident;
    _actual_resident app.resident;
    _support_email citext;
    _support_display_name citext;
  BEGIN
      select * into _tenant from app.tenant where id = _tenant_id;

      update app.resident set status = 'supporting' 
      where profile_id = _profile_id and status = 'active'
      returning * into _actual_resident;

      select coalesce(value, 'support@example.com') into _support_email from app.app_settings where key = 'support-email' and application_key = 'app';
      select coalesce(value, 'Site Support') into _support_display_name from app.app_settings where key = 'support-display-name' and application_key = 'app';

      insert into app.resident(
        tenant_id
        ,profile_id
        ,tenant_name
        ,email
        ,display_name
        ,status
        ,type
      ) values (
        _tenant.id
        ,_profile_id
        ,_tenant.name
        ,_support_email
        ,_support_display_name
        ,'active'
        ,'support'::app.resident_type
      )
      on conflict(tenant_id, profile_id) do update
        set status = 'active'
      returning * into _resident
      ;

      insert into app.license(
        tenant_id
        ,resident_id
        ,tenant_subscription_id
        ,license_type_key
      )
      values (
        _resident.tenant_id
        ,_resident.id
        ,(select id from app.tenant_subscription where tenant_id = _resident.tenant_id limit 1)
        ,'app-admin-support'
      )
      on conflict (resident_id, license_type_key) DO NOTHING
      -- on conflict (resident_id, license_type_key) DO UPDATE SET updated_at = current_timestamp
      ;

      insert into app.license(
        tenant_id
        ,resident_id
        ,tenant_subscription_id
        ,license_type_key
      )
      select
        _resident.tenant_id
        ,_resident.id
        ,ats.id
        ,lplt.license_type_key
      from app.tenant_subscription ats
      join app.license_pack lp on lp.key = ats.license_pack_key
      join app.license_pack_license_type lplt on lplt.license_pack_key = lp.key
      join app.license_type lt on lt.key = lplt.license_type_key
      where ats.tenant_id = _resident.tenant_id
      and lt.assignment_scope in ('admin', 'all', 'none') -- this is a super special rule only for support users
      and not exists (
        select id from app.license
        where resident_id = _resident.id
        and license_type_key = lplt.license_type_key
      )
      on conflict (resident_id, license_type_key) DO NOTHING
      ;

      perform app_fn.configure_user_metadata(_resident.profile_id, _actual_resident.id);

    return _resident;
  end;
  $$;  
----------------------------------------------------------------- exit_support_mode
CREATE OR REPLACE FUNCTION app_api.exit_support_mode()
  RETURNS app.resident
  LANGUAGE plpgsql
  VOLATILE
  SECURITY DEFINER
  AS $$
  DECLARE
    _resident app.resident;
  BEGIN
    if auth_ext.has_permission('p:app-admin-support') = false then
      raise exception '30000: PERMISSION DENIED';
    end if;

    _resident := (select app_fn.exit_support_mode(auth_ext.resident_id(), auth_ext.actual_resident_id()));
    return _resident;
  end;
  $$;  

CREATE OR REPLACE FUNCTION app_fn.exit_support_mode(_support_resident_id uuid, _actual_resident uuid)
  RETURNS app.resident
  LANGUAGE plpgsql
  VOLATILE
  SECURITY DEFINER
  AS $$
  DECLARE
    _resident app.resident;
  BEGIN
    update app.resident set status = 'inactive' where id = _support_resident_id;
    _resident := (select app_fn.assume_residency(id::uuid, email::citext) from app.resident where id = _actual_resident);

    return _resident;
  end;
  $$;  
----------------------------------- deactivate_tenant
CREATE OR REPLACE FUNCTION app_api.deactivate_tenant(_tenant_id uuid)
  RETURNS app.tenant
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $function$
  DECLARE
    _tenant app.tenant;
  BEGIN
    if auth_ext.has_permission('p:app-admin-super') != true then raise exception '30000: NOT AUTHORIZED'; end if;

    _tenant := app_fn.deactivate_tenant(_tenant_id);
    return _tenant;
  end;
  $function$
  ;

CREATE OR REPLACE FUNCTION app_fn.deactivate_tenant(_tenant_id uuid)
  RETURNS app.tenant
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $function$
  DECLARE
    _tenant app.tenant;
    _active_resident_ids uuid[];
  BEGIN
    select array_agg(aut.id) into _active_resident_ids from app.resident aut where tenant_id = _tenant_id and status = 'active';

    update app.tenant set status = 'inactive' where id = _tenant_id;
    update app.resident set status = 'blocked_tenant' where tenant_id = _tenant_id and status in ('invited', 'active', 'inactive');

    perform app_fn.configure_user_metadata(aut.id) from app.resident aut where id = any(_active_resident_ids);

    return _tenant;
  end;
  $function$
  ;

----------------------------------- activate_tenant
CREATE OR REPLACE FUNCTION app_api.activate_tenant(_tenant_id uuid)
  RETURNS app.tenant
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $function$
  DECLARE
    _tenant app.tenant;
  BEGIN
    if auth_ext.has_permission('p:app-admin-super') != true then raise exception '30000: NOT AUTHORIZED'; end if;

    _tenant := app_fn.activate_tenant(_tenant_id);
    return _tenant;
  end;
  $function$
  ;

CREATE OR REPLACE FUNCTION app_fn.activate_tenant(_tenant_id uuid)
  RETURNS app.tenant
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $function$
  DECLARE
    _tenant app.tenant;
  BEGIN
    update app.tenant set status = 'active' where id = _tenant_id;
    update app.resident 
      set status = 'inactive' 
    where tenant_id = _tenant_id 
    and status in ('blocked_tenant')
    and profile_id is not null
    ;

    update app.resident 
      set status = 'invited' 
    where tenant_id = _tenant_id 
    and status in ('blocked_tenant')
    and profile_id is null
    ;

    return _tenant;
  end;
  $function$
  ;
----------------------------------------------------------------- tenants_for_support ---  API ONLY
-- CREATE OR REPLACE FUNCTION app_api.tenants_for_support()
--   RETURNS setof app.tenant
--   LANGUAGE plpgsql
--   STABLE
--   SECURITY DEFINER
--   AS $$
--   DECLARE
--   BEGIN
--     if auth_ext.has_permission('p:app-admin-support') != true then 
--       raise exception '30000: NOT AUTHORIZED'; 
--     end if;

--     return query
--     select 
--       *
--     from app.tenant t
--     where type != 'anchor'
--     ;
--   end;
--   $$;
---------------------------------------------- search_residents
  CREATE OR REPLACE FUNCTION app_api.search_residents(_options app_fn.search_residents_options)
    RETURNS setof app.resident
    LANGUAGE plpgsql
    stable
    SECURITY DEFINER
    AS $$
    DECLARE
    BEGIN
      if auth_ext.has_permission('p:app-admin-support') != true then 
        raise exception '30000: NOT AUTHORIZED'; 
      end if;

      return query select * from app_fn.search_residents(_options);
    end;
    $$;

  CREATE OR REPLACE FUNCTION app_fn.search_residents(_options app_fn.search_residents_options)
    RETURNS setof app.resident
    LANGUAGE plpgsql
    stable
    SECURITY DEFINER
    AS $$
    DECLARE
      _use_options app_fn.search_residents_options;
    BEGIN
      -- resident: add paging options

      return query
      select r.* 
      from app.resident r
      join app.tenant a on a.id = r.tenant_id
      where (
        _options.search_term is null 
        or r.email like '%'||_options.search_term||'%'
        or r.tenant_name like '%'||_options.search_term||'%'
        or r.display_name like '%'||_options.search_term||'%'
      )
      and (_options.status is null or r.status = _options.status)
      and r.type != 'support'
      and a.type != 'anchor'
      ;
    end;
    $$;
---------------------------------------------- search_profiles
  CREATE OR REPLACE FUNCTION app_api.search_profiles(_options app_fn.search_profiles_options)
    RETURNS setof app.profile
    LANGUAGE plpgsql
    stable
    SECURITY DEFINER
    AS $$
    DECLARE
    BEGIN
      if auth_ext.has_permission('p:app-admin-support') != true then 
        raise exception '30000: NOT AUTHORIZED'; 
      end if;

      return query select * from app_fn.search_profiles(_options);
    end;
    $$;

  CREATE OR REPLACE FUNCTION app_fn.search_profiles(_options app_fn.search_profiles_options)
    RETURNS setof app.profile
    LANGUAGE plpgsql
    stable
    SECURITY DEFINER
    AS $$
    DECLARE
      _use_options app_fn.search_profiles_options;
    BEGIN
      -- profile: add paging options

      return query
      select p.* 
      from app.profile p
      where (
        _options.search_term is null 
        or p.email like '%'||_options.search_term||'%'
        or p.display_name like '%'||_options.search_term||'%'
      )
      ;
    end;
    $$;


---------------------------------------------- search_tenants
  CREATE OR REPLACE FUNCTION app_api.search_tenants(_options app_fn.search_tenants_options)
    RETURNS setof app.tenant
    LANGUAGE plpgsql
    stable
    SECURITY DEFINER
    AS $$
    DECLARE
    BEGIN
      if auth_ext.has_permission('p:app-admin-support') != true then 
        raise exception '30000: NOT AUTHORIZED'; 
      end if;

      return query select * from app_fn.search_tenants(_options);
    end;
    $$;

  CREATE OR REPLACE FUNCTION app_fn.search_tenants(_options app_fn.search_tenants_options)
    RETURNS setof app.tenant
    LANGUAGE plpgsql
    stable
    SECURITY DEFINER
    AS $$
    DECLARE
      _use_options app_fn.search_tenants_options;
    BEGIN
      -- profile: add paging options

      return query
      select t.* 
      from app.tenant t
      where (
        _options.search_term is null 
        or t.name like '%'||_options.search_term||'%'
        or t.identifier like '%'||_options.search_term||'%'
      )
      and (_options.status is null or t.status = _options.status)
      and (_options.type is null or t.type = _options.type)
      and type != 'anchor'
      ;
    end;
    $$;


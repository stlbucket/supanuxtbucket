----------------------------------------------------------------- configure_user_metadata ---  NO API
CREATE OR REPLACE FUNCTION app_fn.configure_user_metadata(_app_user_id uuid, _actual_app_user_tenancy uuid default null)
  RETURNS void
  LANGUAGE plpgsql
  VOLATILE
  SECURITY DEFINER
  AS $$
  DECLARE
    _app_user_claims app_fn.app_user_claims;
  BEGIN
    _app_user_claims := app_fn.current_app_user_claims(_app_user_id);
    _app_user_claims.actual_app_user_tenancy_id = _actual_app_user_tenancy;

    -- here and app_fn.handle_new_user should be the only places where auth.users are updated
    update auth.users set
      raw_user_meta_data = (select to_jsonb(_app_user_claims))
    where id = _app_user_id
    ;
  end;
  $$;  
----------------------------------- handle_new_user ---  NO API
create or replace function app_fn.handle_new_user()
  returns trigger
  language plpgsql
  security definer
  as $$
  DECLARE
    _app_user_tenancy app.app_user_tenancy;
  begin
    insert into app.app_user (id, email, display_name)
    values (new.id, new.email, split_part(new.email, '@', 1));

    update app.app_user_tenancy set
      app_user_id = new.id
      ,status = 'active'
    where email = new.email
    and status != 'blocked_individual'
    and status != 'blocked_tenant'
    ;

    select * into _app_user_tenancy from app.app_user_tenancy where app_user_id = new.id and status = 'active' limit 1;

    -- this has to happen directly because this is inside a trigger
    update auth.users set 
      raw_user_meta_data = (select to_jsonb(app_fn.current_app_user_claims(_app_user_tenancy.app_user_id)))
    where id = _app_user_tenancy.app_user_id
    ;

    return new;
  end;
  $$;
  -- trigger the function every time a user is created
create or replace trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure app_fn.handle_new_user();
----------------------------------- assume_app_user_tenancy
CREATE OR REPLACE FUNCTION app_fn_api.assume_app_user_tenancy(_app_user_tenancy_id uuid)
  RETURNS app.app_user_tenancy
  LANGUAGE plpgsql
  VOLATILE
  SECURITY DEFINER
  AS $function$
  DECLARE
    _app_user_tenancy app.app_user_tenancy;
  BEGIN
    _app_user_tenancy := app_fn.assume_app_user_tenancy(_app_user_tenancy_id, auth_ext.email());
    return _app_user_tenancy;
  end;
  $function$
  ;

CREATE OR REPLACE FUNCTION app_fn.assume_app_user_tenancy(_app_user_tenancy_id uuid, _email citext)
  RETURNS app.app_user_tenancy
  LANGUAGE plpgsql
  VOLATILE
  SECURITY DEFINER
  AS $function$
  DECLARE
    _app_user_tenancy app.app_user_tenancy;
  BEGIN
    select * into _app_user_tenancy from app.app_user_tenancy where id = _app_user_tenancy_id and email = _email;
    -- raise exception '%', _app_user_tenancy;

    if _app_user_tenancy.id is not null then
      update app.app_user_tenancy set 
        status = 'inactive' 
        ,updated_at = current_timestamp 
      where app_user_id = _app_user_tenancy.app_user_id
      and status in ('active', 'supporting')
      and id != _app_user_tenancy_id 
      ;

      update app.app_user_tenancy set 
        status = 'active' 
        ,updated_at = current_timestamp 
      where id = _app_user_tenancy_id
      returning * 
      into _app_user_tenancy;

      perform app_fn.configure_user_metadata(_app_user_tenancy.app_user_id);
    end if;

    return _app_user_tenancy;
  end;
  $function$
  ;

----------------------------------- update_profile
CREATE OR REPLACE FUNCTION app_fn_api.update_profile(
    _display_name citext
    ,_first_name citext
    ,_last_name citext
    ,_phone citext default null
  )
  RETURNS app.app_user
  LANGUAGE plpgsql
  VOLATILE
  SECURITY DEFINER
  AS $function$
  DECLARE
    _app_user app.app_user;
  BEGIN
    _app_user := app_fn.update_profile(
      auth.uid()
      ,_display_name
      ,_first_name
      ,_last_name
      ,_phone
    );
    return _app_user;
  end;
  $function$
  ;

CREATE OR REPLACE FUNCTION app_fn.update_profile(
    _app_user_id uuid
    ,_display_name citext
    ,_first_name citext
    ,_last_name citext
    ,_phone citext default null
  )
  RETURNS app.app_user
  LANGUAGE plpgsql
  VOLATILE
  SECURITY DEFINER
  AS $function$
  DECLARE
    _app_user app.app_user;
  BEGIN
    update app.app_user_tenancy set 
      display_name = _display_name
      ,updated_at = current_timestamp 
    where app_user_id = _app_user_id
    ;

    update app.app_user set 
      display_name = _display_name
      ,first_name = _first_name
      ,last_name = _last_name
      ,phone = _phone
      ,updated_at = current_timestamp 
    where id = _app_user_id
    returning * 
    into _app_user;

    perform app_fn.configure_user_metadata(_app_user.id);

    return _app_user;
  end;
  $function$
  ;

----------------------------------- invite_user
CREATE OR REPLACE FUNCTION app_fn_api.invite_user(_email citext)
  RETURNS app.app_user_tenancy
  LANGUAGE plpgsql
  VOLATILE
  SECURITY DEFINER
  AS $function$
  DECLARE
    _app_user app.app_user;
    _app_user_tenancy app.app_user_tenancy;
  BEGIN
    -- this function invites a user to the same tenant as the current user
    -- can only be called by user with app-admin license or better.

    if auth_ext.has_permission('p:app-admin') = false then
      raise exception '30000: UNAUTHORIZED';
    end if;

    select * into _app_user_tenancy 
    from app.app_user_tenancy 
    where app_user_id = auth.uid() 
    and status = 'active'
    ;

    _app_user_tenancy = (select app_fn.invite_user(_app_user_tenancy.app_tenant_id, _email));

    return _app_user_tenancy;
  end;
  $function$
  ;

CREATE OR REPLACE FUNCTION app_fn.invite_user(
    _app_tenant_id uuid
    ,_email citext
    ,_assignment_scope app.license_type_assignment_scope default 'user'
  )
  RETURNS app.app_user_tenancy
  LANGUAGE plpgsql
  VOLATILE
  SECURITY DEFINER
          -- security definer to allow for select of app.app_user from other tenants
          -- this would allow for one tenant to know if a user at an email were on
          -- the platform - though the other would know that they know.  so it would
          -- all be known knowns and no unknown unknowns.  -- donny r
  AS $function$
  DECLARE
    _app_user app.app_user;
    _app_user_tenancy app.app_user_tenancy;
    _app_tenant app.app_tenant;
    _license_pack_license_type app.license_pack_license_type;
    _license_type_key citext;
    _app_tenant_subscription_id uuid;
  BEGIN    
    -- find existing records for app_user and tenancy
    select * into _app_user from app.app_user where email = _email;
    select * into _app_user_tenancy from app.app_user_tenancy where email = _email and app_tenant_id = _app_tenant_id;
    select * into _app_tenant from app.app_tenant where id = _app_tenant_id;

    if _app_user_tenancy.id is null then
      insert into app.app_user_tenancy(
        app_tenant_id
        ,app_tenant_name
        ,email
        ,display_name
      ) values (
        _app_tenant.id
        ,_app_tenant.name
        ,_email
        ,coalesce(_app_user.display_name, split_part(_email,'@',1))
      ) 
      returning * into _app_user_tenancy;

      -- grant all licenses at the specified assignment scope
      for _license_type_key, _app_tenant_subscription_id in
        select lplt.license_type_key, ats.id
          from app.license_pack_license_type lplt
          join app.license_type lt on lt.key = lplt.license_type_key
          join app.license_pack lp on lp.key = lplt.license_pack_key
          join app.app_tenant_subscription ats on ats.license_pack_key = lp.key
          where ats.app_tenant_id = _app_tenant_id
          and (lt.assignment_scope = _assignment_scope or lt.assignment_scope = 'all')
      loop
        insert into app.license(
          app_tenant_id
          ,app_user_tenancy_id
          ,app_tenant_subscription_id
          ,license_type_key
        )
        values (
          _app_tenant_id
          ,_app_user_tenancy.id
          ,_app_tenant_subscription_id
          ,_license_type_key
        )
        on conflict (app_user_tenancy_id, license_type_key) DO UPDATE SET updated_at = EXCLUDED.updated_at
        ;
      end loop;
    end if;
    
    -- attach tenancy to any existing user
    if _app_user.id is not null then
      update app.app_user_tenancy set app_user_id = _app_user.id where id = _app_user_tenancy.id returning * into _app_user_tenancy;
    end if;

    return _app_user_tenancy;
  end;
  $function$
  ;

----------------------------------- demo_app_user_tenancies
CREATE OR REPLACE FUNCTION app_fn_api.demo_app_user_tenancies()
  RETURNS setof app.app_user_tenancy
  LANGUAGE plpgsql
  STABLE
  SECURITY DEFINER
  AS $function$
  DECLARE
  BEGIN
    return query select * from app_fn.demo_app_user_tenancies();
  end;
  $function$
  ;

CREATE OR REPLACE FUNCTION app_fn.demo_app_user_tenancies()
  RETURNS setof app.app_user_tenancy
  LANGUAGE plpgsql
  STABLE
  SECURITY DEFINER
  AS $function$
  DECLARE
  BEGIN
    return query
    select distinct
      aut.*
    from app.app_user_tenancy aut
    join app.app_tenant t on t.id = aut.app_tenant_id
    where (t.type = 'demo' or t.type = 'anchor')
    and aut.display_name != 'Site Support'
    ;
  end;
  $function$
  ;
----------------------------------------------------------------- become_support
CREATE OR REPLACE FUNCTION app_fn_api.become_support(_app_tenant_id uuid)
  RETURNS app.app_user_tenancy
  LANGUAGE plpgsql
  VOLATILE
  SECURITY DEFINER
  AS $$
  DECLARE
    _app_user_tenancy app.app_user_tenancy;
  BEGIN
    if auth_ext.has_permission('p:app-admin-support') = false then
      raise exception '30000: PERMISSION DENIED';
    end if;

    _app_user_tenancy := (select app_fn.become_support(_app_tenant_id, auth.uid()));
    return _app_user_tenancy;
  end;
  $$;  

CREATE OR REPLACE FUNCTION app_fn.become_support(_app_tenant_id uuid, _app_user_id uuid)
  RETURNS app.app_user_tenancy
  LANGUAGE plpgsql
  VOLATILE
  SECURITY DEFINER
  AS $$
  DECLARE
    _app_tenant app.app_tenant;
    _app_user_tenancy app.app_user_tenancy;
    _actual_app_user_tenancy app.app_user_tenancy;
    _support_email citext;
    _support_display_name citext;
  BEGIN
      select * into _app_tenant from app.app_tenant where id = _app_tenant_id;

      update app.app_user_tenancy set status = 'supporting' 
      where app_user_id = _app_user_id and status = 'active'
      returning * into _actual_app_user_tenancy;

      select coalesce(value, 'support@example.com') into _support_email from app.app_settings where key = 'support-email' and application_key = 'app';
      select coalesce(value, 'Site Support') into _support_display_name from app.app_settings where key = 'support-display-name' and application_key = 'app';

      insert into app.app_user_tenancy(
        app_tenant_id
        ,app_user_id
        ,app_tenant_name
        ,email
        ,display_name
        ,status
      ) values (
        _app_tenant.id
        ,_app_user_id
        ,_app_tenant.name
        ,_support_email
        ,_support_display_name
        ,'active'
      )
      on conflict(app_tenant_id, app_user_id) do update
        set status = 'active'
      returning * into _app_user_tenancy
      ;

      insert into app.license(
        app_tenant_id
        ,app_user_tenancy_id
        ,app_tenant_subscription_id
        ,license_type_key
      )
      values (
        _app_user_tenancy.app_tenant_id
        ,_app_user_tenancy.id
        ,(select id from app.app_tenant_subscription where app_tenant_id = _app_user_tenancy.app_tenant_id limit 1)
        ,'app-admin-support'
      )
      on conflict (app_user_tenancy_id, license_type_key) DO NOTHING
      -- on conflict (app_user_tenancy_id, license_type_key) DO UPDATE SET updated_at = current_timestamp
      ;

      insert into app.license(
        app_tenant_id
        ,app_user_tenancy_id
        ,app_tenant_subscription_id
        ,license_type_key
      )
      select
        _app_user_tenancy.app_tenant_id
        ,_app_user_tenancy.id
        ,ats.id
        ,lplt.license_type_key
      from app.app_tenant_subscription ats
      join app.license_pack lp on lp.key = ats.license_pack_key
      join app.license_pack_license_type lplt on lplt.license_pack_key = lp.key
      join app.license_type lt on lt.key = lplt.license_type_key
      where ats.app_tenant_id = _app_user_tenancy.app_tenant_id
      and lt.assignment_scope in ('admin', 'all', 'none') -- this is a super special rule only for support users
      and not exists (
        select id from app.license
        where app_user_tenancy_id = _app_user_tenancy.id
        and license_type_key = lplt.license_Type_key
      )
      on conflict (app_user_tenancy_id, license_type_key) DO NOTHING
      ;

      perform app_fn.configure_user_metadata(_app_user_tenancy.app_user_id, _actual_app_user_tenancy.id);

    return _app_user_tenancy;
  end;
  $$;  
----------------------------------------------------------------- exit_support_mode
CREATE OR REPLACE FUNCTION app_fn_api.exit_support_mode()
  RETURNS app.app_user_tenancy
  LANGUAGE plpgsql
  VOLATILE
  SECURITY DEFINER
  AS $$
  DECLARE
    _app_user_tenancy app.app_user_tenancy;
  BEGIN
    if auth_ext.has_permission('p:app-admin-support') = false then
      raise exception '30000: PERMISSION DENIED';
    end if;

    _app_user_tenancy := (select app_fn.exit_support_mode(auth_ext.app_user_tenancy_id(), auth_ext.actual_app_user_tenancy_id()));
    return _app_user_tenancy;
  end;
  $$;  

CREATE OR REPLACE FUNCTION app_fn.exit_support_mode(_support_app_user_tenancy_id uuid, _actual_app_user_tenancy uuid)
  RETURNS app.app_user_tenancy
  LANGUAGE plpgsql
  VOLATILE
  SECURITY DEFINER
  AS $$
  DECLARE
    _app_user_tenancy app.app_user_tenancy;
  BEGIN
    update app.app_user_tenancy set status = 'inactive' where id = _support_app_user_tenancy_id;
    _app_user_tenancy := (select app_fn.assume_app_user_tenancy(id::uuid, email::citext) from app.app_user_tenancy where id = _actual_app_user_tenancy);

    return _app_user_tenancy;
  end;
  $$;  
----------------------------------------------------------------- get_ab_listings --- API ONLY
CREATE OR REPLACE FUNCTION app_fn_api.get_ab_listings(_app_user_id uuid)
  RETURNS SETOF app_fn.ab_listing
  LANGUAGE plpgsql
  STABLE
  SECURITY DEFINER
  AS $$
  DECLARE
  BEGIN
    return query select * from app_fn.get_ab_listings(auth.uid(), auth_ext.app_tenant_id());
  end;
  $$;  

-- ---------------------------------------------- search_app_user_tenancies
--   CREATE OR REPLACE FUNCTION app_fn_api.search_app_user_tenancies(_options app_fn.search_app_user_tenancies_options)
--     RETURNS setof app.app_user_tenancy
--     LANGUAGE plpgsql
--     stable
--     SECURITY DEFINER
--     AS $$
--     DECLARE
--     BEGIN
--       return query select * from app_fn.search_app_user_tenancies(_options);
--     end;
--     $$;

--   CREATE OR REPLACE FUNCTION app_fn.search_app_user_tenancies(_options app_fn.search_app_user_tenancies_options)
--     RETURNS setof app.app_user_tenancy
--     LANGUAGE plpgsql
--     stable
--     SECURITY DEFINER
--     AS $$
--     DECLARE
--       _use_options app_fn.search_app_user_tenancies_options;
--     BEGIN
--       -- app_user_tenancy: add paging options

--       return query
--       select t.* 
--       from app.app_user_tenancy t
--       join app.app_tenant a on a.id = t.app_tenant_id
--       where (
--         _options.search_term is null 
--         or t.email like '%'||_options.search_term||'%'
--         or t.app_tenant_name like '%'||_options.search_term||'%'
--         or a.display_name like '%'||_options.search_term||'%'
--       )
--       and (_options.app_user_tenancy_type is null or t.type = _options.app_user_tenancy_type)
--       and (_options.app_user_tenancy_status is null or t.status = _options.app_user_tenancy_status)
--       and (coalesce(_options.roots_only, false) = false or t.parent_app_user_tenancy_id is null )
--       ;
--     end;
--     $$;


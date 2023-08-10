----------------------------------------------------------------- configure_user_metadata ---  NO API
CREATE OR REPLACE FUNCTION app_fn.configure_user_metadata(_profile_id uuid, _actual_resident uuid default null)
  RETURNS void
  LANGUAGE plpgsql
  VOLATILE
  SECURITY DEFINER
  AS $$
  DECLARE
    _profile_claims app_fn.profile_claims;
  BEGIN
    _profile_claims := app_fn.current_profile_claims(_profile_id);
    _profile_claims.actual_resident_id = _actual_resident;

    -- here and app_fn.handle_new_user should be the only places where auth.users are updated
    update auth.users set
      raw_user_meta_data = (select to_jsonb(_profile_claims))
    where id = _profile_id
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
    _resident app.resident;
  begin
    insert into app.profile (id, email, display_name)
    values (new.id, new.email, split_part(new.email, '@', 1));

    update app.resident set
      profile_id = new.id
      ,status = 'active'
    where email = new.email
    and status != 'blocked_individual'
    and status != 'blocked_tenant'
    ;

    select * into _resident from app.resident where profile_id = new.id and status = 'active' limit 1;

    -- this has to happen directly because this is inside a trigger
    update auth.users set 
      raw_user_meta_data = (select to_jsonb(app_fn.current_profile_claims(_resident.profile_id)))
    where id = _resident.profile_id
    ;

    return new;
  end;
  $$;
  -- trigger the function every time a user is created
create or replace trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure app_fn.handle_new_user();
----------------------------------- assume_resident
CREATE OR REPLACE FUNCTION app_api.assume_resident(_resident_id uuid)
  RETURNS app.resident
  LANGUAGE plpgsql
  VOLATILE
  SECURITY DEFINER
  AS $function$
  DECLARE
    _resident app.resident;
  BEGIN
    _resident := app_fn.assume_resident(_resident_id, auth_ext.email());
    return _resident;
  end;
  $function$
  ;

CREATE OR REPLACE FUNCTION app_fn.assume_resident(_resident_id uuid, _email citext)
  RETURNS app.resident
  LANGUAGE plpgsql
  VOLATILE
  SECURITY DEFINER
  AS $function$
  DECLARE
    _resident app.resident;
  BEGIN
    select * into _resident from app.resident where id = _resident_id and email = _email;
    -- raise exception '%', _resident;

    if _resident.id is not null then
      update app.resident set 
        status = 'inactive' 
        ,updated_at = current_timestamp 
      where profile_id = _resident.profile_id
      and status in ('active', 'supporting')
      and id != _resident_id 
      ;

      update app.resident set 
        status = 'active' 
        ,updated_at = current_timestamp 
      where id = _resident_id
      returning * 
      into _resident;

      perform app_fn.configure_user_metadata(_resident.profile_id);
    end if;

    return _resident;
  end;
  $function$
  ;

----------------------------------- update_profile
CREATE OR REPLACE FUNCTION app_api.update_profile(
    _display_name citext
    ,_first_name citext
    ,_last_name citext
    ,_phone citext default null
  )
  RETURNS app.profile
  LANGUAGE plpgsql
  VOLATILE
  SECURITY DEFINER
  AS $function$
  DECLARE
    _profile app.profile;
  BEGIN
    _profile := app_fn.update_profile(
      auth.uid()
      ,_display_name
      ,_first_name
      ,_last_name
      ,_phone
    );
    return _profile;
  end;
  $function$
  ;

CREATE OR REPLACE FUNCTION app_fn.update_profile(
    _profile_id uuid
    ,_display_name citext
    ,_first_name citext
    ,_last_name citext
    ,_phone citext default null
  )
  RETURNS app.profile
  LANGUAGE plpgsql
  VOLATILE
  SECURITY DEFINER
  AS $function$
  DECLARE
    _profile app.profile;
  BEGIN
    update app.resident set 
      display_name = _display_name
      ,updated_at = current_timestamp 
    where profile_id = _profile_id
    ;

    update app.profile set 
      display_name = _display_name
      ,first_name = _first_name
      ,last_name = _last_name
      ,phone = _phone
      ,updated_at = current_timestamp 
    where id = _profile_id
    returning * 
    into _profile;

    perform app_fn.configure_user_metadata(_profile.id);

    return _profile;
  end;
  $function$
  ;

----------------------------------- invite_user
CREATE OR REPLACE FUNCTION app_api.invite_user(_email citext)
  RETURNS app.resident
  LANGUAGE plpgsql
  VOLATILE
  SECURITY DEFINER
  AS $function$
  DECLARE
    _profile app.profile;
    _resident app.resident;
  BEGIN
    -- this function invites a user to the same tenant as the current user
    -- can only be called by user with app-admin license or better.

    if auth_ext.has_permission('p:app-admin') = false then
      raise exception '30000: UNAUTHORIZED';
    end if;

    select * into _resident 
    from app.resident 
    where profile_id = auth.uid() 
    and status = 'active'
    ;

    _resident = (select app_fn.invite_user(_resident.tenant_id, _email));

    return _resident;
  end;
  $function$
  ;

CREATE OR REPLACE FUNCTION app_fn.invite_user(
    _tenant_id uuid
    ,_email citext
    ,_assignment_scope app.license_type_assignment_scope default 'user'
  )
  RETURNS app.resident
  LANGUAGE plpgsql
  VOLATILE
  SECURITY DEFINER
          -- security definer to allow for select of app.profile from other tenants
          -- this would allow for one tenant to know if a user at an email were on
          -- the platform - though the other would know that they know.  so it would
          -- all be known knowns and no unknown unknowns.  -- donny r
  AS $function$
  DECLARE
    _profile app.profile;
    _resident app.resident;
    _tenant app.tenant;
    _license_pack_license_type app.license_pack_license_type;
    _license_type_key citext;
    _tenant_subscription_id uuid;
  BEGIN    
    -- find existing records for profile and resident
    select * into _profile from app.profile where email = _email;
    select * into _resident from app.resident where email = _email and tenant_id = _tenant_id;
    select * into _tenant from app.tenant where id = _tenant_id;

    if _resident.id is null then
      insert into app.resident(
        tenant_id
        ,tenant_name
        ,email
        ,display_name
      ) values (
        _tenant.id
        ,_tenant.name
        ,_email
        ,coalesce(_profile.display_name, split_part(_email,'@',1))
      ) 
      returning * into _resident;

      -- grant all licenses at the specified assignment scope
      for _license_type_key, _tenant_subscription_id in
        select lplt.license_type_key, ats.id
          from app.license_pack_license_type lplt
          join app.license_type lt on lt.key = lplt.license_type_key
          join app.license_pack lp on lp.key = lplt.license_pack_key
          join app.tenant_subscription ats on ats.license_pack_key = lp.key
          where ats.tenant_id = _tenant_id
          and (lt.assignment_scope = _assignment_scope or lt.assignment_scope = 'all')
      loop
        insert into app.license(
          tenant_id
          ,resident_id
          ,tenant_subscription_id
          ,license_type_key
        )
        values (
          _tenant_id
          ,_resident.id
          ,_tenant_subscription_id
          ,_license_type_key
        )
        on conflict (resident_id, license_type_key) DO UPDATE SET updated_at = EXCLUDED.updated_at
        ;
      end loop;
    end if;
    
    -- attach resident to any existing user
    if _profile.id is not null then
      update app.resident set profile_id = _profile.id where id = _resident.id returning * into _resident;
    end if;

    return _resident;
  end;
  $function$
  ;

----------------------------------- demo_profile_residencies
CREATE OR REPLACE FUNCTION app_api.demo_profile_residencies()
  RETURNS setof app.resident
  LANGUAGE plpgsql
  STABLE
  SECURITY DEFINER
  AS $function$
  DECLARE
  BEGIN
    return query select * from app_fn.demo_profile_residencies();
  end;
  $function$
  ;

CREATE OR REPLACE FUNCTION app_fn.demo_profile_residencies()
  RETURNS setof app.resident
  LANGUAGE plpgsql
  STABLE
  SECURITY DEFINER
  AS $function$
  DECLARE
  BEGIN
    return query
    select distinct
      aut.*
    from app.resident aut
    join app.tenant t on t.id = aut.tenant_id
    where (t.type = 'demo' or t.type = 'anchor')
    and aut.display_name != 'Site Support'
    ;
  end;
  $function$
  ;
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
    if auth_ext.has_permission('p:app-admin-support') = false then
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
      ) values (
        _tenant.id
        ,_profile_id
        ,_tenant.name
        ,_support_email
        ,_support_display_name
        ,'active'
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
        and license_type_key = lplt.license_Type_key
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
    _resident := (select app_fn.assume_resident(id::uuid, email::citext) from app.resident where id = _actual_resident);

    return _resident;
  end;
  $$;  
----------------------------------------------------------------- get_ab_listings --- API ONLY
CREATE OR REPLACE FUNCTION app_api.get_ab_listings(_profile_id uuid)
  RETURNS SETOF app_fn.ab_listing
  LANGUAGE plpgsql
  STABLE
  SECURITY DEFINER
  AS $$
  DECLARE
  BEGIN
    return query select * from app_fn.get_ab_listings(auth.uid(), auth_ext.tenant_id());
  end;
  $$;  

-- ---------------------------------------------- search_profile_residencies
--   CREATE OR REPLACE FUNCTION app_api.search_profile_residencies(_options app_fn.search_profile_residencies_options)
--     RETURNS setof app.resident
--     LANGUAGE plpgsql
--     stable
--     SECURITY DEFINER
--     AS $$
--     DECLARE
--     BEGIN
--       return query select * from app_fn.search_profile_residencies(_options);
--     end;
--     $$;

--   CREATE OR REPLACE FUNCTION app_fn.search_profile_residencies(_options app_fn.search_profile_residencies_options)
--     RETURNS setof app.resident
--     LANGUAGE plpgsql
--     stable
--     SECURITY DEFINER
--     AS $$
--     DECLARE
--       _use_options app_fn.search_profile_residencies_options;
--     BEGIN
--       -- resident: add paging options

--       return query
--       select t.* 
--       from app.resident t
--       join app.tenant a on a.id = t.tenant_id
--       where (
--         _options.search_term is null 
--         or t.email like '%'||_options.search_term||'%'
--         or t.tenant_name like '%'||_options.search_term||'%'
--         or a.display_name like '%'||_options.search_term||'%'
--       )
--       and (_options.resident_type is null or t.type = _options.resident_type)
--       and (_options.resident_status is null or t.status = _options.resident_status)
--       and (coalesce(_options.roots_only, false) = false or t.parent_resident_id is null )
--       ;
--     end;
--     $$;


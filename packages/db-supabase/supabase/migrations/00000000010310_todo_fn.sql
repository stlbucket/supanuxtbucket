-----------------------------------------------
-- script  todo_fn schema
-----------------------------------------------

create schema if not exists todo_fn_api;
create schema if not exists todo_fn;

-------------------------------------------------------------------------------- todo-functions
-------------------------------------- ensure_todo_user
CREATE OR REPLACE FUNCTION todo_fn.ensure_todo_user(
    _app_user_tenancy_id uuid
  ) RETURNS todo.todo_user
    LANGUAGE plpgsql VOLATILE
    AS $$
  DECLARE
    _todo_tenant todo.todo_tenant;
    _todo_user todo.todo_user;
  BEGIN
    -- ensure that the tenancy has a todo_user and todo_tenant.  add them if not.
    select mt.* 
    into _todo_tenant 
    from todo.todo_tenant mt 
    join app.app_user_tenancy aut on mt.app_tenant_id = aut.app_tenant_id and aut.id = _app_user_tenancy_id
    ;

    if _todo_tenant.app_tenant_id is null then
      insert into todo.todo_tenant(app_tenant_id, name)
        select app_tenant_id, app_tenant_name
        from app.app_user_tenancy 
        where id = _app_user_tenancy_id
      returning * into _todo_tenant;
    end if;

    select * into _todo_user from todo.todo_user where app_user_tenancy_id = _app_user_tenancy_id;
    if _todo_user.app_user_tenancy_id is null then
      insert into todo.todo_user(app_user_tenancy_id, display_name, app_tenant_id)
        select id, display_name, app_tenant_id
        from app.app_user_tenancy 
        where id = _app_user_tenancy_id 
      returning * into _todo_user;
    end if;
    return _todo_user;
  end;
  $$;
---------------------------------------------- create_todo
CREATE OR REPLACE FUNCTION todo_fn_api.create_todo(
    _name citext
    ,_options todo_fn.create_todo_options
  )
  RETURNS todo.todo
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $$
  DECLARE
    _retval todo.todo;
  BEGIN
    _retval := todo_fn.create_todo(
      auth_ext.app_user_tenancy_id()::uuid
      ,_name::citext
      ,_options::todo_fn.create_todo_options
    );
    return _retval;
  end;
  $$;

CREATE OR REPLACE FUNCTION todo_fn.create_todo(
    _app_user_tenancy_id uuid
    ,_name citext
    ,_options todo_fn.create_todo_options
  )
  RETURNS todo.todo
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $$
  DECLARE
    _ordinal integer;
    _todo_user todo.todo_user;
    _retval todo.todo;
  BEGIN
    _todo_user := todo_fn.ensure_todo_user(_app_user_tenancy_id);

    _ordinal := 0;
    if _options.parent_todo_id is not null then
      _ordinal := (select count(*) + 1 from todo.todo where parent_todo_id = _options.parent_todo_id);
    end if;

    insert into todo.todo(
      app_tenant_id
      ,app_user_tenancy_id
      ,name
      ,description
      ,parent_todo_id
      ,ordinal
    ) 
    values(
      _todo_user.app_tenant_id
      ,_todo_user.app_user_tenancy_id
      ,_name
      ,_options.description
      ,_options.parent_todo_id
      ,_ordinal
    )
    returning * into _retval;

    if _options.parent_todo_id is not null then
      update todo.todo set type = 'milestone' where id = _options.parent_todo_id;

      perform todo_fn.update_todo_status(
        _todo_id => _retval.id
        ,_status => 'incomplete'
      );
    end if;

    
    return _retval;
  end;
  $$;

---------------------------------------------- update_todo
CREATE OR REPLACE FUNCTION todo_fn_api.update_todo(
    _todo_id uuid
    ,_name citext
    ,_description citext default null
  )
  RETURNS todo.todo
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $$
  DECLARE
    _retval todo.todo;
  BEGIN
    _retval := todo_fn.update_todo(
      _todo_id
      ,_name
      ,_description
    );
    return _retval;
  end;
  $$;

CREATE OR REPLACE FUNCTION todo_fn.update_todo(
    _todo_id uuid
    ,_name citext
    ,_description citext default null
  )
  RETURNS todo.todo
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $$
  DECLARE
    _retval todo.todo;
  BEGIN
    update todo.todo set
      name = _name
      ,description = _description
    where id = _todo_id
    returning * into _retval
    ;

    return _retval;
  end;
  $$;

---------------------------------------------- update_todo_status
CREATE OR REPLACE FUNCTION todo_fn_api.update_todo_status(
    _todo_id uuid
    ,_status todo.todo_status
  )
  RETURNS todo.todo
  VOLATILE
  SECURITY INVOKER
  LANGUAGE plpgsql
  AS $function$
  DECLARE
    _todo todo.todo;
  BEGIN
    _todo := todo_fn.update_todo_status(_todo_id, _status);
    return _todo;
  end;
  $function$
  ;

CREATE OR REPLACE FUNCTION todo_fn.update_todo_status(
    _todo_id uuid
    ,_status todo.todo_status
  )
  RETURNS todo.todo
  VOLATILE
  SECURITY INVOKER
  LANGUAGE plpgsql
  AS $function$
  DECLARE
    _todo todo.todo;
  BEGIN
      update todo.todo set 
        status = _status
        ,updated_at = current_timestamp
      where id = _todo_id
      returning * into _todo
      ;

      if _todo.parent_todo_id is not null then
        if _status = 'complete' then
          if (select count(*) from todo.todo where parent_todo_id = _todo.parent_todo_id and status = 'incomplete') = 0 then
            -- update todo.todo set status = 'complete' where id = _todo.parent_todo_id;
            perform todo_fn.update_todo_status(_todo.parent_todo_id, 'complete');
          end if; 
        end if;

        if _status = 'incomplete' then
          perform todo_fn.update_todo_status(_todo.parent_todo_id, 'incomplete');
          -- update todo.todo set status = 'incomplete' where id = _todo.parent_todo_id;
        end if;
      end if;
      
    return _todo;
  end;
  $function$
  ;

---------------------------------------------- delete_todo
CREATE OR REPLACE FUNCTION todo_fn_api.delete_todo(_todo_id uuid)
  RETURNS boolean
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $$
  DECLARE
    _retval boolean;
  BEGIN
    _retval := todo_fn.delete_todo(_todo_id);
    return _retval;
  end;
  $$;

CREATE OR REPLACE FUNCTION todo_fn.delete_todo(_todo_id uuid)
  RETURNS boolean
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $$
  DECLARE
    _parent_child_count integer;
    _todo todo.todo;
  BEGIN
    perform todo_fn.delete_todo(id) from todo.todo where parent_todo_id = _todo_id;
    
    select * into _todo from todo.todo where id = _todo_id;

    if _todo.parent_todo_id is not null then
      _parent_child_count := (select count(*) from todo.todo where parent_todo_id = _todo.parent_todo_id);
    else
      _parent_child_count := -1;
    end if;
    delete from todo.todo where id = _todo_id;

    if _parent_child_count = 1 then
      update todo.todo set type = 'task' where id = _todo.parent_todo_id;
    end if;

    return true;
  end;
  $$;

---------------------------------------------- pin_todo
CREATE OR REPLACE FUNCTION todo_fn_api.pin_todo(_todo_id uuid)
  RETURNS todo.todo
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $$
  DECLARE
    _retval todo.todo;
  BEGIN
    _retval := todo_fn.pin_todo(_todo_id);
    return _retval;
  end;
  $$;

CREATE OR REPLACE FUNCTION todo_fn.pin_todo(_todo_id uuid)
  RETURNS todo.todo
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $$
  DECLARE
    _todo todo.todo;
  BEGIN
    update todo.todo set pinned = true where id = _todo_id returning * into _todo;
    return _todo;
  end;
  $$;

---------------------------------------------- unpin_todo
CREATE OR REPLACE FUNCTION todo_fn_api.unpin_todo(_todo_id uuid)
  RETURNS todo.todo
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $$
  DECLARE
    _retval todo.todo;
  BEGIN
    _retval := todo_fn.unpin_todo(_todo_id);
    return _retval;
  end;
  $$;

CREATE OR REPLACE FUNCTION todo_fn.unpin_todo(_todo_id uuid)
  RETURNS todo.todo
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $$
  DECLARE
    _todo todo.todo;
  BEGIN
    update todo.todo set pinned = false where id = _todo_id returning * into _todo;
    return _todo;
  end;
  $$;

---------------------------------------------- assign_todo
CREATE OR REPLACE FUNCTION todo_fn_api.assign_todo(_todo_id uuid, _app_user_tenancy_id uuid)
  RETURNS todo.todo
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $$
  DECLARE
    _retval todo.todo;
  BEGIN
    _retval := todo_fn.assign_todo(_todo_id, _app_user_tenancy_id);
    return _retval;
  end;
  $$;

CREATE OR REPLACE FUNCTION todo_fn.assign_todo(_todo_id uuid, _app_user_tenancy_id uuid)
  RETURNS todo.todo
  LANGUAGE plpgsql
  VOLATILE
  SECURITY INVOKER
  AS $$
  DECLARE
    _todo todo.todo;
  BEGIN
    update todo.todo set app_user_tenancy_id = _app_user_tenancy_id where id = _todo_id returning * into _todo;
    return _todo;
  end;
  $$;

---------------------------------------------- get_full_todo_tree
CREATE OR REPLACE FUNCTION todo_fn_api.get_full_todo_tree(_todo_id uuid)
  RETURNS jsonb
  LANGUAGE plpgsql
  STABLE
  SECURITY INVOKER
  AS $$
  DECLARE
    _retval jsonb;
  BEGIN
    _retval := todo_fn.get_full_todo_tree(_todo_id);
    return _retval;
  end;
  $$;

CREATE OR REPLACE FUNCTION todo_fn.get_full_todo_tree(_todo_id uuid)
  RETURNS jsonb
  LANGUAGE plpgsql
  STABLE
  SECURITY INVOKER
  AS $$
  DECLARE
    _retval jsonb;
    _children jsonb[];
  BEGIN
    select array_agg(coalesce(todo_fn.get_full_todo_tree(id), '{}'::jsonb))
    into _children
    from todo.todo where parent_todo_id = _todo_id
    ;

    select jsonb_build_object(
      'id', _todo_id,
      'name', t.name,
      'status', t.status,
      'type', t.type,
      'canEdit', (_children is null or array_length(_children, 1) = 0),
      'children', coalesce(_children, '{}'::jsonb[])
    )
    into _retval
    from todo.todo t
    where id = _todo_id
    ;

    return _retval;
  end;
  $$;


---------------------------------------------- search_todos
  CREATE OR REPLACE FUNCTION todo_fn_api.search_todos(_options todo_fn.search_todos_options)
    RETURNS setof todo.todo
    LANGUAGE plpgsql
    stable
    SECURITY INVOKER
    AS $$
    DECLARE
    BEGIN
      return query select * from todo_fn.search_todos(_options);
    end;
    $$;

  CREATE OR REPLACE FUNCTION todo_fn.search_todos(_options todo_fn.search_todos_options)
    RETURNS setof todo.todo
    LANGUAGE plpgsql
    stable
    SECURITY INVOKER
    AS $$
    DECLARE
      _use_options todo_fn.search_todos_options;
    BEGIN
      -- TODO: add paging options

      return query
      select t.* 
      from todo.todo t
      join app.app_tenant a on a.id = t.app_tenant_id
      where (
        _options.search_term is null 
        or t.name like '%'||_options.search_term||'%'
        or t.description like '%'||_options.search_term||'%'
        or a.name like '%'||_options.search_term||'%'
      )
      and (_options.todo_type is null or t.type = _options.todo_type)
      and (_options.todo_status is null or t.status = _options.todo_status)
      and (coalesce(_options.roots_only, false) = false or t.parent_todo_id is null )
      ;
    end;
    $$;


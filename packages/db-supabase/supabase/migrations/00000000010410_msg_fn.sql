-------------------------------------- ensure_msg_user
CREATE OR REPLACE FUNCTION msg_fn.ensure_msg_user(
    _app_user_tenancy_id uuid
  ) RETURNS msg.msg_user
    LANGUAGE plpgsql VOLATILE
    AS $$
  DECLARE
    _msg_tenant msg.msg_tenant;
    _msg_user msg.msg_user;
  BEGIN
    -- ensure that the tenancy has a msg_user and msg_tenant.  add them if not.
    select mt.* 
    into _msg_tenant 
    from msg.msg_tenant mt 
    join app.app_user_tenancy aut on mt.app_tenant_id = aut.app_tenant_id and aut.id = _app_user_tenancy_id
    ;

    if _msg_tenant.app_tenant_id is null then
      insert into msg.msg_tenant(app_tenant_id, name)
        select app_tenant_id, app_tenant_name
        from app.app_user_tenancy 
        where id = _app_user_tenancy_id
      returning * into _msg_tenant;
    end if;

    select * into _msg_user from msg.msg_user where id = _app_user_tenancy_id;
    if _msg_user.id is null then
      insert into msg.msg_user(id, display_name, app_tenant_id)
        select id, display_name, app_tenant_id
        from app.app_user_tenancy 
        where id = _app_user_tenancy_id 
      returning * into _msg_user;
    end if;
    return _msg_user;
  end;
  $$;

-------------------------------------- upsert_topic
CREATE OR REPLACE FUNCTION msg_fn_api.upsert_topic(
    _topic_info msg_fn.topic_info
  ) RETURNS msg.topic
    LANGUAGE plpgsql VOLATILE
    AS $$
  DECLARE
    _topic msg.topic;
  BEGIN
    perform auth_ext.enforce_permission('p:discussions');

    _topic := msg_fn.upsert_topic(
      _topic_info
      ,auth_ext.app_user_tenancy_id()
    );
    return _topic;
  end;
  $$;

CREATE OR REPLACE FUNCTION msg_fn.upsert_topic(
    _topic_info msg_fn.topic_info
    ,_app_user_tenancy_id uuid
  ) RETURNS msg.topic
    LANGUAGE plpgsql VOLATILE
    AS $$
  DECLARE
    _msg_user msg.msg_user;
    _topic msg.topic;
    _topic_id uuid;
  BEGIN
    _msg_user := msg_fn.ensure_msg_user(_app_user_tenancy_id);

    _topic_id = coalesce(_topic_info.id, gen_random_uuid());
    select *
      into _topic
    from msg.topic
    where (id = _topic_id or identifier = _topic_info.identifier)
    and app_tenant_id = _msg_user.app_tenant_id
    ;

    if _topic.id is not null then
      update msg.topic set
        name = _topic_info.name
      where id = _topic_id
      ;
    else
      insert into msg.topic(
        id
        ,app_tenant_id
        ,name
        ,identifier
        ,status
      )
      select
        _topic_id
        ,_msg_user.app_tenant_id
        ,_topic_info.name
        ,_topic_info.identifier
        ,coalesce(_topic_info.status, 'open')
      returning *
      into _topic
      ;
    end if;

    return _topic;
  end;
  $$;
-------------------------------------- upsert_message
CREATE OR REPLACE FUNCTION msg_fn_api.upsert_message(
    _message_info msg_fn.message_info
  ) RETURNS msg.message
    LANGUAGE plpgsql VOLATILE
    AS $$
  DECLARE
    _message msg.message;
  BEGIN
    perform auth_ext.enforce_permission('p:discussions');

    _message := msg_fn.upsert_message(
      _message_info
      ,auth_ext.app_user_tenancy_id()
    );
    return _message;
  end;
  $$;

CREATE OR REPLACE FUNCTION msg_fn.upsert_message(
    _message_info msg_fn.message_info
    ,_app_user_tenancy_id uuid
  ) RETURNS msg.message
    LANGUAGE plpgsql VOLATILE
    AS $$
  DECLARE
    _msg_user msg.msg_user;
    _topic msg.topic;
    _message msg.message;
  BEGIN
    _msg_user := msg_fn.ensure_msg_user(_app_user_tenancy_id);

    select * 
    into _topic 
    from msg.topic 
    where _message_info.topic_id is not null 
    and id = _message_info.topic_id;

    if _topic.id is null then
      _topic := msg_fn.upsert_topic(
        row(
          null::uuid
          ,case
            when length(_message_info.content > 100) then substring(_message_info.content from 0 for 100)::citext
            else _message_info.content
          end 
          ,null::citext
          ,'open'::msg.topic_status
        )
        ,_msg_user.app_user_tenancy_id
      );
    end if;

    select * into _message from msg.message where id = _message_info.id;

    if _message.id is not null then
      update msg.message set
        content = _message_info.content
        ,tags = coalesce(_message_info.tags, '{}')
      where id = _message.id
      ;
    else
      insert into msg.message(
        app_tenant_id
        ,topic_id
        ,posted_by_msg_user_id
        ,content
        ,tags
      )
      select
        _topic.app_tenant_id
        ,_message_info.topic_id
        ,_msg_user.id
        ,_message_info.content
        ,coalesce(_message_info.tags, '{}')
      returning *
      into _message
      ;
    end if;

    return _message;
  end;
  $$;
-------------------------------------- upsert_subscription
CREATE OR REPLACE FUNCTION msg_fn_api.upsert_subscription(
    _subscription_info msg_fn.subscription_info
  ) RETURNS msg.subscription
    LANGUAGE plpgsql VOLATILE
    AS $$
  DECLARE
    _subscription msg.subscription;
  BEGIN
    perform auth_ext.enforce_permission('p:discussions');

    _subscription := msg_fn.upsert_subscription(
      _subscription_info
    );
    return _subscription;
  end;
  $$;

CREATE OR REPLACE FUNCTION msg_fn.upsert_subscription(
    _subscription_info msg_fn.subscription_info
  ) RETURNS msg.subscription
    LANGUAGE plpgsql VOLATILE
    AS $$
  DECLARE
    _topic msg.topic;
    _subscription msg.subscription;
    _msg_user msg.msg_user;
  BEGIN
    _msg_user := msg_fn.ensure_msg_user(_subscription_info.subscriber_msg_user_id);

    select *
    into _topic
    from msg.topic
    where id = _subscription_info.topic_id
    ;
    if _topic.id is null then
      raise exception 'no topic for id: %', _subscription_info.topic_id;
    end if;

    select * into _subscription
    from msg.subscription
    where topic_id = _subscription_info.topic_id
    and subscriber_msg_user_id = _subscription_info.subscriber_msg_user_id
    ;

    if _subscription.id is not null then
      update msg.subscription set
        status = 'active'
      where id = _subscription.id
      ;
    else
      insert into msg.subscription(
        app_tenant_id
        ,topic_id
        ,subscriber_msg_user_id
      )
      select
        _topic.app_tenant_id
        ,_topic.id
        ,_subscription_info.subscriber_msg_user_id
      returning *
      into _subscription
      ;
    end if;

    return _subscription;
  end;
  $$;
-------------------------------------- upsert_subscription
CREATE OR REPLACE FUNCTION msg_fn_api.deactivate_subscription(
    _subscription_id uuid
  ) RETURNS msg.subscription
    LANGUAGE plpgsql VOLATILE
    AS $$
  DECLARE
    _subscription msg.subscription;
  BEGIN
    perform auth_ext.enforce_permission('p:discussions');

    _subscription := msg_fn.deactivate_subscription(
      _subscription_id
    );
    return _subscription;
  end;
  $$;

CREATE OR REPLACE FUNCTION msg_fn.deactivate_subscription(
    _subscription_id uuid
  ) RETURNS msg.subscription
    LANGUAGE plpgsql VOLATILE
    AS $$
  DECLARE
    _subscription msg.subscription;
  BEGIN
    update msg.subscription set
      status = 'inactive'
    where id = _subscription_id
    returning *
    into _subscription
    ;

    return _subscription;
  end;
  $$;
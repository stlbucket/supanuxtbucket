      select todo_fn.create_todo(
        _resident_id => (select id from app.resident where tenant_id = l.tenant_id order by random() limit 1)
        ,_name => ('Trash Pickup '||l.name)::citext
        ,_options => row(
          'picking up trash'::citext
          ,null
          ,'{}'::citext[]
          ,false
          ,row(
            l.id,
            '',
            '',
            null,
            null,
            null,
            null,
            null,
            null,
            null
          )::loc_fn.location_info
        )::todo_fn.create_todo_options
      ) 
      from loc.location l
      ;

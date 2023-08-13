------------------------ CREATE ANCHOR TENANT AND SUPER ADMIN USER ---------------------------------------------
--- change parameters as appropriate
  select app_fn.create_anchor_tenant(
    _name => 'Anchor Tenant'::citext
    ,_email => 'app-admin-super@example.com'::citext
  );

  insert into app.app_settings(application_key, key, display_name, value) values ('app', 'support-email', 'Site Support Email', 'site-support@example.com');
  insert into app.app_settings(application_key, key, display_name, value) values ('app', 'support-display-name', 'Site Support Display Name', 'Site Support');

------------------------ INSTALL APPLICATIONS AND SUBSCRIBE ANCHOR TENANT TO EACH ------------------------------

  -- select todo_fn.install_todo_application();
  -- select app_fn.subscribe_tenant_to_license_pack(
  --   _tenant_id => (select id from app.tenant where identifier = 'anchor')::uuid
  --   ,_license_pack_key => 'todo'
  -- );
      -- select your_app_fn.install_your_application();
      -- select app_fn.subscribe_tenant_to_license_pack(
      --   _tenant_id => (select id from app.tenant where identifier = 'anchor')::uuid
      --   ,_license_pack_key => 'YOUR LICENSE PACK NAME FROM your_app_fn.install_your_application()'
      -- );

      -- take a look todo_fn.install_todo_application for an example

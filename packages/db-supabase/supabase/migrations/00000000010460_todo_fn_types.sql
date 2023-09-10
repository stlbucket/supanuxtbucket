-----------------------------------------------
-- script  todo_fn schema
-----------------------------------------------

create schema if not exists todo_api;
create schema if not exists todo_fn;

create type todo_fn.create_todo_options as (
  description citext
  ,parent_todo_id uuid
  ,is_template boolean
);
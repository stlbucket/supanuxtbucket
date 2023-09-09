#!/usr/bin/env bash
psql -h 0.0.0.0 -U postgres -c 'drop database snb;'
psql -h 0.0.0.0 -U postgres -c 'create database snb;'

psql -h 0.0.0.0 -U postgres -d snb -f ./supabase/auth-stub.sql
psql -h 0.0.0.0 -U postgres -d snb -f ./supabase/migrations/00000000010100_extensions.sql
psql -h 0.0.0.0 -U postgres -d snb -f ./supabase/migrations/00000000010220_app.sql
psql -h 0.0.0.0 -U postgres -d snb -f ./supabase/migrations/00000000010230_app_fn_types.sql
psql -h 0.0.0.0 -U postgres -d snb -f ./supabase/migrations/00000000010300_todo.sql
psql -h 0.0.0.0 -U postgres -d snb -f ./supabase/migrations/00000000010400_msg.sql
psql -h 0.0.0.0 -U postgres -d snb -f ./supabase/migrations/00000000010450_loc.sql
psql -h 0.0.0.0 -U postgres -d snb -f ./supabase/migrations/00000000010500_inc.sql
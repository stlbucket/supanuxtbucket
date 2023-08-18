# Getting Started
Clone the repository at **https://github.com/stlbucket/nuxtsupabucket**
```
pnpm install
```

Create a [Supabase](https://www.supabase.com) account.

Install the [Supabase Cli](https://supabase.com/docs/guides/cli), create a new project and link to it.

Open a second terminal in the **/packages/db-supabase** directory and start your local Supabase dev environment, then deploy the migrations.  You will want to work in this directory to ensure the correct version of Supabase is used with the project
```
npx supabase projects list
npx supabase link --project-ref YOUR_PROJECT_REF
npx supabase db init
```
After this, you will need to install the demo data - this is in addition to the seed sql:
```
psql postgresql://postgres:postgres@localhost:54322/postgres -f ./supabase/demo-data.sql
```

In original terminal:
```
pnpm run dev
```
Then navigate to http://localhost:3025

This documentation should be available at http://localhost:5173

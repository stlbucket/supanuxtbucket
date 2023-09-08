# SupaNuxtPhile
Core Techs:
- [Supabase](https://www.supabase.com)
- [Nuxt](https://nuxtjs.com)
- [Postgraphile](https://postgraphile.org/)
- [Nuxt UI](https://ui.nuxtlabs.com/getting-started)
- [Nuxt Graphql Client](https://nuxt-graphql-client.web.app/)

## Purpose
This repo is intended to illustrate a quick-start scenario for building MVPs that can be easily deployed to Supabase and the related ecosystem.
- Multi-tenancy support that includes the ability for individuals to work in many contexts, with varying permission levels depending on tenant residency.
- Minimal UI styling, with simple straightforward usage of Nuxt UI component library and basic Tailwind tweaks.  It should be relatively painless to swap in a different library as desired.
- A schema-based, modular approach to database design meant to be scalable in the short term, and ready for refactoring should major services need to be split off in the future.

The problem space is loosely defined as an incident management scenario, where group discussion and ad-hoc todo list tools are included with additional functionality to build a custom solution.

Additionally, the combination of Nuxt, Postgraphile, and Supabase is a core aspect of this codebase.  Significant input from [benjie](https://github.com/benjie/) and [dodobibi](https://github.com/Dodobibi) in the Postgraphile community helped bring this together, and they will soon be likely to publish a proper Nuxt module.

## A few relevant threads
- [could_supabase_rls_used_for_complex_authorization](https://www.reddit.com/r/Supabase/comments/15nem7t/could_supabase_rls_used_for_complex_authorization/)
- [is_supabase_rls_enough_for_an_mvp](https://www.reddit.com/r/Supabase/comments/151xp3w/is_supabase_rls_enough_for_an_mvp/)
- [is_supabase_capable_of_multi_tenancy](https://www.reddit.com/r/Supabase/comments/165kbqs/is_supabase_capable_of_multi_tenancy/)
- [how_would_one_set_up_supabase_with_multitenant](https://www.reddit.com/r/Supabase/comments/zauwim/how_would_one_set_up_supabase_with_multitenant/)
# SupaNuxtPhile
Core Techs:
- [Supabase](https://www.supabase.com)
- [Nuxt](https://nuxtjs.com)
- [Postgraphile](https://postgraphile.org/)
- [Nuxt UI Labs](https://ui.nuxtlabs.com/getting-started)

## Goals
This repo is intended to illustrate a quick-start scenario for building MVPs that that can be easily deployed to Supabase and the related ecosystem.

Minimal UI styling, with simple straightforward usage of Nuxt UI Labs component library and basic Tailwind tweaks.  It should be relatively painless to swap in a different library as desired.

A schema-based, modular approach to database design meant to be scalable in the short term, and ready for refactoring should major services need to be split off in the future.

Multi-tenancy support that includes the ability for individuals to work in many contexts, with varying permission levels depending on tenant residency.  This is really the core functionality of this repository.  Todo, messaging and incidents could be removed with no impact.

The problem space is loosely defined as an incident management scenario, where group discussion and ad-hoc todo list tools are included with additional functionality to build a custom solution.

## Notes
The messaging feature is very minimal and not real-time enabled.  Ways to accomplish this could include:
- [supabase realtime](https://supabase.com/docs/guides/realtime)
- [postgraphile subscriptions](https://postgraphile.org/postgraphile/next/subscriptions/)
- [soketi](https://soketi.app/) - or other third-party solutions

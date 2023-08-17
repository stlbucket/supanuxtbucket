export default {
  title: 'VitePress',
  description: 'Just playing around with turborepo',
  themeConfig: {
    siteTitle: 'SupaNuxtGraphile',
    nav: [
      { text: 'Getting started', link: '/getting-started' },
      { text: 'Github', link: 'https://github.com/stlbucket/supanuxtbucket' },
    ],
    sidebar: [
      {
        items: [
          { text: 'Getting started', link: '/getting-started' },
          { text: 'Demo Data', link: '/demo-tenants' },
          { text: 'Postraphile v5', link: '/postgraphile' },
          { text: 'Credentials Flow', link: '/credentials-flow' },
          {
            text: 'Schemas',
            link: '/schemas/index.schema',
            items: [
              { text: 'auth_ext', link: '/schemas/auth_ext.schema' },
              { text: 'app', link: '/schemas/app.schema' },
              { text: 'todo', link: '/schemas/todo.schema' },
              { text: 'msg', link: '/schemas/msg.schema' },
              { text: 'inc', link: '/schemas/inc.schema' },
            ],
          },
          { text: 'UI Boilerplate', items: [
            { text: 'SiteAdmin', items: [
              { text: 'Applications', link: '/site-admin/applications' },
              { text: 'License Packs', link: '/site-admin/license-packs' },
              { text: 'App Users', link: '/site-admin/app-users' },
              { text: 'Tenant Residents', link: '/site-admin/tenant-residents' },
              { text: 'Tenant Support', link: '/site-admin/tenant-support' },
            ]},
            { text: 'Admin', items: [
              { text: 'App Users', link: '/site-admin/applications' },
              { text: 'Subscriptions', link: '/site-admin/license-packs' },
            ]},
            { text: 'Tools', items: [
              { text: 'Todo', link: '/site-admin/applications' },
              { text: 'Discussions', link: '/site-admin/license-packs' },
              { text: 'Address Book', link: '/site-admin/license-packs' },
            ]},
          ]}
        ],
      },
    ],
  },

}

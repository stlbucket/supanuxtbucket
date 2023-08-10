// https://nuxt.com/docs/api/configuration/nuxt-config
// import defaultTheme from 'tailwindcss/defaultTheme'
export default defineNuxtConfig({
  supabase: {
    redirect: false
  },
  imports: {
    dirs: [
      'lib'
      ,'store'
    ]
  },
  modules: [
    '@nuxthq/ui',
    '@nuxtjs/supabase',
    'nuxt-graphql-client',
    '@pinia/nuxt',
    '@pinia-plugin-persistedstate/nuxt',
    '@nuxtjs/tailwindcss'
  ],
  pinia: {
    autoImports: [
      ['defineStore', 'definePiniaStore'], // import { defineStore as definePiniaStore } from 'pinia'
    ],
  },
  devtools: { enabled: true },
  css: [
    '@/assets/css/main.scss'
  ],
  'graphql-client': {
    codegen: false,
    // tokenStorage: {
    //   mode: 'cookie',
    //   cookieOptions: {
    //     path: '/',
    //     secure: false, // defaults to `process.env.NODE_ENV === 'production'`
    //     httpOnly: false, // Only accessible via HTTP(S)
    //     maxAge: 60 * 60 * 24 * 5 // 5 days
    //   }
    // }
  },
  devServer: {
    port: 3025
  },
  runtimeConfig: {
    public: {      
      'graphql-client': {
        codegen: false,
        // tokenStorage: {
        //   mode: 'cookie',
        //   cookieOptions: {
        //     path: '/',
        //     secure: false, // defaults to `process.env.NODE_ENV === 'production'`
        //     httpOnly: false, // Only accessible via HTTP(S)
        //     maxAge: 60 * 60 * 24 * 5 // 5 days
        //   }
        // }
      },
      GQL_HOST: 'http://localhost:3025/api/graphql', // overwritten by process.env.GQL_HOST
    }  
  },
  components: {
    "dirs": [
      {
        "path": "~/components/_common",
        "global": true
      },
      {
        "path": "~/components/Dev",
        "global": true
      },
      {
        "path": "~/components/Nav",
        "global": true
      },
      {
        "path": "~/components/App",
        "global": true
      },
      {
        "path": "~/components/Todo",
        "global": true
      },
      {
        "path": "~/components/Inc",
        "global": true
      },
      "~/components"
    ]
  },
  // tailwindcss: {
  //   config: {
  //     theme: {
  //       extend: {
  //         colors: {
  //           primary: defaultTheme.colors.blue
  //         }
  //       }
  //     }  
  //   }
  // }
})

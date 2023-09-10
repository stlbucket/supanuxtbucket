// https://nuxt.com/docs/api/configuration/nuxt-config
// import defaultTheme from 'tailwindcss/defaultTheme'
export default defineNuxtConfig({
  supabase: {
    redirect: false,
    redirectOptions: {
      login: '/login',
      callback: '/authenticated',
      exclude: [],
    },
    cookieOptions: {
      // maxAge: 60 * 5,
      maxAge: 60 * 60 * 8,
      sameSite: 'lax',
      secure: true
    },
    clientOptions: {
      // auth: {
      //   flowType: 'pkce',
      //   detectSessionInUrl: true,
      //   persistSession: true,
      //   autoRefreshToken: true
      // },
    }
  },
  imports: {
    dirs: [
      'lib'
      ,'store'
      ,'types'
    ],
    global: true
  },
  modules: [
    '@nuxthq/ui',
    '@nuxtjs/supabase',
    'nuxt-graphql-client',
    '@pinia/nuxt',
    '@pinia-plugin-persistedstate/nuxt',
    '@nuxtjs/tailwindcss',
    'nuxt3-leaflet'
  ],
  pinia: {
    autoImports: [
      ['defineStore', 'definePiniaStore'],
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
    // these are for nuxt/supabase
    SUPABASE_URL: 'http://localhost:54321',
    SUPABASE_KEY: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0',
    SUPABASE_SERVICE_KEY: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU',
    SUPABASE_JWT_SECRET: 'super-secret-jwt-token-with-at-least-32-characters-long',    
    // this one is for postgraphile
    SUPABASE_URI: 'postgresql://postgres:postgres@localhost:54322/postgres',
    public: {      
      'graphql-client': {
        codegen: false
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
        "path": "~/components/Map",
        "global": true
      },
      {
        "path": "~/components/Inc",
        "global": true
      },
      "~/components"
    ]
  },
  ignore: [
    "server/api/mutation-hooks/**"
  ],
  tailwindcss: {
    config: {
      theme: {
        extend: {
          colors: {
            'tahiti': {
              100: '#cffafe',
              200: '#a5f3fc',
              300: '#67e8f9',
              400: '#22d3ee',
              500: '#06b6d4',
              600: '#0891b2',
              700: '#0e7490',
              800: '#155e75',
              900: '#164e63',
            },
          }
        }
      }  
    }
  }
})

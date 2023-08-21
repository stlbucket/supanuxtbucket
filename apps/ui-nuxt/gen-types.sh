npx kysely-codegen --camel-case --include-pattern 'app.*' --out-file ./db-types/db.app.d.ts

npx kysely-codegen --camel-case --include-pattern 'todo.*' --out-file ./db-types/db.todo.d.ts

npx kysely-codegen --camel-case --include-pattern 'msg.*' --out-file ./db-types/db.msg.d.ts

npx kysely-codegen --camel-case --include-pattern 'inc.*' --out-file ./db-types/db.inc.d.ts

npx kysely-codegen --camel-case --include-pattern 'app.*' --out-file ./types/db.app.d.ts

npx kysely-codegen --camel-case --include-pattern 'todo.*' --out-file ./types/db.todo.d.ts

npx kysely-codegen --camel-case --include-pattern 'msg.*' --out-file ./types/db.msg.d.ts

npx kysely-codegen --camel-case --include-pattern 'inc.*' --out-file ./types/db.inc.d.ts
# npx kysely-codegen --camel-case --include-pattern 'inc_fn.*' --out-file ./db.inc_fn.d.ts

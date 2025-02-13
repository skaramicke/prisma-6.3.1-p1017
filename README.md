# prisma-6.3.1-p1017

Example project for reproducing P1017 issue with Prisma 6.3.1.

## Original setup process

1. Install packages
      ```bash
      npm init -y
      npm install typescript tsx @types/node --save-dev
      npx tsc --init
      npm install prisma --save-dev
      ```

2. Create Prisma schema  
   Added the following schema to `schema.prisma` file.
      ```prisma
      model User {
        id    Int     @id @default(autoincrement())
        email String  @unique
        name  String?
        posts Post[]
      }

      model Post {
        id        Int     @id @default(autoincrement())
        title     String
        content   String?
        published Boolean @default(false)
        author    User    @relation(fields: [authorId], references: [id])
        authorId  Int
      }
      ```

  3. Create kind cluster
      ```bash
      kind create cluster --name prisma
      ```

  4. Start tilt
      ```bash
      tilt up
      ```
  
  5. Wait for postgresql to be ready
      ```bash
      kubectl exec deployments/postgresql -- pg_isready -U johndoe -d mydb
      # Defaulted container "postgresql" out of: postgresql, init-permissions (init)
      # /var/run/postgresql:5432 - accepting connections
      ```

  6. Run Prisma migrate
      ```bash
      npx prisma migrate dev --name init
      ```

## Result

```bash
% npx prisma migrate dev --name init
# Environment variables loaded from .env
# Prisma schema loaded from prisma/schema.prisma
# Datasource "db": PostgreSQL database "mydb", schema "public" at "localhost:5432"
# 
# Error: P1017
# 
# Server has closed the connection.
```

```bash
% DEBUG="*" npx prisma migrate dev --name init
# prisma:engines binaries to download libquery-engine, schema-engine +153ms
# prisma:getSchema prismaConfig {
#   "packagePath": "/Users/mix/Projects/prisma-6.3.1-p1017/package.json"
# } +232ms
# prisma:getSchema Checking existence of /Users/mix/Projects/prisma-6.3.1-p1017/schema.prisma +0ms
# prisma:getSchema Reading schema from single file /Users/mix/Projects/prisma-6.3.1-p1017/schema.prisma +1ms
# prisma:getSchema Checking existence of /Users/mix/Projects/prisma-6.3.1-p1017/prisma/schema.prisma +0ms
# prisma:getSchema Reading schema from single file /Users/mix/Projects/prisma-6.3.1-p1017/prisma/schema.prisma +0ms
# prisma:getSchema Reading schema from multiple files /Users/mix/Projects/prisma-6.3.1-p1017/prisma/schema +1ms
# prisma:loadEnv project root found at /Users/mix/Projects/prisma-6.3.1-p1017/package.json +0ms
# prisma:getSchema prismaConfig {
#   "packagePath": "/Users/mix/Projects/prisma-6.3.1-p1017/package.json"
# } +1ms
# prisma:tryLoadEnv Environment variables loaded from /Users/mix/Projects/prisma-6.3.1-p1017/.env +0ms
# prisma:getConfig Using getConfig Wasm +1ms
# prisma:getConfig config data retrieved without errors in getConfig Wasm +10ms
# prisma:loadEnv project root found at /Users/mix/Projects/prisma-6.3.1-p1017/package.json +0ms
# prisma:getSchema prismaConfig {
#   "packagePath": "/Users/mix/Projects/prisma-6.3.1-p1017/package.json"
# } +0ms
# prisma:tryLoadEnv Environment variables loaded from /Users/mix/Projects/prisma-6.3.1-p1017/.env +1ms
# Environment variables loaded from .env
# prisma:getSchema Reading schema from single file /Users/mix/Projects/prisma-6.3.1-p1017/prisma/schema.prisma +0ms
# Prisma schema loaded from prisma/schema.prisma
# prisma:getSchema Reading schema from single file /Users/mix/Projects/prisma-6.3.1-p1017/prisma/schema.prisma +0ms
# prisma:getConfig Using getConfig Wasm +1ms
# prisma:getConfig config data retrieved without errors in getConfig Wasm +1ms
# Datasource "db": PostgreSQL database "mydb", schema "public" at "localhost:5432"
# 
# prisma:validate Using validate Wasm +1ms
# prisma:getConfig Using getConfig Wasm +8ms
# prisma:getConfig config data retrieved without errors in getConfig Wasm +1ms
# prisma:getSchema Reading schema from single file /Users/mix/Projects/prisma-6.3.1-p1017/prisma/schema.prisma +0ms
# prisma:getConfig Using getConfig Wasm +1ms
# prisma:getConfig config data retrieved without errors in getConfig Wasm +0ms
# prisma:schemaEngine:rpc starting Schema engine with binary: /Users/mix/Projects/prisma-6.3.1-p1017/node_modules/@prisma/engines/schema-engine-darwin-arm64 +39ms
# prisma:getSchema Reading schema from single file /Users/mix/Projects/prisma-6.3.1-p1017/prisma/schema.prisma +0ms
# prisma:getConfig Using getConfig Wasm +0ms
# prisma:getConfig config data retrieved without errors in getConfig Wasm +1ms
# prisma:schemaEngine:rpc SENDING RPC CALL {"id":1,"jsonrpc":"2.0","method":"devDiagnostic","params":{"migrationsDirectoryPath":"/Users/mix/Projects/prisma-6.3.1-p1017/prisma/migrations"}} +1ms
# prisma:schemaEngine:stderr {"timestamp":"2025-02-13T11:43:40.629401Z","level":"INFO","fields":{"message":"Starting schema engine RPC server","git_hash":"acc0b9dd43eb689cbd20c9470515d719db10d0b0"},"target":"schema_engine"} +7ms
# prisma:schemaEngine:stderr {"timestamp":"2025-02-13T11:43:40.761213Z","level":"ERROR","fields":{"message":"Error in PostgreSQL connection: Error { kind: Closed, cause: None }"},"target":"quaint::connector::postgres::native"} +132ms
# prisma:schemaEngine:rpc {
#   "jsonrpc": "2.0",
#   "error": {
#     "code": 4466,
#     "message": "An error happened. Check the data field for details.",
#     "data": {
#       "is_panic": false,
#       "message": "Server has closed the connection.",
#       "meta": null,
#       "error_code": "P1017"
#     }
#   },
#   "id": 1
# } +0ms
# Error: Error: P1017
# 
# Server has closed the connection.
# 
#     at Object.<anonymous> (/Users/mix/Projects/prisma-6.3.1-p1017/node_modules/prisma/build/index.js:990:8)
#     at Vo.handleResponse (/Users/mix/Projects/prisma-6.3.1-p1017/node_modules/prisma/build/index.js:981:2915)
#     at nh.<anonymous> (/Users/mix/Projects/prisma-6.3.1-p1017/node_modules/prisma/build/index.js:986:524)
#     at nh.emit (node:events:519:28)
#     at addChunk (node:internal/streams/readable:559:12)
#     at readableAddChunkPushObjectMode (node:internal/streams/readable:536:3)
#     at Readable.push (node:internal/streams/readable:391:5)
#     at nh._pushBuffer (/Users/mix/Projects/prisma-6.3.1-p1017/node_modules/prisma/build/index.js:975:369)
#     at nh._transform (/Users/mix/Projects/prisma-6.3.1-p1017/node_modules/prisma/build/index.js:975:199)
#     at Transform._write (node:internal/streams/transform:171:8)
```

Postgresql log output:
```log
2025-02-13 11:51:27.322 UTC [1265] ERROR:  relation "_prisma_migrations" does not exist at character 126
2025-02-13 11:51:27.322 UTC [1265] STATEMENT:  SELECT "id", "checksum", "finished_at", "migration_name", "logs", "rolled_back_at", "started_at", "applied_steps_count" FROM "_prisma_migrations" ORDER BY "started_at" ASC
2025-02-13 11:51:27.450 UTC [1266] FATAL:  terminating connection due to administrator command
2025-02-13 11:51:27.553 UTC [66] LOG:  checkpoint starting: immediate force wait
2025-02-13 11:51:27.561 UTC [66] LOG:  checkpoint complete: wrote 4 buffers (0.0%); 0 WAL file(s) added, 0 removed, 0 recycled; write=0.002 s, sync=0.003 s, total=0.008 s; sync files=4, longest=0.002 s, average=0.001 s; distance=4249 kB, estimate=4249 kB; lsn=0/25BF358, redo lsn=0/25BF300
2025-02-13 11:51:34.987 UTC [1284] ERROR:  relation "_prisma_migrations" does not exist at character 126
2025-02-13 11:51:34.987 UTC [1284] STATEMENT:  SELECT "id", "checksum", "finished_at", "migration_name", "logs", "rolled_back_at", "started_at", "applied_steps_count" FROM "_prisma_migrations" ORDER BY "started_at" ASC
2025-02-13 11:51:35.081 UTC [1285] FATAL:  terminating connection due to administrator command
2025-02-13 11:51:35.183 UTC [66] LOG:  checkpoint starting: immediate force wait
2025-02-13 11:51:35.189 UTC [66] LOG:  checkpoint complete: wrote 4 buffers (0.0%); 0 WAL file(s) added, 0 removed, 0 recycled; write=0.001 s, sync=0.001 s, total=0.007 s; sync files=4, longest=0.001 s, average=0.001 s; distance=4250 kB, estimate=4250 kB; lsn=0/29E5B78, redo lsn=0/29E5B20
```


## Verifying DB access

```bash
% kubectl exec -it deployments/postgresql -- psql -U johndoe -d mydb
# Defaulted container "postgresql" out of: postgresql, init-permissions (init)
# psql (17.2 (Debian 17.2-1.pgdg120+1))
# Type "help" for help.
# 
# mydb=# \dt
# Did not find any relations.
# mydb=#
```
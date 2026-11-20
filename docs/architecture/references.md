# Primary technical references

These primary references explain the underlying concepts. The project’s own contracts define its narrower local guarantees.

## Primary references

- SQLite changesets and conflict concepts: https://www.sqlite.org/sessionintro.html
- PostgreSQL logical decoding and repeated delivery considerations: https://www.postgresql.org/docs/current/logicaldecoding-explanation.html
- SQLite atomic commit principles: https://www.sqlite.org/atomiccommit.html

These references explain relevant problems. This application-level protocol does not require native session extensions, PostgreSQL WAL access or compatibility with existing replication products.

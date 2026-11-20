# Primary technical references

This release baseline retains the supplied requirement identifiers and behavioral boundaries. Detailed implementation choices are linked from the component design index.

## Primary references

- SQLite changesets and conflict concepts: https://www.sqlite.org/sessionintro.html
- PostgreSQL logical decoding and repeated delivery considerations: https://www.postgresql.org/docs/current/logicaldecoding-explanation.html
- SQLite atomic commit principles: https://www.sqlite.org/atomiccommit.html

These references explain relevant problems. This application-level protocol does not require native session extensions, PostgreSQL WAL access or compatibility with existing replication products.

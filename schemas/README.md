# Schemas and reference storage model

These JSON Schemas use draft 2020-12 and describe proposed version 1 contracts. They complement the [API contract](../docs/contracts/api.md); the runtime is not implemented yet. The field limits newly made concrete here are proposal defaults, not measured limits or silent changes to the source scope.

| Schema | Purpose |
| --- | --- |
| [record.schema.json](record.schema.json) | Equipment record |
| [operation.schema.json](operation.schema.json) | Immutable replica operation |
| [push-batch.schema.json](push-batch.schema.json) | Bounded push operation batch |
| [resolution.schema.json](resolution.schema.json) | Conflict resolution request |
| [bootstrap-request.schema.json](bootstrap-request.schema.json) | Fresh replica bootstrap request |
| [snapshot-manifest.schema.json](snapshot-manifest.schema.json) | Consistent snapshot manifest |
| [change-page.schema.json](change-page.schema.json) | Consecutive accepted feed page |

[reference-schema.sql](reference-schema.sql) supplies relational keys, foreign keys, enum constraints and indexes. Sections labeled as separate stores belong in separate databases. This is a reference design, not an installed migration. Migration checksums, immutable-field triggers, role checks, byte limits and the complete transaction protocol remain implementation work.

JSON Schema checks structure, not database state. It cannot prove a current revision, consecutive feed/offset range, valid lease, safe retention cutoff or sufficient capacity. Enforce those rules in the accepting transaction. Encoded byte limits, duplicate-key rejection, Unicode/canonicalization and SHA-256 verification also require the parser/domain implementation.

Idempotency-Key, correlation IDs and demo identity normally travel in headers/session context and are not duplicated in these body schemas. Path IDs must agree with any body identity. Examples use fictional readable IDs; resolve names to registered IDs before actual submission.

Concrete record limits proposed here: nonempty label up to 256 characters, category up to 64, quantity integer 0–1,000,000. The conflict batch deliberately mixes replica identities to exercise the hub protocol; ordinary synchronizers submit only their registered replica’s operations.

No schema parser or SQL setup result is a runtime durability acceptance result.

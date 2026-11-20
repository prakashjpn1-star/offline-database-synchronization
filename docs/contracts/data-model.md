# Data model and integrity contract

The data model separates authoritative state, in-progress work, immutable outcomes and audit history. Constraints preserve identity and prevent conflicting records.

## Logical data model

| Store/entity | Required fields and constraints |
| --- | --- |
| Hub Record | Nonnull ID, schema, current revision, payload or tombstone and last mutation sequence. |
| Hub AcceptedEvent | Unique global sequence, mutation/resolution kind, operation identity, full state/revision and digest. |
| Hub OperationReceipt | Unique replica/operation ID, request digest and immutable outcome. |
| Hub Conflict | Original intent/base/current-at-detection, revision, state and resolution reference. |
| Hub Decision | Reviewer, choice, viewed record/conflict versions, reason, new operation and receipt. |
| Hub ReplicaRegistry | Stable identity, compatible schema, status and observed progress metadata. |
| Replica Shadow | Latest accepted record/tombstone and revision; separate from local overlay. |
| Replica Intent/Outbox | Unique operation ID, base revision, immutable proposal/digest, transport/outcome state and receipt link. |
| Replica Checkpoint | Last contiguous applied sequence, source generation and schema. |
| Replica Ownership | Synchronizer instance/epoch, lease and stopped state. |
| SnapshotManifest | Source generation, consistent sequence S, counts, digest and format version. |
| Audit | Ordered mutation/decision/control history with correlation IDs and bounded details. |

Enforce nonnull IDs, positive revisions, unique operation identities, one unresolved local intent per record and foreign keys where local. Validate shadow revision and checkpoint monotonicity. Resolution-only events may reference a record's existing revision without incrementing it. Migration tooling must understand that distinction.

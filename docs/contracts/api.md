# API contract

The API exposes durable mutations and bounded reads. Each operation defines its identity, revision checks, response and retry behavior.

## API contract

| Service and endpoint | Behaviour |
| --- | --- |
| All: GET /api/health and /api/ready | Liveness separate from schema/storage readiness. |
| Replica: GET /api/records | Show shadow, local overlay and pending/conflicted state. |
| Replica: POST /api/records | Durable create intent with client key. |
| Replica: PUT or DELETE /api/records/{id} | Revision-checked local intent; pending-record guard. |
| Replica: GET /api/outbox | Paginated operations, outcomes and uncertain transfers. |
| Replica: POST /api/sync/pause, /resume, /run-once | Explicit local synchronization controls. |
| Hub: POST /internal/replicas/register | Register synthetic identity and schema. |
| Hub: POST /internal/sync/push | Per-operation outcomes for bounded batches. |
| Hub: GET /internal/sync/changes | Consistent ordered feed after checkpoint. |
| Hub: POST /internal/snapshots | Prepare stable bootstrap snapshot and manifest. |
| Hub: GET /api/conflicts and /api/conflicts/{id} | Inspect preserved proposal/base/current alternatives. |
| Hub: POST /api/conflicts/{id}/resolve | Keyed decision with expected versions/digests. |
| All: GET /api/status, /api/audit, /api/metrics | Progress, history, lag, health and transport state. |

Illustrative push operation: `{"operationId":"replica-a-op-001","recordId":"synthetic-001","kind":"UPDATE","baseRevision":3,"value":{"label":"Sample","category":"test","quantity":7}}`. Base revision is captured when the local intent is created, not rewritten to force a stale change through.

All human mutations define keyed replay and optimistic revisions. Return 400 malformed protocol, 422 invalid schema, 403 denied roles, 404 absent target, 409 revision/key conflict, 413 size limit and 503 unavailable store. A business sync conflict is a durable per-operation outcome, distinct from malformed requests or a changed-body idempotency conflict. Lists default to 50/maximum 200 with stable cursors.

## Machine-readable companions

The [schema catalog](../../schemas/README.md) and [worked examples](../../examples/README.md) define proposed request shapes. They add structural checks while the accepting transaction retains responsibility for revisions, authority and state-dependent rules.

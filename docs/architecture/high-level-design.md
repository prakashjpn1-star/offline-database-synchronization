# High-level design

Save an edit even when synchronization is stopped. When the connection returns, keep every unresolved proposal visible, explain conflicts, and bring both replicas to the same accepted state after review.

The hub owns accepted revisions and the global change sequence. A replica owns durable local intent. A successful local save is not a synchronization confirmation.

## System context and deployment

```mermaid
flowchart LR
    A["Replica A browser"] --> RA["Replica A service and store"]
    B["Replica B browser"] --> RB["Replica B service and store"]
    RA --> H["Hub API and accepted state"]
    RB --> H
    R["Conflict reviewer"] --> H
    H --> RA
    H --> RB
```

All runtime services run as ordinary local processes. The browser uses same-origin HTTP, locally bundled assets and no telemetry/CDN. Canonical storage sits on supported local disk outside synchronized folders. Separate consumer/replica stores remain separate correctness boundaries.

## End-to-end sequence

```mermaid
sequenceDiagram
    actor E as Editor
    participant R as Replica
    participant H as Hub
    E->>R: Save proposal against viewed shadow revision
    R->>R: Commit intent, outbox and save receipt
    R-->>E: Saved locally
    R->>H: Push original operation ID and digest
    H->>H: Commit mutation or conflict and receipt
    H-->>R: Per-operation outcome
    R->>H: Pull after committed checkpoint
    H-->>R: Consecutive changes and resolution links
    R->>R: Commit shadow, settled intent and checkpoint
```

## Component responsibilities

| Component | Responsibility |
| --- | --- |
| [Local editing and outbox](../design/local-editing.md) | Read the expected local view revision and reject an existing unresolved intent for this record. |
| [Hub acceptance and receipts](../design/hub-push.md) | Parse and bound the batch, then process each identified operation in its own transaction. |
| [Feed application and checkpoints](../design/pull-checkpoints.md) | Fetch after the last committed checkpoint, optionally bounded by captured high-water mark. |
| [Conflict review and tombstones](../design/conflict-resolution.md) | Load preserved base, proposal, detection-time hub value and current hub value separately. |
| [Consistent snapshot bootstrap](../design/snapshot-bootstrap.md) | Register a new replica identity and compatible source generation. |
| [Synchronizer ownership and recovery](../design/synchronizer.md) | Acquire a replica ownership lease and increment epoch atomically. |
| Control API | Parse requests, enforce roles/revisions/keys, dispatch domain services, return durable outcomes |
| Browser | Explain authoritative state and pending intent without advancing progress locally |
| Storage | Enforce uniqueness, foreign keys, immutable history and atomic mutation boundaries |
| Failure harness | Control exact stop points and query committed-state invariants |

Read the [data model](../contracts/data-model.md), [API contract](../contracts/api.md) and [transaction protocol](../design/transactions.md) together. No in-memory queue, local UI state or process lock is the sole correctness mechanism.

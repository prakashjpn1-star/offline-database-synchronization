# Software requirements specification

The hub owns accepted revisions and the global change sequence. A replica owns durable local intent. A successful local save is not a synchronization confirmation.

## Local editing requirements

| ID | Requirement |
| --- | --- |
| LOC-01 | Create/update/delete validates a bounded record schema and checks expected local view revision. |
| LOC-02 | Saving an intent and inserting its outbox operation commit in the same local transaction before success is shown. |
| LOC-03 | Each operation has a stable unique ID, replica identity, base hub revision, kind, canonical proposed value/digest and creation time. |
| LOC-04 | Initial create uses base revision 0 and succeeds at the hub only if that ID has never existed. |
| LOC-05 | Update/delete captures the last shadow revision seen by the editor. A stale browser tab cannot quietly change that base. |
| LOC-06 | One unresolved operation locks that record for further local edits; show the reason and its pending state. |
| LOC-07 | Browser reload or replica restart preserves intent, operation ID and the distinction from accepted shadow data. |
| LOC-08 | No discard/cancel of a submitted operation is supported initially. Local deletion of outbox rows is not a cancellation protocol. |

Different replicas creating the same record ID conflict rather than silently merging. UI-generated IDs should normally avoid that collision, but the protocol and tests must still handle it. Input content is never executed as SQL, paths or scripts.

## Push protocol and idempotency

| ID | Requirement |
| --- | --- |
| PUSH-01 | Send bounded batches of immutable outbox operations. Stable operation ID/content is preserved across transport retries. |
| PUSH-02 | Hub receipt lookup is scoped by replica/operation ID. Same digest returns the original outcome; changed content conflicts at the protocol level. |
| PUSH-03 | Each operation commits its own atomic outcome. A batch can have mixed results; response identifies every operation separately. |
| PUSH-04 | Accepted mutation, new record revision, hub change event and receipt commit together. |
| PUSH-05 | Conflicted operation, preserved alternatives and its immutable conflict receipt commit together without changing authoritative record data. |
| PUSH-06 | A partially processed batch can be resent in full; committed operations replay receipts and unprocessed operations are processed once. |
| PUSH-07 | Hub retries transaction conflicts as whole operations under bounded backoff. It never confirms an uncommitted write. |

Default batch limit is 100 operations/1 MiB encoded. Per-record payload maximum is 16 KiB. A pending operation transitions LOCAL_PENDING to SENDING, then ACCEPTED_AWAITING_PULL, CONFLICTED or REJECTED. SENDING is transport status, not global authority; after restart, an uncertain SENDING operation is resent under the same ID.

Push responses do not advance the replica's pull checkpoint and do not overwrite its shadow. Accepted intent remains visibly pending until the authoritative change feed applies the accepted event or an explicitly linked later resolution. That prevents a push response followed by an older pull page from moving the shadow backward.

A terminal hub rejection proves that operation made no authoritative mutation. Preserve its proposal and receipt as history, remove its pending overlay and release its local edit lock; a corrected proposal uses a fresh operation ID and newly viewed base revision. A transport error or uncertain response is not a terminal rejection and must never release that lock. Invalid operation contracts return a durable per-operation rejection receipt when identity and digest can be safely parsed; malformed envelopes are rejected before processing.

## Hub revision rules

The hub serializes updates to each record and assigns an increasing global sequence to accepted mutations. Each record revision starts at 1 and increases by 1 on every accepted update or deletion. Revision checks and mutation are one transaction.

Allocate the next feed sequence in the same transaction as a mutation or resolution notification. Rollback does not expose a sequence gap. The feed is contiguous from its initial sequence, including resolution-only notifications, and checkpoints identify the last fully applied sequence rather than a count of record mutations.

| Operation | Required precondition | Outcome |
| --- | --- | --- |
| Create | ID never existed and baseRevision=0 | Create revision 1 and accepted event. |
| Update | Record exists, is not deleted and baseRevision equals current revision | Replace allowed fields; increment revision and append event. |
| Delete | Record exists, is not deleted and baseRevision equals current revision | Persist tombstone, increment revision and append event. |
| Stale update/delete | Base differs, target deleted or target absent | Persist explicit conflict; no silent overwrite or resurrection. |
| Duplicate operation | Same ID and digest already has receipt | Return original receipt without new revision/sequence. |

Record mutation sequences are committed in the hub's durable order, not client timestamps. Concurrent disconnected edits to the same base produce one accepted result and one conflict according to transaction order. Disjoint field edits still conflict at record level; automatic merge is intentionally deferred.

## Accepted change feed and pull

The hub exposes accepted mutations in sequence order with immutable operation identity, record ID, revision, complete post-change state/tombstone and optional resolution linkage. It also exposes low/high sequence bounds. All historical accepted changes are retained in the first release; feed compaction is not supported.

Pull uses `afterSequence`, maximum items/bytes and optional captured `throughSequence` for bounded catch-up. A page returns consecutive feed entries, next checkpoint and high-water mark from one consistent snapshot. Empty pages preserve progress. Duplicate pages are safe; missing or out-of-order pages are rejected rather than skipped.

Applying a pull batch and advancing the local checkpoint commit in one replica transaction. Apply accepted revisions monotonically and validate record progression; unexpected gaps fail readiness for investigation. Do not advance the checkpoint before record writes. A repeated page at/below the checkpoint changes nothing. The hub does not treat a client pull request as proof the replica applied it.

When a feed entry links to the replica's own accepted operation, clear its intent and mark it SYNCHRONIZED in the same transaction as shadow update/checkpoint. When another writer changed that record, preserve unresolved local intent. Conflict resolution events carry enough linkage to settle the corresponding conflicted intent. A replica with no pending/conflicted intents and caught up through a shared high-water mark must have the same canonical authoritative digest as the hub.

## Conflicts and human resolution

Conflict states are OPEN and RESOLVED. Preserve original operation ID, proposed value or deletion, supplied base revision, available base value, authoritative revision/value at conflict creation and relevant history references. Later hub changes do not erase the original conflict. Show current authoritative state separately when reviewing an old conflict.

Supported decisions:

- KEEP_CURRENT: retain the hub record/tombstone and resolve the local proposal without changing record revision.
- APPLY_PROPOSAL: apply the proposed full record or deletion only against the current revision explicitly viewed by the reviewer.
- APPLY_EDITED: apply a schema-validated full record supplied by the reviewer against that viewed revision.

All decisions include expected conflict revision, expected current record revision, current-state digest, operation key and fictional reviewer. A concurrent hub mutation makes a stale decision fail with conflict; it must not silently retry against newer content. Resolution uses a fresh operation identity. Original conflicted-operation receipts remain immutable and continue to report their original conflict outcome.

For an applied resolution, new record revision/change event, decision, conflict settlement and receipt commit together. KEEP_CURRENT also emits a sequenced resolution-notification event, including authoritative state and original operation/conflict identity, so every replica can settle the pending intent without guessing. A resolution-only event does not increment the record revision; consumers distinguish it from a mutation.

When the target is tombstoned, restoring old data is not implicit. APPLY_PROPOSAL/APPLY_EDITED for a deleted target requires an explicit restore confirmation against the tombstone revision, creates a new revision and records a RESTORE mutation. Ordinary updates never restore deleted records.

Two reviewers deciding concurrently yield one accepted decision. A matching key replays the original result; a different conflicting decision receives a settled/stale response. Every alternative and final decision remains auditable.

## Deletion and identity lifetime

Deleted IDs remain reserved through tombstones. No garbage collection of tombstones, operation receipts or accepted history is allowed in the baseline. This costs storage but prevents a long-disconnected replica from resurrecting a forgotten deletion.

Explicit restore is a review operation with a current tombstone revision; generating a new ID creates a different record. Tests must distinguish delete/update, delete/delete, restore/stale-update and two-create collisions. Deleting a replica database is not a supported way to reset its identity: reseeding requires a new replica identity and a fresh bootstrap.

## Bootstrap and snapshot contract

Register a fresh replica identity and obtain a consistent hub snapshot at sequence S. The snapshot includes all authoritative records, tombstones, schema version, manifest/counts and canonical digest. The hub must preserve a consistent snapshot while exporting; naive pagination over changing live rows is insufficient.

Verify and import the snapshot into a new local store atomically or through an isolated staged database plus atomic activation. Set pull checkpoint to S only with the fully imported state. Pull accepted events after S to catch up. Snapshot installation cannot overwrite a replica with unresolved intent; refuse that operation and preserve its existing store.

A corrupt, partial, incompatible or mixed-version snapshot is rejected without replacing the current state. First release retains the whole change feed, so no expired-cursor protocol is needed. Limits and storage pressure must still be reported.

## Synchronizer lifecycle and recovery

Per replica, the synchronizer is STOPPED, IDLE, PUSHING, PULLING, BACKOFF, PAUSED or ERROR. Durable records, not this process state, determine actual progress. The operator can pause push, pull or both to demonstrate disconnection; local editing remains available where record-level pending constraints allow it.

Allow one authorized synchronization process per replica using a lease/epoch or an equivalent tested local ownership mechanism. A stale synchronizer cannot regress checkpoints or alter operation outcomes. Default ownership lease is 15 seconds with 5-second heartbeat. Each replica's database serializes edit, pull-apply and local outcome transitions.

On restart recover pending/uncertain outbox operations with their original IDs, read the last committed checkpoint and resume bounded batches. Database/API uncertainty triggers bounded backoff without fabricated acceptance. Graceful shutdown stops new transfers and completes bounded local transactions. Hard stop relies on durable receipts and atomic local apply.

## Failure and transaction boundaries

| Stop point | Required recovery |
| --- | --- |
| Before local edit/outbox commit | Neither intent nor outbox is visible. |
| After local commit before browser response | Same client key returns the original saved intent. |
| After hub accepts operation before response | Same operation ID returns original revision/sequence. |
| Halfway through push batch | Resend entire batch; previously accepted items replay outcomes. |
| During local pull application | Rollback leaves old shadow and checkpoint; retry same page. |
| After pull commit before response | Duplicate page is recognized and does not reapply effects. |
| Before resolution commit | Conflict remains open with unchanged authoritative state. |
| After resolution commit before response | Keyed replay returns original decision and sequence. |

No transaction is assumed to span hub and replica databases. Correctness comes from stable IDs, immutable receipts and atomic local boundaries. Document isolation, lock order, conflict retries and linearization. Never hold a database write lock during network I/O or human review.

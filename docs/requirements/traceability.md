# Requirement traceability

Every source section is covered below, including requirements stated in prose. Every numbered acceptance case is retained verbatim in the acceptance plan. Coverage describes intended verification, not test success.

| Source section | Requirement/design coverage | Verification |
| --- | --- | --- |
| 1 Purpose and outcome | [Contract](../requirements/product.md) | Acceptance plan and milestone gate |
| 2 People and motivating use case | [Contract](../requirements/product.md) | Acceptance plan and milestone gate |
| 3 Environment and scope | [Contract](../requirements/product.md) | Acceptance plan and milestone gate |
| 4 Topology and authority | [Contract](../requirements/product.md) | Acceptance plan and milestone gate |
| 5 Data and canonical fixture | [Contract](../requirements/product.md) | Acceptance plan and milestone gate |
| 6 Core records and semantics | [Contract](../requirements/product.md); [Design](../design/local-editing.md) | Acceptance plan and milestone gate |
| 7 Local editing requirements | [Contract](../requirements/software.md); [Design](../design/local-editing.md) | Acceptance plan and milestone gate |
| 8 Push protocol and idempotency | [Contract](../requirements/software.md); [Design](../design/hub-push.md) | Acceptance plan and milestone gate |
| 9 Hub revision rules | [Contract](../requirements/software.md); [Design](../design/hub-push.md) | Acceptance plan and milestone gate |
| 10 Accepted change feed and pull | [Contract](../requirements/software.md); [Design](../design/pull-checkpoints.md) | Acceptance plan and milestone gate |
| 11 Conflicts and human resolution | [Contract](../requirements/software.md); [Design](../design/conflict-resolution.md) | Acceptance plan and milestone gate |
| 12 Deletion and identity lifetime | [Contract](../requirements/software.md); [Design](../design/conflict-resolution.md) | Acceptance plan and milestone gate |
| 13 Bootstrap and snapshot contract | [Contract](../requirements/software.md); [Design](../design/snapshot-bootstrap.md) | Acceptance plan and milestone gate |
| 14 Synchronizer lifecycle and recovery | [Contract](../requirements/software.md); [Design](../design/synchronizer.md) | Acceptance plan and milestone gate |
| 15 Failure and transaction boundaries | [Contract](../requirements/software.md); [Design](../design/hub-push.md) | Acceptance plan and milestone gate |
| 16 Logical data model | [Contract](../contracts/data-model.md) | Acceptance plan and milestone gate |
| 17 API contract | [Contract](../contracts/api.md) | Acceptance plan and milestone gate |
| 18 Browser journeys | [Contract](../requirements/browser-journeys.md) | Acceptance plan and milestone gate |
| 19 Local access and policy requirements | [Contract](../security/access-and-threats.md) | Acceptance plan and milestone gate |
| 20 Observability backup and resource limits | [Contract](../operations/runbook.md) | Acceptance plan and milestone gate |
| 21 Acceptance catalog | [Contract](../testing/acceptance-plan.md) | Acceptance plan and milestone gate |
| 22 Test strategy and invariants | [Contract](../testing/acceptance-plan.md) | Acceptance plan and milestone gate |
| 23 Session milestones | [Contract](../delivery/implementation-plan.md) | Acceptance plan and milestone gate |
| 24 Deliverables and release gate | [Contract](../delivery/implementation-plan.md) | Acceptance plan and milestone gate |
| 25 Primary references | [Contract](../architecture/references.md) | Acceptance plan and milestone gate |

## Numbered functional requirements

| Source ID | Required behavior | Design |
| --- | --- | --- |
| LOC-01 | Create/update/delete validates a bounded record schema and checks expected local view revision. | [Local editing and outbox](../design/local-editing.md) |
| LOC-02 | Saving an intent and inserting its outbox operation commit in the same local transaction before success is shown. | [Local editing and outbox](../design/local-editing.md) |
| LOC-03 | Each operation has a stable unique ID, replica identity, base hub revision, kind, canonical proposed value/digest and creation time. | [Local editing and outbox](../design/local-editing.md) |
| LOC-04 | Initial create uses base revision 0 and succeeds at the hub only if that ID has never existed. | [Local editing and outbox](../design/local-editing.md) |
| LOC-05 | Update/delete captures the last shadow revision seen by the editor. A stale browser tab cannot quietly change that base. | [Local editing and outbox](../design/local-editing.md) |
| LOC-06 | One unresolved operation locks that record for further local edits; show the reason and its pending state. | [Local editing and outbox](../design/local-editing.md) |
| LOC-07 | Browser reload or replica restart preserves intent, operation ID and the distinction from accepted shadow data. | [Local editing and outbox](../design/local-editing.md) |
| LOC-08 | No discard/cancel of a submitted operation is supported initially. Local deletion of outbox rows is not a cancellation protocol. | [Local editing and outbox](../design/local-editing.md) |
| PUSH-01 | Send bounded batches of immutable outbox operations. Stable operation ID/content is preserved across transport retries. | [Hub acceptance and receipts](../design/hub-push.md) |
| PUSH-02 | Hub receipt lookup is scoped by replica/operation ID. Same digest returns the original outcome; changed content conflicts at the protocol level. | [Hub acceptance and receipts](../design/hub-push.md) |
| PUSH-03 | Each operation commits its own atomic outcome. A batch can have mixed results; response identifies every operation separately. | [Hub acceptance and receipts](../design/hub-push.md) |
| PUSH-04 | Accepted mutation, new record revision, hub change event and receipt commit together. | [Hub acceptance and receipts](../design/hub-push.md) |
| PUSH-05 | Conflicted operation, preserved alternatives and its immutable conflict receipt commit together without changing authoritative record data. | [Hub acceptance and receipts](../design/hub-push.md) |
| PUSH-06 | A partially processed batch can be resent in full; committed operations replay receipts and unprocessed operations are processed once. | [Hub acceptance and receipts](../design/hub-push.md) |
| PUSH-07 | Hub retries transaction conflicts as whole operations under bounded backoff. It never confirms an uncommitted write. | [Hub acceptance and receipts](../design/hub-push.md) |

## Acceptance coverage

| Source case | Durable acceptance oracle | Status |
| --- | --- | --- |
| SY-AC-01 | Bootstrap both replicas from one snapshot S; digests/counts match and subsequent pull starts after S. | NOT RUN |
| SY-AC-02 | Partial/corrupt snapshot or installation over unresolved intent is rejected without losing local state. | NOT RUN |
| SY-AC-03 | Local save and outbox insertion are atomic; browser/replica restart preserves accepted local intent. | NOT RUN |
| SY-AC-04 | Lost local-save response replays one intent under the same client key. | NOT RUN |
| SY-AC-05 | Pause transport; distinct-record edits survive locally and converge after resume. | NOT RUN |
| SY-AC-06 | Same-record updates from one base produce one accepted change and one preserved conflict. | NOT RUN |
| SY-AC-07 | Create/create collision is explicit; update/delete and delete/delete do not silently overwrite or resurrect. | NOT RUN |
| SY-AC-08 | Repeat operation ID returns original outcome; changed payload with that ID is rejected. | NOT RUN |
| SY-AC-09 | Hub crash after acceptance before response yields one revision/change event on retry. | NOT RUN |
| SY-AC-10 | Partially accepted push batch can be retried without duplicate mutations. | NOT RUN |
| SY-AC-11 | Pull crash before local commit preserves old shadow/checkpoint; retry applies once. | NOT RUN |
| SY-AC-12 | Duplicate/out-of-order pull pages do not regress or skip local progress. | NOT RUN |
| SY-AC-13 | Remote pull updates shadow while preserving unresolved local overlay and conflict evidence. | NOT RUN |
| SY-AC-14 | Accepted push does not advance pull cursor or let older feed events overwrite a newer shadow. | NOT RUN |
| SY-AC-15 | KEEP_CURRENT settles intent through a resolution event without a fake record revision. | NOT RUN |
| SY-AC-16 | APPLY_PROPOSAL/APPLY_EDITED creates the viewed revision's authorized result and one decision receipt. | NOT RUN |
| SY-AC-17 | Concurrent reviewer decisions or a newer hub edit reject stale resolution without data loss. | NOT RUN |
| SY-AC-18 | Resolution response lost after commit replays one decision; original conflict receipt remains unchanged. | NOT RUN |
| SY-AC-19 | Tombstone resists stale updates; explicit confirmed restore creates a fresh revision and visible history. | NOT RUN |
| SY-AC-20 | Additional local edit on pending record is blocked; two browser tabs cannot create hidden local chains. | NOT RUN |
| SY-AC-21 | Competing/stale synchronizers cannot regress checkpoints or duplicate accepted operations. | NOT RUN |
| SY-AC-22 | Hub/replica storage outage produces no false acceptance; retries resume stable IDs after recovery. | NOT RUN |
| SY-AC-23 | Canonical conflict fixture yields the prescribed final hash on hub and both replicas after all decisions/catch-up. | NOT RUN |
| SY-AC-24 | Large 10,000-operation stress fixture preserves IDs/revisions/history and converges after prescribed resolutions. | NOT RUN |
| SY-AC-25 | Browser stale-state, authorization, size, origin and input-boundary tests pass. | NOT RUN |
| SY-AC-26 | Coordinated backup/restore preserves receipts, pending intent, tombstones and convergence. | NOT RUN |
| SY-AC-27 | Entire edit/disconnect/sync/review/recover journey works with external connectivity disabled. | NOT RUN |

# Acceptance and failure-test plan

Acceptance scenarios check committed records at controlled failure boundaries. Every case remains NOT RUN until implementation evidence is recorded.

## Acceptance catalog

| ID | Scenario and required result |
| --- | --- |
| SY-AC-01 | Bootstrap both replicas from one snapshot S; digests/counts match and subsequent pull starts after S. |
| SY-AC-02 | Partial/corrupt snapshot or installation over unresolved intent is rejected without losing local state. |
| SY-AC-03 | Local save and outbox insertion are atomic; browser/replica restart preserves accepted local intent. |
| SY-AC-04 | Lost local-save response replays one intent under the same client key. |
| SY-AC-05 | Pause transport; distinct-record edits survive locally and converge after resume. |
| SY-AC-06 | Same-record updates from one base produce one accepted change and one preserved conflict. |
| SY-AC-07 | Create/create collision is explicit; update/delete and delete/delete do not silently overwrite or resurrect. |
| SY-AC-08 | Repeat operation ID returns original outcome; changed payload with that ID is rejected. |
| SY-AC-09 | Hub crash after acceptance before response yields one revision/change event on retry. |
| SY-AC-10 | Partially accepted push batch can be retried without duplicate mutations. |
| SY-AC-11 | Pull crash before local commit preserves old shadow/checkpoint; retry applies once. |
| SY-AC-12 | Duplicate/out-of-order pull pages do not regress or skip local progress. |
| SY-AC-13 | Remote pull updates shadow while preserving unresolved local overlay and conflict evidence. |
| SY-AC-14 | Accepted push does not advance pull cursor or let older feed events overwrite a newer shadow. |
| SY-AC-15 | KEEP_CURRENT settles intent through a resolution event without a fake record revision. |
| SY-AC-16 | APPLY_PROPOSAL/APPLY_EDITED creates the viewed revision's authorized result and one decision receipt. |
| SY-AC-17 | Concurrent reviewer decisions or a newer hub edit reject stale resolution without data loss. |
| SY-AC-18 | Resolution response lost after commit replays one decision; original conflict receipt remains unchanged. |
| SY-AC-19 | Tombstone resists stale updates; explicit confirmed restore creates a fresh revision and visible history. |
| SY-AC-20 | Additional local edit on pending record is blocked; two browser tabs cannot create hidden local chains. |
| SY-AC-21 | Competing/stale synchronizers cannot regress checkpoints or duplicate accepted operations. |
| SY-AC-22 | Hub/replica storage outage produces no false acceptance; retries resume stable IDs after recovery. |
| SY-AC-23 | Canonical conflict fixture yields the prescribed final hash on hub and both replicas after all decisions/catch-up. |
| SY-AC-24 | Large 10,000-operation stress fixture preserves IDs/revisions/history and converges after prescribed resolutions. |
| SY-AC-25 | Browser stale-state, authorization, size, origin and input-boundary tests pass. |
| SY-AC-26 | Coordinated backup/restore preserves receipts, pending intent, tombstones and convergence. |
| SY-AC-27 | Entire edit/disconnect/sync/review/recover journey works with external connectivity disabled. |

All cases start NOT RUN. Record commit, environment, seed, operation IDs, checkpoint/sequence ranges, expected/actual digests, barriers, receipts and invariant evidence.

## Test strategy and invariants

Unit tests cover record validation, revision guards, canonicalization, state transitions and merge-decision construction. Storage integration tests exercise uniqueness, transactions and rollback. Multi-process tests run the actual three-store topology with controlled transport pause/drop/duplicate/reorder. Browser tests exercise both replicas and conflicting review tabs.

Place deterministic barriers around local save commit, hub acceptance commit, partial batch boundary, local pull commit and resolution commit. Repeat each crash window at least 20 times and conflicting writers/reviewers/synchronizers at least 100 rounds. Retain failing seeds. Run a 30-minute bounded soak with alternating transport pause/resume.

Invariants: operation IDs never change content; each accepted operation produces one authoritative mutation; record revisions never regress; local checkpoint advances only with fully applied feed entries; unresolved local intent is preserved; stale updates do not erase tombstones; only one resolution wins; synchronized replicas agree through the same high-water mark. Convergence assumes transport resumes and every blocking conflict receives a decision; do not promise automatic convergence with unresolved human choices.

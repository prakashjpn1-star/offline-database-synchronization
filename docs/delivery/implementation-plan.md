# Delivery milestones and definition of done

This release baseline retains the supplied requirement identifiers and behavioral boundaries. Detailed implementation choices are linked from the component design index.

## Session milestones

| Milestone | Checkable exit |
| --- | --- |
| 1 | Verify tools; implement three local stores/services, record schema and readiness. |
| 2 | Implement local intent/outbox and browser edit guards; atomic-save tests pass. |
| 3 | Implement hub receipts/revisions and push; retries cannot duplicate acceptance. |
| 4 | Implement ordered feed and atomic pull/checkpoints; interrupted apply recovers. |
| 5 | Implement consistent bootstrap snapshot and generation checks. |
| 6 | Implement conflict preservation, decisions, resolution events and tombstones. |
| 7 | Implement synchronizer ownership, backoff and restart races. |
| 8 | Complete both replica UIs, review, lag and error diagnostics. |
| 9 | Execute canonical/stress/crash/soak/offline/restore acceptance and record limitations. |

Milestones may span several sessions. Save commits/checkpoints, actual tests, unresolved defects and continuation notes. Never replace failed evidence with a fresh generated all-pass report.

## Deliverables and release gate

Deliver source/licence notices, schemas/migrations, local startup/shutdown scripts, hub/replica protocol contracts, browser application, deterministic fixtures and independent expected outputs, failure harness, acceptance report, measurements, backup/restore guide and design decisions.

Release requires all mandatory acceptance cases/repetition counts, correct final fixture digests, a repeatable offline setup and no unresolved defect invalidating preservation or convergence guarantees. Choose language/framework, one local store, serialization, identity-generation policy and exact configured bounds before implementation; no specific language is required here.

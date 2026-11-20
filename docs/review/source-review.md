# Source review and resolved design questions

The main design risks concern the boundary between a committed outcome and a lost response. The following decisions address those risks; runtime acceptance evidence is still pending.

| Question or risk | Design response |
| --- | --- |
| A push receipt must never advance the pull checkpoint. | Push records an operation outcome only. The replica advances its checkpoint when the linked feed page commits locally. |
| A live-page bootstrap can combine incompatible revisions. | Bootstrap exports one stable snapshot at sequence S and activates the verified staged store atomically. |
| Preserved conflicts mean convergence depends on explicit human decisions. | Conflict alternatives remain available until a revision-checked decision emits a linked resolution notification. |
| Three independently timed live backups are not a consistent system snapshot. | Backup quiesces the hub and both replicas and preserves their stores, identities and checkpoints as one restore set. |
| Dependency compatibility | Python and SQLite are the reference stack. Exact framework/library versions depend on the permitted environment inventory. |
| Expected hashes not yet generated | Require deterministic generator and independent oracle; keep actual result fields unfilled. |
| Durability confused with exactly-once effects | State acceptance, delivery and local-effect guarantees separately. |
| Generated evidence overwritten | Keep result reports separate; no build script regenerates executed acceptance outcomes. |

New design choices are labeled proposed: explicit SQLite writer serialization, canonical JSON library, one-second browser polling and conservative recovery. Open items include exact versions, configured hard caps, workload measurements and immutable-field migration enforcement.

The original requirements remain archived for traceability. Programme eligibility and participant authorship are assessed separately from these technical design decisions.

# Quality requirements and measurable targets

Correctness comes first: no fabricated confirmation, no stale authority mutation, and no loss of accepted history. Performance figures remain provisional until measured on the supplied desktop.


Metrics include unresolved outbox count/age, checkpoint lag, push/pull throughput, duplicate operations, open conflicts, stale resolution rejections, retry/backoff count and storage size. Audit local intent save, hub acceptance/conflict, decisions, snapshot install and pause/resume. Include replica, operation, record, conflict and sequence IDs without leaking tokens.

Keep schema migrations versioned and explicit. Refuse incompatible/newer schema; never auto-reset a database. For a complete demo restore, stop hub/replica services and take coordinated consistent snapshots of all three stores, identities, receipts and checkpoints. Restore into isolated directories with fresh synchronizer process instances. A restored replica from a different hub generation must be rejected rather than silently synced. Do not overwrite evidence when regenerating templates.

No tombstone/feed receipt garbage collection means storage grows with accepted history. Enforce configurable caps and return backpressure without deleting unresolved intent. Initial targets: 10,000 current records, 100,000 accepted history entries, two replicas, 100-operation/1 MiB batches, 16 KiB records, p95 local edit under 500 ms, 1,000 nonconflicting operations synchronized to both replicas within 60 seconds after resume on a healthy desktop, UI state within 3 seconds and total services/stores under 2 GiB RAM excluding browser/build. Measure rather than promise these targets. Conflicts requiring human decisions are excluded from automatic convergence latency.



## Shared release criteria

The complete journey works offline with loopback available, ordinary local processes and synthetic data. Browser state uses confirmed server revisions, text labels and keyboard-accessible equivalents. Inputs, pages, logs and artifact/record sizes are bounded before expensive work.

Measure p50/p95/max where relevant, record warm-up/sample count and retain raw failures. Every report includes build/commit, CPU/RAM/OS, store/interpreter/package versions, durability settings, worker counts, payload sizes, fixture seed and exact method. Do not silently relax a target or remove a slow sample.

Run crash windows at least 20 times, contention/authority races at least 100 rounds, and a bounded 30-minute soak. Report NOT RUN until evidence exists. Actual reports are separate from regenerable templates.

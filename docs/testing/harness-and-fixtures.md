# Failure harness and deterministic fixtures

Generate 1,000 initial equipment records using a fixed seed. Keep a small conflict script with prescribed decisions and an independent expected final digest, plus a 10,000-operation stress fixture. The digest includes sorted IDs, revisions, tombstones and canonical values; it excludes overlays and transport time.

```mermaid
flowchart LR
    Scenario["Scenario ID and seed"] --> Supervisor["Local process supervisor and barriers"]
    Supervisor --> Services["Actual services and workers"]
    Services --> Stores[("Isolated transactional stores")]
    Stores --> Assertions["Committed-state invariant checks"]
    Supervisor --> Evidence["Receipts, snapshots, timings and logs"]
    Assertions --> Evidence
```

Each test owns a fresh runtime directory, database paths, loopback ports, synthetic identities and tracked PIDs. Only stop processes created by this harness. Fault controls are disabled by default and require explicit test mode and a separate disposable local capability. No fault endpoint should be callable in ordinary operation.

Use acknowledged named barriers before commit, after commit before response, after grant/fetch, before progress application, and around authority replacement. Kill the process that owns the transaction when proving rollback; dropping a response after commit is a different experiment. No random sleep substitutes for a proven boundary.

Repeat each crash window at least 20 times; conflicting/ownership/contention races at least 100 rounds. Preserve failing seeds and rounds. Run a bounded 30-minute soak and the complete journey offline with loopback available. Hash expected output using an independent oracle and canonical ordering; actual hashes are NOT GENERATED until implementation.

Record build/commit, OS/CPU/RAM/store versions, durability settings, configuration, fixture seed, IDs/ranges, barrier acknowledgements, before/after snapshots, HTTP receipts, timing and invariant outcome. [Acceptance plan](acceptance-plan.md) supplies every source case. Runtime tests are NOT RUN.

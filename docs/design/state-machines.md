# State machines and control races

```mermaid
stateDiagram-v2
    [*] --> LOCAL_PENDING
    LOCAL_PENDING --> SENDING: bounded transfer
    SENDING --> ACCEPTED_AWAITING_PULL: accepted receipt
    SENDING --> CONFLICTED: preserved conflict
    SENDING --> REJECTED: durable terminal rejection
    SENDING --> SENDING: uncertain response uses same ID
    ACCEPTED_AWAITING_PULL --> SYNCHRONIZED: linked feed applied
    CONFLICTED --> SYNCHRONIZED: resolution notification applied
    SYNCHRONIZED --> [*]
    REJECTED --> [*]
```

Terminal outcomes do not reopen. Idempotent replay returns an existing receipt; it does not repeat a transition. Controls use expected revisions, persisted state and the transaction protocol.

The hub owns accepted revisions and the global change sequence. A replica owns durable local intent. A successful local save is not a synchronization confirmation.

## Race matrix

| Race | Required result |
| --- | --- |
| New mutation versus matching retry | Return one original outcome; changed content conflicts |
| Current owner versus replacement | Epoch/generation determines authority; stale update rejected |
| Control versus new work | First valid serialized transition determines admission |
| Completion versus deadline | Check durable time inside writer; expired authority cannot make a new commit |
| Read versus retention/snapshot transition | Return one consistent state and bounds or an explicit error |
| Commit versus lost response | Replay receipt; do not infer rollback from transport failure |

The component documents supply additional source state values and exact transitions. Each race must be tested in both orders using deterministic barriers.

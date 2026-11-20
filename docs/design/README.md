# Low-level component designs

Every component follows the same [transaction rules](transactions.md), [API errors](../contracts/api.md) and [data constraints](../contracts/data-model.md).

- [Local editing and outbox](local-editing.md)
- [Hub acceptance and receipts](hub-push.md)
- [Feed application and checkpoints](pull-checkpoints.md)
- [Conflict review and tombstones](conflict-resolution.md)
- [Consistent snapshot bootstrap](snapshot-bootstrap.md)
- [Synchronizer ownership and recovery](synchronizer.md)
- [State machines](state-machines.md)
- [Browser and control API](browser-and-api.md)
- [Observability](observability.md)

Each design includes an algorithm, diagram, atomicity/recovery behavior and applicable source contracts. The [test harness](../testing/harness-and-fixtures.md) defines evidence required to prove the design.

- [Storage and entity relationships](storage.md)

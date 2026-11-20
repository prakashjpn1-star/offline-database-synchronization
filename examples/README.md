# Worked examples

These are small fictional request and protocol examples, not the canonical stress fixtures or recorded test results. Each JSON file has a corresponding schema. Digest-bearing decision inputs must use actual canonical digests fetched from the current reviewed state; no invented digest is supplied here.

| Example | Schema | What it demonstrates |
| --- | --- | --- |
| [create-operation.json](create-operation.json) | [operation](../schemas/operation.schema.json) | A new record reserves a never-used ID; send the identical operation on retry. |
| [conflicting-updates.json](conflicting-updates.json) | [push-batch](../schemas/push-batch.schema.json) | With hub revision 3, one update wins and the other is preserved as a conflict. This is a protocol test envelope; the server must verify each replica identity. |
| [delete-operation.json](delete-operation.json) | [operation](../schemas/operation.schema.json) | Deletion keeps a tombstone and cannot be implemented by removing all history. |
| [bootstrap-request.json](bootstrap-request.json) | [bootstrap-request](../schemas/bootstrap-request.schema.json) | Install only into a fresh replica without unresolved intent. |
| [resolution-notification-page.json](resolution-notification-page.json) | [change-page](../schemas/change-page.schema.json) | KEEP_CURRENT advances sequence to 10 while record revision remains 4. Apply shadow, linked intent settlement and checkpoint together. |

Submit mutations with a stable Idempotency-Key and the appropriate fictional role/registered process. Retry the same intent with the same key and body after an uncertain response. A new edited intent needs a new key. An accepted response is required before the browser displays success.

Actual generated large fixtures, independent expected-output hashes and crash evidence are future implementation deliverables. These files claim no measured results.

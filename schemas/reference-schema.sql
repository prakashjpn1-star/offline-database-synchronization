-- Design reference. Run hub and replica sections in separate databases.
-- Add migration checksums and immutable-field triggers before implementation release.
PRAGMA foreign_keys=ON;
-- HUB STORE
CREATE TABLE hub_meta(id INTEGER PRIMARY KEY CHECK(id=1), generation TEXT NOT NULL, next_sequence INTEGER NOT NULL CHECK(next_sequence>0));
CREATE TABLE replicas(id TEXT PRIMARY KEY, schema_version INTEGER NOT NULL, status TEXT NOT NULL);
CREATE TABLE records(id TEXT PRIMARY KEY, revision INTEGER NOT NULL CHECK(revision>0), deleted INTEGER NOT NULL CHECK(deleted IN(0,1)), value_json TEXT, last_sequence INTEGER NOT NULL, CHECK((deleted=1 AND value_json IS NULL) OR (deleted=0 AND value_json IS NOT NULL AND json_valid(value_json))));
CREATE TABLE operation_receipts(replica_id TEXT NOT NULL REFERENCES replicas(id), operation_id TEXT NOT NULL, digest TEXT NOT NULL CHECK(length(digest)=64), outcome TEXT NOT NULL CHECK(outcome IN('ACCEPTED','CONFLICTED','REJECTED')), response_json TEXT NOT NULL CHECK(json_valid(response_json)), PRIMARY KEY(replica_id,operation_id));
CREATE TABLE accepted_events(sequence INTEGER PRIMARY KEY CHECK(sequence>0), kind TEXT NOT NULL CHECK(kind IN('CREATE','UPDATE','DELETE','RESTORE','RESOLUTION')), record_id TEXT NOT NULL REFERENCES records(id), revision INTEGER NOT NULL CHECK(revision>0), operation_id TEXT NOT NULL, state_json TEXT NOT NULL CHECK(json_valid(state_json)), resolved_operation_id TEXT, conflict_id TEXT);
CREATE TABLE conflicts(id TEXT PRIMARY KEY, replica_id TEXT NOT NULL, operation_id TEXT NOT NULL, revision INTEGER NOT NULL CHECK(revision>0), state TEXT NOT NULL CHECK(state IN('OPEN','RESOLVED')), alternatives_json TEXT NOT NULL CHECK(json_valid(alternatives_json)), UNIQUE(replica_id,operation_id), FOREIGN KEY(replica_id,operation_id) REFERENCES operation_receipts(replica_id,operation_id));
CREATE TABLE decisions(id TEXT PRIMARY KEY, conflict_id TEXT NOT NULL UNIQUE REFERENCES conflicts(id), actor TEXT NOT NULL, choice TEXT NOT NULL CHECK(choice IN('KEEP_CURRENT','APPLY_PROPOSAL','APPLY_EDITED')), request_digest TEXT NOT NULL, viewed_record_revision INTEGER NOT NULL, decision_json TEXT NOT NULL CHECK(json_valid(decision_json)));
CREATE TABLE control_receipts(actor TEXT NOT NULL, operation TEXT NOT NULL, target TEXT NOT NULL, request_key TEXT NOT NULL, request_digest TEXT NOT NULL, response_json TEXT NOT NULL, PRIMARY KEY(actor,operation,target,request_key));
CREATE TABLE snapshots(id TEXT PRIMARY KEY, source_generation TEXT NOT NULL, through_sequence INTEGER NOT NULL, manifest_json TEXT NOT NULL CHECK(json_valid(manifest_json)), payload BLOB NOT NULL);
CREATE INDEX open_conflicts ON conflicts(state,id);
-- REPLICA STORE (no cross-store foreign keys)
CREATE TABLE shadow(record_id TEXT PRIMARY KEY, revision INTEGER NOT NULL CHECK(revision>0), deleted INTEGER NOT NULL CHECK(deleted IN(0,1)), value_json TEXT, view_revision INTEGER NOT NULL CHECK(view_revision>0));
CREATE TABLE outbox(operation_id TEXT PRIMARY KEY, replica_id TEXT NOT NULL, record_id TEXT NOT NULL, base_revision INTEGER NOT NULL CHECK(base_revision>=0), kind TEXT NOT NULL CHECK(kind IN('CREATE','UPDATE','DELETE')), proposal_json TEXT NOT NULL CHECK(json_valid(proposal_json)), digest TEXT NOT NULL, state TEXT NOT NULL CHECK(state IN('LOCAL_PENDING','SENDING','ACCEPTED_AWAITING_PULL','CONFLICTED','REJECTED','SYNCHRONIZED')), created_at INTEGER NOT NULL, receipt_json TEXT);
CREATE UNIQUE INDEX one_unresolved_record ON outbox(record_id) WHERE state IN('LOCAL_PENDING','SENDING','ACCEPTED_AWAITING_PULL','CONFLICTED');
CREATE INDEX outbox_pending ON outbox(state,created_at,operation_id);
CREATE TABLE checkpoint(id INTEGER PRIMARY KEY CHECK(id=1), source_generation TEXT NOT NULL, sequence INTEGER NOT NULL CHECK(sequence>=0));
CREATE TABLE ownership(id INTEGER PRIMARY KEY CHECK(id=1), instance_id TEXT, epoch INTEGER NOT NULL CHECK(epoch>=0), lease_expires_at INTEGER);
CREATE TABLE local_save_receipts(actor TEXT NOT NULL, request_key TEXT NOT NULL, request_digest TEXT NOT NULL, operation_id TEXT NOT NULL REFERENCES outbox(operation_id), response_json TEXT NOT NULL, PRIMARY KEY(actor,request_key));
CREATE TABLE local_audit(sequence INTEGER PRIMARY KEY, event_type TEXT NOT NULL, entity_id TEXT NOT NULL, payload_json TEXT NOT NULL CHECK(json_valid(payload_json)));
-- Transaction guards enforce contiguous feed, monotonic revisions/checkpoint and current ownership.

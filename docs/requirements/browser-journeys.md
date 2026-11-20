# Browser journeys and accessibility

This release baseline retains the supplied requirement identifiers and behavioral boundaries. Detailed implementation choices are linked from the component design index.

## Browser journeys

Provide separate labeled replica A/B workspaces; a hub record/change-feed view; outbox with local/accepted/conflicted/synchronized states; pause controls and connection indicators; conflict comparison/resolution; bootstrap/readiness diagnostics; and history/search.

Never show locally saved as globally synchronized. Mark accepted-awaiting-pull separately. Conflict UI displays base, proposed, detection-time hub state and current hub state; the reviewer confirms exactly the current revision/digest used in a decision. Restoring a deletion needs explicit wording. Preserve a stale review for comparison and require refresh before resubmission.

Browser refresh leaves intent and checkpoints unchanged. Two tabs editing one replica need optimistic guards. Keyboard operation and textual state labels are required. Bundle all assets locally, provide loading/empty/disconnected/error states, and avoid success before durable confirmation.

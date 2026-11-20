# Local access and threat model

This release baseline retains the supplied requirement identifiers and behavioral boundaries. Detailed implementation choices are linked from the component design index.

## Local access and policy requirements

Use only synthetic records and fictional editor/operator/reviewer identities. Bind services to loopback and check same-origin/Host for browser mutations. Separate local synchronization credentials from demo browser roles if tokens are used; generate disposable values and keep them out of URLs, logs and source. No real account authentication is needed.

Reject arbitrary paths, URLs, SQL fragments, scripts, oversized fields, invalid Unicode, duplicate JSON keys and nonfinite values. Fault-injection controls are enabled only in explicit test mode. Normal application login/access checks are within scope; hostile-code research is not part of this project.

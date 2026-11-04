## Context

Every schema an mdp pipeline writes is listed in `cicd_writable_schemas`; the grants follow from the list.

## Decisions

- Grant only `gold_analytics_gateway`, the one the story writes. The other two gold schemas stay as they are.

## Risks / Trade-offs

- None beyond a plan that adds grants only; the plan is read in full before apply.

---
description: Generate and enrich the Product Requirements Prompt (PRP) runbook from current artifacts.
scripts:
  sh: scripts/bash/create-prp.sh --json
  ps: scripts/powershell/create-prp.ps1 -Json
---

The user input to you can be provided directly by the agent or as a command argument - you **MUST** consider it before proceeding with the prompt (if not empty).

User input:

$ARGUMENTS

When to use:
- Run early, right after `/specify` (and after `/clarify` if needed) to align scope, context, and validation gates before planning.
- Run again after `/implement` to refresh the Evidence Ledger and lock in gate results.

Your objective is to produce a complete PRP dossier that aligns specification, plan, tasks, and quality gates. Follow these steps:

1. Run `{SCRIPT}` from the repository root. Capture the JSON output for `PRP_FILE` and `FEATURE_BRANCH`.
2. Load the generated PRP file. Sections are pre-populated with artifact paths—use them to ingest context (spec, plan, tasks, research, data model, contracts, quickstart).
3. Populate every section marked with guidance:
   - Summarize Goal & Strategic Why using evidence from the specification.
   - Define Scope Boundaries and Dependencies; mark unknowns with `[NEEDS CLARIFICATION: ...]`.
   - Curate Context items with absolute paths/URLs and rationales.
   - Build the Implementation Blueprint table (stages, tasks, evidence) referencing the plan and engineering principles (SOLID, DRY, KISS, YAGNI, risk calibration).
   - Enumerate Validation Gates with exact commands (unit/integration tests, linting, manual checks) and expected proofs.
   - Document Risks, Trade-offs, and mitigation strategies.
   - Identify Parallelization opportunities and hand-off expectations.
   - Seed the Evidence Ledger with baseline metrics or placeholders for results.
4. Ensure the Engineering Principles reminder at the end is respected—if any principle conflicts with the current plan, highlight it in the Risk/Decision section.
5. Save the updated PRP file and report completion with absolute path and key highlights (number of validation gates, open clarifications, parallel work streams). If this is a post-implementation refresh, include links to test reports and metrics in the Evidence Ledger.

Remember: Evidence \> assumptions. If the source artifacts are insufficient, stop and request the missing context before proceeding.

# Product Requirements Prompt (PRP): {{FEATURE_BRANCH}}

**Generated:** {{CURRENT_DATE}}

## Source Context
- Feature Specification → {{SPEC_PATH}}
- Implementation Plan → {{PLAN_PATH}}
- Tasks Backlog → {{TASKS_PATH}}
- Research Notes → {{RESEARCH_PATH}}
- Data Model → {{DATA_MODEL_PATH}}
- API / Contract Directory → {{CONTRACTS_PATH}}
- Quickstart Guide → {{QUICKSTART_PATH}}

> Treat these artifacts as the single source of truth. Do not invent requirements. When an input is missing or ambiguous, add `[NEEDS CLARIFICATION: …]` and pause for resolution.

## Goal & Strategic Why
- **Goal Statement**: Summarize the user and business outcome in one sentence.
- **Problem Framing**: Explain the pain or opportunity this feature addresses.
- **Success Signals**: List measurable indicators (KPIs, qualitative outcomes) that prove success.

## Scope Boundaries
- **In-Scope**: Enumerate scenarios explicitly supported.
- **Out-of-Scope**: Call out exclusions to reduce assumption drift.
- **Dependencies & Preconditions**: Identify upstream requirements, migrations, or feature flags.

## Curated Context
Document concrete artifacts the agent should load before implementation. Reference files, commands, or external docs with absolute paths or URLs.

| Context Item | Path / Link | Why It Matters |
|--------------|-------------|----------------|
|              |             |                |

## Implementation Blueprint
Break down the execution plan into stages. Align each stage with SOLID, DRY, KISS, and the Task-First loop (Understand → Plan → Execute → Validate).

| Stage | Objective | Key Tasks | Evidence of Completion |
|-------|-----------|-----------|------------------------|
| 1     |           |           |                        |

Guidance:
- Reference data structures, APIs, and flows from the plan artifacts rather than restating code.
- Highlight opportunities for parallel work streams and the coordination required.
- Explicitly note where abstractions or interfaces enforce Dependency Inversion or Interface Segregation.

## Validation Gates & Tooling
List all quality checks that must pass before the feature is complete. Provide exact commands (with working directories) and expected outputs.

- **Unit / Functional Tests**: `...`
- **Integration / Contract Tests**: `...`
- **Static Analysis & Lint**: `...`
- **Manual / Exploratory**: `...`
- **Monitoring Hooks**: describe metrics, A/B toggles, or dashboards to watch post-deploy.

> Evidence > assumptions: record command output, log snippets, or screenshots linked in the Evidence Ledger.

## Risk, Trade-offs & Decision Record
- **Risks**: probability × impact, with mitigation plans.
- **Trade-offs**: capture rejected options and rationale (reversibility, time horizon, option preservation).
- **Security & Compliance**: document how data protection, auth, and audits are preserved.

## Parallelization & Handoff Strategy
- Identify tasks that can run concurrently across agents or humans.
- Specify sync points, code review expectations, and rollout strategy.
- Clarify ownership for follow-up tasks or monitoring.

## Evidence Ledger
Track proof for every major claim or completion signal.

| Item | Evidence (link, log, test output) | Reviewer |
|------|------------------------------------|----------|
|      |                                    |          |

## Open Questions & Clarifications
- Use `[NEEDS CLARIFICATION: question]` for unresolved gaps.
- Tie each question back to the impacted section above.

## Ready-for-Implementation Checklist
- [ ] Scope boundaries confirmed and stakeholders aligned
- [ ] Implementation blueprint reviewed for ripple effects and long-term implications
- [ ] Validation gates executable locally and in CI
- [ ] Risk mitigations and roll-back plans documented
- [ ] Evidence ledger seeded with baseline metrics / screenshots

### Engineering Principles Reminder
- **Task-First**: Work in Understand → Plan → Execute → Validate loops.
- **Evidence-Based**: Every change needs objective proof.
- **Parallel Thinking**: Batch related work when safe; avoid blocking sequences.
- **Context Awareness**: Keep AGENTS.md, PRPs, and project artifacts synchronized after every major change.

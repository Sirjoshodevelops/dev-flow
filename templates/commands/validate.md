---
description: Validate documentation, context, specifications, and best practices compliance across the project.
scripts:
  sh: scripts/bash/run-validation.sh --json
  ps: scripts/powershell/run-validation.ps1 -Json
---

The user input to you can be provided directly by the agent or as a command argument - you **MUST** consider it before proceeding with the prompt (if not empty).

User input:

$ARGUMENTS

## Purpose

The `/validate` command performs comprehensive quality checks across all project artifacts to ensure:
- Documentation completeness and consistency
- Requirements quality using EARS syntax
- Context window budget optimization
- Cross-artifact traceability
- Best practices compliance
- Constitution alignment

This command can be run at any time to verify project health and identify issues before they compound.

## Execution Flow

```
1. Run `{SCRIPT}` from repo root, parse JSON for REPO_ROOT, CURRENT_BRANCH, SPECS_DIR
2. Load validation configuration from .specify/validation-config.json (if exists)
3. Execute validation phases in order:
   Phase 1: Document Structure Validation
   Phase 2: Requirements Quality Check (EARS compliance)
   Phase 3: Context Window Budget Analysis
   Phase 4: Cross-Artifact Consistency
   Phase 5: Constitution Compliance
   Phase 6: Best Practices Verification
4. Generate validation report with severity levels (ERROR, WARNING, INFO)
5. Output actionable recommendations
6. Return: validation-report.md in specs directory
```

## Phase 1: Document Structure Validation

### Checks:
- **Mandatory sections present**: Verify all required sections exist in spec.md, plan.md, prp.md
- **Template compliance**: Ensure documents follow their respective templates
- **Markdown linting**: Check for syntax errors, broken links, malformed headers
- **File existence**: Confirm all referenced files and paths exist
- **Naming conventions**: Validate file and directory naming matches standards

### Tools Reference:
- Use markdownlint rules for syntax checking
- Verify against spec-template.md, plan-template.md, prp-template.md
- Check `[NEEDS CLARIFICATION]` markers are resolved or documented

### Output Format:
```markdown
### Document Structure
- ✅ spec.md: All mandatory sections present
- ⚠️  plan.md: Missing "Risk & Trade-offs" section
- ❌ tasks.md: 3 broken internal links detected
- ✅ All file references valid
```

## Phase 2: Requirements Quality Check (EARS Compliance)

### Checks:
- **EARS syntax adherence**: Scan requirements for proper EARS patterns
  - Event-Driven: "When [trigger], the system shall [response]"
  - State-Driven: "While [state], the system shall [response]"
  - Ubiquitous: "The system shall [response]"
  - Optional: "Where [feature], the system shall [response]"
  - Unwanted: "If [condition], then the system shall [response]"
- **Requirement clarity**: Detect ambiguous language (maybe, should, could, possibly)
- **Testability**: Ensure requirements are measurable and verifiable
- **Completeness**: Check for vague placeholders or TODOs
- **Consistency**: Verify requirements don't contradict each other

### Detection Rules:
```python
# Ambiguous language patterns to flag
ambiguous_terms = ["maybe", "could", "should consider", "might", "possibly", 
                   "approximately", "as needed", "if possible", "TBD", "TODO"]

# EARS pattern recognition
ears_patterns = {
    "event": r"When\s+.+,\s+the\s+.+\s+shall\s+.+",
    "state": r"While\s+.+,\s+the\s+.+\s+shall\s+.+",
    "ubiquitous": r"The\s+.+\s+shall\s+.+",
    "optional": r"Where\s+.+,\s+the\s+.+\s+shall\s+.+",
    "unwanted": r"If\s+.+,\s+then\s+the\s+.+\s+shall\s+.+"
}
```

### Output Format:
```markdown
### Requirements Quality (EARS Compliance)
- ✅ 12/15 requirements follow EARS syntax (80%)
- ⚠️  FR-003: Uses ambiguous term "should" - recommend "shall" or "must"
- ⚠️  FR-007: Missing trigger condition - not a valid EARS pattern
- ❌ FR-009: Contains "TBD" placeholder - must be resolved
- ✅ All requirements are testable
- ⚠️  FR-012 and FR-015 may conflict - verify intent

**Recommendations:**
1. Rewrite FR-003 as: "When user logs in, the system shall redirect to dashboard"
2. Add trigger to FR-007 or convert to ubiquitous pattern
3. Resolve FR-009 placeholder before implementation
```

## Phase 3: Context Window Budget Analysis

### Checks:
- **Token estimation**: Calculate approximate token count for each artifact
- **Total budget**: Sum tokens across constitution, spec, plan, research, tasks
- **Optimization suggestions**: Identify sections that can be summarized or referenced
- **Priority ranking**: Mark which artifacts are critical vs optional for AI context

### Estimation Formula:
```
tokens ≈ (characters / 4) × 1.3  # Rough estimation
OR
Use tiktoken library if available for accurate count
```

### Token Budget Targets:
- **Constitution**: Target < 500 tokens
- **Spec**: Target < 1,000 tokens
- **Plan**: Target < 1,500 tokens
- **Research**: Target < 800 tokens (can be external reference)
- **Tasks**: Target < 400 tokens (summarize completed)
- **PRP**: Target < 2,000 tokens
- **Total Optimal**: < 6,000 tokens for high-quality AI performance
- **Maximum Acceptable**: < 8,000 tokens before quality degradation

### Output Format:
```markdown
### Context Window Budget Analysis
| Artifact | Tokens | Target | Status | Priority |
|----------|--------|--------|--------|----------|
| Constitution | 450 | 500 | ✅ | HIGH |
| Spec | 1,200 | 1,000 | ⚠️  | HIGH |
| Plan | 1,800 | 1,500 | ⚠️  | HIGH |
| Research | 950 | 800 | ⚠️  | MEDIUM |
| Tasks | 300 | 400 | ✅ | LOW |
| PRP | 2,100 | 2,000 | ⚠️  | HIGH |
| **TOTAL** | **6,800** | **6,000** | **⚠️** | - |

**Optimization Recommendations:**
1. Spec is 20% over budget - consider:
   - Moving detailed examples to separate examples.md
   - Summarizing user scenarios after validation
2. Plan exceeds target - options:
   - Archive completed phases to plan-archive.md
   - Reference external research instead of embedding
3. Research notes can be external reference (saves 950 tokens)
4. **After optimization**: Estimated total = 5,850 tokens ✅
```

## Phase 4: Cross-Artifact Consistency

### Checks:
- **Requirement traceability**: Ensure spec requirements map to plan tasks
- **Feature alignment**: Verify PRP goal matches spec primary requirement
- **Terminology consistency**: Same concepts use same terms across docs
- **Version sync**: Check all docs reference same feature/branch
- **Completeness chains**: Spec → Plan → Tasks → PRP all connected
- **Evidence tracking**: Validation gates in PRP reference actual test files

### Traceability Matrix:
```markdown
### Cross-Artifact Consistency
- ✅ All FR-### requirements traced to plan phases
- ⚠️  FR-007 not mentioned in tasks.md - missing implementation task
- ❌ PRP references "authentication" but spec uses "login" - inconsistent terminology
- ✅ Branch name matches across all documents (###-user-auth)
- ⚠️  plan.md references test file "auth_test.py" but file doesn't exist yet
- ✅ Constitution principles referenced in plan Constitution Check

**Terminology Issues:**
- "login" vs "authentication" used interchangeably
- "user" vs "account holder" - prefer consistent term

**Missing Connections:**
- FR-007 needs task in tasks.md Phase 2
- Create auth_test.py or update plan reference
```

## Phase 5: Constitution Compliance

### Checks:
- **Simplicity principle**: Flag unnecessary complexity (4th project, extra abstraction)
- **Evidence-based claims**: Verify assertions have supporting evidence
- **Task-first loop**: Check workflow follows Understand → Plan → Execute → Validate
- **Parallel thinking**: Identify opportunities for concurrent work
- **Context awareness**: Ensure agent files are up-to-date

### Constitution Gates:
```markdown
### Constitution Compliance
- ✅ Project structure follows simplicity principle (3 projects max)
- ✅ No unnecessary abstractions detected
- ⚠️  Plan includes repository pattern - justification needed in Complexity Tracking
- ✅ Evidence ledger present in PRP
- ✅ Validation gates defined with commands
- ⚠️  Tasks not ordered by dependencies - review for parallel execution
- ❌ Agent file (.claude/CLAUDE.md) last updated 2 days ago - run update script

**Required Actions:**
1. Add justification for repository pattern in plan Complexity Tracking
2. Reorder tasks.md to enable parallel execution where possible
3. Run: scripts/bash/update-agent-context.sh claude
```

## Phase 6: Best Practices Verification

### Checks:
- **Security practices**: No hardcoded credentials, sensitive data marked
- **Testing strategy**: Tests defined before implementation (TDD)
- **Documentation currency**: Recent changes documented
- **Version control**: Proper branching strategy, meaningful commits
- **Performance considerations**: Non-functional requirements present
- **Accessibility**: If UI feature, accessibility requirements included

### Output Format:
```markdown
### Best Practices
- ✅ No credentials detected in any files
- ✅ Contract tests defined before implementation
- ✅ All changes have corresponding documentation updates
- ⚠️  Last commit message: "wip" - use descriptive messages
- ✅ Performance requirements specified (response time < 200ms)
- ⚠️  UI feature but no accessibility requirements - consider adding
- ✅ Error handling specified for all failure scenarios

**Recommendations:**
1. Add accessibility requirements (WCAG 2.1 AA compliance)
2. Use conventional commits format for better changelog generation
3. Consider adding security requirements section to spec
```

## Validation Report Summary

The final report should include:

```markdown
# Validation Report: [Feature Name]
**Generated**: [timestamp]
**Branch**: [branch-name]
**Status**: [✅ PASS | ⚠️  WARNINGS | ❌ FAIL]

## Executive Summary
- **Total Issues**: X errors, Y warnings, Z info
- **Critical Issues**: [count] (must fix before proceeding)
- **Recommendations**: [count] improvements suggested
- **Overall Health**: [Excellent | Good | Needs Attention | Critical]

## Issues by Severity

### ❌ Errors (Must Fix)
1. [Issue description with location and fix suggestion]

### ⚠️  Warnings (Should Fix)
1. [Issue description with recommendation]

### ℹ️  Info (Consider)
1. [Suggestion for improvement]

## Phase Results
[Detailed results from each phase]

## Action Items
1. [ ] Fix FR-009 TBD placeholder
2. [ ] Run agent context update script
3. [ ] Add accessibility requirements
4. [ ] Optimize spec.md token budget

## Next Steps
Based on validation results, recommended next command:
- If errors: Fix errors, then re-run `/validate`
- If warnings only: Consider fixes, then `/plan` or `/tasks`
- If all green: Proceed to `/implement`
```

## Configuration File (Optional)

Users can create `.specify/validation-config.json` to customize checks:

```json
{
  "validation": {
    "ears_compliance": {
      "enabled": true,
      "min_compliance_percent": 80,
      "strict_mode": false
    },
    "context_budget": {
      "enabled": true,
      "max_total_tokens": 8000,
      "warn_threshold": 6000
    },
    "markdown_linting": {
      "enabled": true,
      "rules": ["MD001", "MD003", "MD004", "MD013"]
    },
    "constitution_checks": {
      "enabled": true,
      "require_justification": true
    },
    "ignore_patterns": [
      "*.draft.md",
      "archived/*"
    ]
  }
}
```

## Usage Patterns

### Run full validation
```bash
/validate
```

### Validate specific aspect (if supported)
```bash
/validate --focus requirements
/validate --focus budget
/validate --focus consistency
```

### Validate with custom severity
```bash
/validate --strict  # Treat warnings as errors
/validate --lenient # Show only errors
```

## Integration with Workflow

**When to run `/validate`:**
1. **After `/specify`** - Verify spec quality before planning
2. **After `/clarify`** - Ensure clarifications resolved ambiguities
3. **After `/plan`** - Check plan completeness and consistency
4. **Before `/implement`** - Final quality gate
5. **During implementation** - Periodic health checks
6. **Before `/prp` refresh** - Ensure input artifacts are clean

## Notes for AI Agents

- This command is **READ-ONLY** - it identifies issues but doesn't fix them
- Present findings clearly with actionable next steps
- Prioritize errors over warnings over info
- Always provide specific location (file, line, section) for each issue
- Suggest concrete fixes, not just "improve this"
- Use emojis sparingly: ✅ ⚠️  ❌ ℹ️  only
- Keep report focused - don't overwhelm with minor issues
- Generate the report even if some checks fail - partial results are valuable

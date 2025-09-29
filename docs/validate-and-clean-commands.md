---
description: Complete guide to the /validate and /clean commands for quality assurance and code maintenance
---

# `/validate` and `/clean` Commands Documentation

## Overview

The Spec-Driven Development toolkit now includes two powerful maintenance commands:

- **`/validate`** - Comprehensive quality checks for documentation, requirements, and best practices
- **`/clean`** - Safe automated cleanup of dead code, duplicates, and unused files

Both commands are fully integrated into the Flow CLI workflow and can be run at any time to maintain project health.

---

## `/validate` Command

### Purpose

The `/validate` command performs six phases of automated quality checks:

1. **Document Structure** - Verify template compliance and markdown syntax
2. **Requirements Quality** - Check EARS syntax and clarity
3. **Context Window Budget** - Analyze token usage for AI agents
4. **Cross-Artifact Consistency** - Ensure traceability across docs
5. **Constitution Compliance** - Verify adherence to project principles
6. **Best Practices** - Check security, testing, and development standards

### When to Run

```
/specify    ─────→  /validate  ─────→  /clarify (if needed)
                        │
/clarify    ─────→  /validate  ─────→  /plan (if clean)
                        │
/plan       ─────→  /validate  ─────→  /tasks (if clean)
                        │
/tasks      ─────→  /validate  ─────→  /implement (final gate)
                        │
During impl ─────→  /validate  ─────→  Health check anytime
                        │
Before /prp ─────→  /validate  ─────→  Ensure clean inputs
```

### Usage Examples

#### Basic validation (all checks)
```bash
/validate
```

#### Focus on specific phase
```bash
/validate --focus requirements
/validate --focus budget
/validate --focus consistency
/validate --focus constitution
/validate --focus practices
```

#### Strict mode (warnings as errors)
```bash
/validate --strict
```

### Output Format

The command generates a detailed markdown report with:

```markdown
# Validation Report: Feature Name
**Status**: ✅ PASS | ⚠️  WARNINGS | ❌ FAIL

## Executive Summary
- Total Issues: 2 errors, 5 warnings, 3 info
- Critical Issues: 2 (must fix before proceeding)
- Overall Health: Good

## Issues by Severity

### ❌ Errors (Must Fix)
1. FR-009 contains TBD placeholder (spec.md:45)
   → Fix: Replace with actual requirement

### ⚠️  Warnings (Should Fix)  
1. Context budget at 6,800 tokens (target: 6,000)
   → Optimize: Move examples to separate file

### ℹ️  Info (Consider)
1. No accessibility requirements for UI feature
   → Suggestion: Add WCAG 2.1 AA compliance

## Action Items
- [ ] Resolve FR-009 placeholder
- [ ] Optimize spec.md token budget
- [ ] Add accessibility requirements

## Next Steps
Fix errors, then re-run /validate
```

### Phase Details

#### Phase 1: Document Structure Validation
Checks:
- All mandatory sections present (spec.md, plan.md, prp.md)
- Template compliance
- Markdown linting (syntax, links, headers)
- File existence for all references
- Naming conventions

#### Phase 2: Requirements Quality (EARS Compliance)
Checks:
- EARS syntax patterns:
  - Event: "When [trigger], the system shall [response]"
  - State: "While [state], the system shall [response]"
  - Ubiquitous: "The system shall [response]"
  - Optional: "Where [feature], the system shall [response]"
  - Unwanted: "If [condition], then the system shall [response]"
- Ambiguous language detection (maybe, should, could, TBD)
- Testability and measurability
- Requirement completeness
- Consistency and contradictions

#### Phase 3: Context Window Budget Analysis
Calculates token estimates:
- Constitution: Target < 500 tokens
- Spec: Target < 1,000 tokens
- Plan: Target < 1,500 tokens
- Research: Target < 800 tokens
- Tasks: Target < 400 tokens
- PRP: Target < 2,000 tokens
- **Total Optimal: < 6,000 tokens**
- **Max Acceptable: < 8,000 tokens**

Provides optimization suggestions:
- Move detailed examples external
- Archive completed sections
- Summarize verbose descriptions
- Reference instead of embed

#### Phase 4: Cross-Artifact Consistency
Verifies:
- Requirement traceability (spec → plan → tasks)
- Feature alignment (spec ↔ PRP)
- Terminology consistency
- Version synchronization
- Evidence tracking (PRP references actual files)

#### Phase 5: Constitution Compliance
Checks:
- Simplicity principle (no unnecessary complexity)
- Evidence-based development
- Task-first loop adherence
- Parallel thinking opportunities
- Agent file currency

#### Phase 6: Best Practices Verification
Checks:
- Security (no hardcoded credentials)
- Testing strategy (TDD approach)
- Documentation currency
- Version control hygiene
- Performance considerations
- Accessibility requirements (for UI)

### Configuration

Create `.specify/validation-config.json` to customize:

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

---

## `/clean` Command

### Purpose

The `/clean` command safely removes:

- **Dead code** - Unused functions, classes, imports
- **Duplicate code** - Identical or similar blocks
- **Unused files** - Orphaned tests, deprecated scripts
- **Outdated documentation** - Superseded specs, old drafts
- **Directory clutter** - Reorganize for clarity

### Safety Principles

**🔒 SAFETY FIRST - The Command is NON-DESTRUCTIVE**

1. ✅ **Automatic Git backup** before any changes
2. ✅ **Dry run by default** - shows what would be deleted
3. ✅ **User confirmation required** for all deletions
4. ✅ **Rollback commands provided** in report
5. ✅ **Archive option** instead of deletion
6. ✅ **Batch processing** with verification between batches

### When to Run

```
After feature merge  ─────→  /clean  ─────→  Remove feature scaffolding
Before major refactor ────→  /clean  ─────→  Clean slate
Quarterly maintenance ────→  /clean  ─────→  Housekeeping
After branch merge    ────→  /clean  ─────→  Clean obsolete specs
Before release        ────→  /clean  ─────→  Production ready
Large specs/ dir      ────→  /clean  ─────→  Archive completed
```

### Usage Examples

#### Dry run (default - safe to run anytime)
```bash
/clean
# Shows report, no changes made
```

#### Execute specific cleanup type
```bash
/clean --type dead-code --execute
/clean --type duplicates --execute
/clean --type unused-files --execute
/clean --type outdated-docs --execute
```

#### Archive mode (no deletions)
```bash
/clean --archive-only
# Moves everything to .archived/ instead of deleting
```

#### Full cleanup (with confirmation)
```bash
/clean --execute
# After reviewing dry run report
```

### Execution Flow

```
1. Safety Check
   ├─ Verify git is clean (no uncommitted changes)
   └─ Create backup branch: cleanup-backup-{timestamp}

2. Static Analysis (Phase 1)
   ├─ Detect dead code (language-specific tools)
   ├─ Find duplicate code blocks
   ├─ Identify unused files
   └─ Locate outdated documentation

3. Dry Run Report (Phase 2)
   ├─ Generate detailed report with risk levels
   ├─ Show space savings estimate
   └─ Provide specific locations and reasons

4. User Confirmation (Phase 3)
   ├─ Present options: [Low risk only | All | Customize | Cancel]
   ├─ Show checklist for customization
   └─ Get explicit approval

5. Safe Cleanup (Phase 4)
   ├─ Process in batches (10 files at a time)
   ├─ Commit each batch
   ├─ Run validation between batches
   └─ Handle refactorings separately

6. Verification (Phase 5)
   ├─ Run linters
   ├─ Run tests (if available)
   ├─ Check for broken imports
   └─ Generate verification report

7. Rollback Info (Phase 6)
   └─ Provide detailed rollback commands
```

### Dead Code Detection

**Language Support:**

#### Python
```bash
vulture . --min-confidence 80
autoflake --check --remove-all-unused-imports
pylint --disable=all --enable=W0613,W0612
```

#### JavaScript/TypeScript
```bash
ts-prune
eslint --no-eslintrc --rule 'no-unused-vars: error'
deadcode .
```

#### Go
```bash
deadcode ./...
golangci-lint run --disable-all --enable unused
```

#### Rust
```bash
cargo clippy -- -W dead_code
cargo machete
```

### Duplicate Detection

**Tools:**
- Python: `pylint --enable=R0801`
- JS/TS: `jscpd`
- General: PMD Copy/Paste Detector
- Simple: Hash-based (md5sum)

**Criteria:**
- Minimum 5 lines similar
- 85%+ similarity threshold
- Exclude test fixtures and migrations

### Unused File Detection

**Multi-factor analysis:**
1. **Git activity** - No commits in 90 days (configurable)
2. **Import analysis** - Not imported/required anywhere
3. **Documentation references** - Not mentioned in docs
4. **Test correlation** - Test with no corresponding source

Only flagged if **BOTH** no git activity AND no imports.

### Output Format

```markdown
# Cleanup Dry Run Report
**Generated**: 2024-01-15 14:30:00
**Branch**: feature/user-auth
**Backup**: cleanup-backup-20240115_143000

## Summary
- Dead Code: 15 files (3,500 LOC)
- Duplicate Code: 8 blocks (500 LOC)
- Unused Files: 23 files
- Outdated Docs: 12 files
- **Total Savings**: ~4,000 LOC, ~300KB

## Risk Assessment
| Risk | Count | Description |
|------|-------|-------------|
| 🟢 LOW | 42 | Safe to remove |
| 🟡 MEDIUM | 8 | Requires refactoring |
| 🔴 HIGH | 0 | Complex changes |

## Dead Code Details

### src/models/legacy_user.py (250 LOC)
**Reason**: Class never imported, last commit 6 months ago
**Risk**: 🟢 LOW
**Action**: ARCHIVE to .archived/2024-01/

### src/utils/old_helpers.py (180 LOC)
**Reason**: All functions unused per static analysis
**Risk**: 🟢 LOW
**Action**: DELETE (backed up in git)

[... detailed entries ...]

## Rollback Instructions

### Full Rollback
```bash
git reset --hard cleanup-backup-20240115_143000
```

### Partial Restore
```bash
git checkout cleanup-backup-20240115_143000 -- path/to/file
```

### Archive Recovery
```bash
cp .archived/2024-01/filename src/original/location/
```
```

### Configuration

Create `.specify/cleanup-config.json`:

```json
{
  "cleanup": {
    "dead_code": {
      "enabled": true,
      "min_confidence": 80,
      "exclude_patterns": [
        "*/migrations/*",
        "*/fixtures/*"
      ],
      "archive_instead_of_delete": false
    },
    "duplicate_code": {
      "enabled": true,
      "min_lines": 5,
      "similarity_threshold": 0.85,
      "auto_refactor": false
    },
    "unused_files": {
      "enabled": true,
      "inactive_days": 90,
      "exclude_patterns": [
        "*.md",
        "LICENSE",
        "README*"
      ],
      "require_git_and_import_check": true
    },
    "outdated_docs": {
      "enabled": true,
      "archive_merged_specs": true,
      "keep_recent_days": 30
    },
    "safety": {
      "dry_run_required": true,
      "backup_branch_required": true,
      "batch_size": 10,
      "run_tests_after_batch": true
    }
  }
}
```

---

## Integration with Workflow

### Complete Feature Lifecycle with Validation & Cleanup

```
┌─────────────────────────────────────────────────────┐
│ 1. /specify "feature description"                   │
└─────────────┬───────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────────┐
│ 2. /validate                                         │
│    → Check spec quality                              │
│    → Verify EARS compliance                          │
│    → Assess context budget                           │
└─────────────┬───────────────────────────────────────┘
              │
              ▼
         ┌────┴────┐
         │ Errors? │
         └────┬────┘
         Yes  │  No
         ←────┤────→
              │              
              ▼
┌─────────────────────────────────────────────────────┐
│ 3. /clarify (if ambiguities detected)               │
└─────────────┬───────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────────┐
│ 4. /prp                                              │
│    → Generate Product Requirements Prompt            │
└─────────────┬───────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────────┐
│ 5. /plan                                             │
│    → Create implementation plan                      │
└─────────────┬───────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────────┐
│ 6. /validate                                         │
│    → Verify plan completeness                        │
│    → Check constitution compliance                   │
│    → Validate cross-artifact consistency             │
└─────────────┬───────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────────┐
│ 7. /tasks                                            │
│    → Generate actionable task list                   │
└─────────────┬───────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────────┐
│ 8. /validate (final quality gate)                   │
│    → All checks before implementation                │
└─────────────┬───────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────────┐
│ 9. /implement                                        │
│    → Execute tasks                                   │
│    → Periodic /validate during implementation        │
└─────────────┬───────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────────┐
│ 10. /clean                                           │
│     → Remove dead code                               │
│     → Archive outdated docs                          │
│     → Clean up duplicates                            │
└─────────────┬───────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────────┐
│ 11. /prp (refresh)                                   │
│     → Update evidence and validation gates           │
└─────────────────────────────────────────────────────┘
```

---

## Best Practices

### For `/validate`

1. **Run early and often** - Don't wait until the end
2. **Fix errors immediately** - Don't let them accumulate
3. **Monitor context budget** - Keep under 6,000 tokens
4. **Use EARS syntax** - Improves AI comprehension by 60%
5. **Maintain traceability** - Every requirement should map to tasks
6. **Update agent files** - Keep context fresh for AI agents

### For `/clean`

1. **Always dry run first** - Review before executing
2. **Start conservative** - Low-risk deletions only
3. **Verify after batches** - Run tests between cleanup batches
4. **Archive when uncertain** - Better safe than sorry
5. **Document decisions** - Note why files were removed
6. **Keep git history** - Use git operations, not raw deletions

---

## Troubleshooting

### `/validate` Issues

**Problem**: "Cannot find spec.md"
- **Solution**: Ensure you're on a feature branch or set `SPECIFY_FEATURE` env var

**Problem**: "EARS compliance at 0%"
- **Solution**: Requirements not following EARS patterns - see Phase 2 examples

**Problem**: "Context budget exceeded"
- **Solution**: Optimize docs - move examples external, summarize completed work

**Problem**: "markdownlint not available"
- **Solution**: Install with `npm install -g markdownlint-cli` (optional)

### `/clean` Issues

**Problem**: "Git working directory is dirty"
- **Solution**: Commit or stash changes before running cleanup

**Problem**: "No dead code detected but I know there is"
- **Solution**: Check if detection tools are installed (vulture, ts-prune, etc.)

**Problem**: "False positive - file is actually used"
- **Solution**: Add to exclude_patterns in cleanup-config.json

**Problem**: "How do I rollback a cleanup?"
- **Solution**: Use rollback commands from cleanup report

---

## Tool Dependencies

### Required (Built-in)
- Git (for `/clean` safety)
- Bash or PowerShell

### Optional (Enhanced Features)

#### For `/validate`:
- `markdownlint` - Markdown linting (npm install -g markdownlint-cli)
- `python3` - For Python-based checks
- `node` - For JavaScript-based checks

#### For `/clean`:
- **Python**: `vulture`, `autoflake`, `pylint`
- **JavaScript/TypeScript**: `ts-prune`, `eslint`, `deadcode`, `jscpd`
- **Go**: `deadcode`, `golangci-lint`
- **Rust**: `cargo clippy`, `cargo machete`

**Installation example:**
```bash
# Python tools
pip install vulture autoflake pylint

# JavaScript tools
npm install -g ts-prune eslint jscpd

# Go tools
go install golang.org/x/tools/cmd/deadcode@latest

# Rust tools
cargo install cargo-machete
```

---

## FAQ

**Q: Is `/validate` required before every command?**
A: No, but recommended. It acts as a quality gate to catch issues early.

**Q: Can `/clean` delete important files?**
A: No. It uses multi-factor analysis and always requires confirmation. Plus, everything is backed up in git.

**Q: How long does `/validate` take?**
A: Usually < 30 seconds for typical projects. Most checks are fast text analysis.

**Q: Will `/clean` break my project?**
A: Extremely unlikely. It processes in batches with verification, and provides rollback commands.

**Q: Can I customize what gets validated/cleaned?**
A: Yes, via config files (`.specify/validation-config.json` and `.specify/cleanup-config.json`)

**Q: What if I don't have the detection tools installed?**
A: Both commands work with basic functionality. Tools enable advanced detection but aren't required.

---

## Command Reference

### `/validate` Options
```bash
/validate                      # Full validation (all phases)
/validate --focus requirements # Only requirements check
/validate --focus budget       # Only context budget
/validate --focus consistency  # Only cross-artifact
/validate --focus constitution # Only constitution compliance
/validate --focus practices    # Only best practices
/validate --strict             # Treat warnings as errors
/validate --lenient            # Show errors only
```

### `/clean` Options
```bash
/clean                           # Dry run (default)
/clean --type dead-code          # Only dead code
/clean --type duplicates         # Only duplicates
/clean --type unused-files       # Only unused files
/clean --type outdated-docs      # Only old docs
/clean --execute                 # Execute cleanup
/clean --archive-only            # Archive instead of delete
/clean --aggressive              # Include medium-risk items
```

---

## Summary

The `/validate` and `/clean` commands complete the Spec-Driven Development toolkit by providing:

✅ **Quality Assurance** - Automated checks for documentation and requirements
✅ **Context Optimization** - Token budget tracking for AI agents
✅ **Code Health** - Dead code and duplicate detection
✅ **Safety First** - Non-destructive operations with rollback
✅ **Workflow Integration** - Natural fit in development lifecycle
✅ **Best Practices** - EARS syntax, constitution compliance, security

Use them regularly to maintain a clean, high-quality codebase optimized for AI-assisted development.

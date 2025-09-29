---
description: Safely clean up duplicate, unused, or outdated code and documentation with automated backup and rollback support.
scripts:
  sh: scripts/bash/run-cleanup.sh --json
  ps: scripts/powershell/run-cleanup.ps1 -Json
---

The user input to you can be provided directly by the agent or as a command argument - you **MUST** consider it before proceeding with the prompt (if not empty).

User input:

$ARGUMENTS

## Purpose

The `/clean` command performs safe, automated cleanup of:
- **Dead code**: Unused functions, classes, imports, variables
- **Duplicate code**: Identical or near-identical code blocks
- **Outdated documentation**: Superseded specs, archived plans
- **Unused files**: Orphaned tests, deprecated scripts
- **Directory structure**: Reorganize for clarity and convention

This command includes **automatic backup** and **rollback capabilities** to ensure nothing is permanently lost.

## ⚠️  CRITICAL SAFETY PRINCIPLES

1. **NEVER delete without backup** - All deletions are reversible via Git
2. **DRY RUN FIRST** - Always show what would be deleted before doing it
3. **USER CONFIRMATION** - Require explicit approval for deletions
4. **GIT INTEGRATION** - Leverage version control for safety
5. **PRESERVE HISTORY** - Move to archive rather than delete when uncertain

## Execution Flow

```
1. Run `{SCRIPT}` from repo root, parse JSON for REPO_ROOT, CURRENT_BRANCH, BACKUP_BRANCH
2. Verify git working directory is clean (no uncommitted changes)
   → If dirty: ERROR "Commit or stash changes before cleaning"
3. Create safety backup branch: git branch cleanup-backup-{timestamp}
4. Execute cleanup phases in order:
   Phase 1: Static Analysis (detect candidates)
   Phase 2: Dry Run Report (show what would be cleaned)
   Phase 3: User Confirmation (get explicit approval)
   Phase 4: Safe Cleanup (execute approved changes)
   Phase 5: Verification (confirm no breakage)
   Phase 6: Archive Creation (move deleted to archive if needed)
5. Provide rollback instructions
6. Return: cleanup-report.md with changes and rollback command
```

## Phase 1: Static Analysis

### Detect Dead Code

#### Python Detection:
```python
# Use vulture for dead code detection
vulture . --min-confidence 80 --sort-by-size

# Check for unused imports
autoflake --check --remove-all-unused-imports -r .

# Find unused functions/classes
pylint --disable=all --enable=W0613,W0612
```

#### JavaScript/TypeScript Detection:
```bash
# Use ts-prune for TypeScript
npx ts-prune

# Use ESLint for unused vars
eslint --no-eslintrc --rule 'no-unused-vars: error'

# deadcode tool
npx deadcode .
```

#### General Language-Agnostic:
```bash
# Find files not in git history (never committed/referenced)
find . -type f ! -path "./.git/*" -exec git log --all --format=%n -- {} \; | grep -c "^$"

# Find files not referenced in any import/require/include
grep -r "import\|require\|include" --include="*.{py,js,ts,go}" . | grep -v "filename"
```

### Detect Duplicate Code

```bash
# Python: use pylint for duplicate detection
pylint --disable=all --enable=R0801 --min-similarity-lines=4

# General: use PMD Copy/Paste Detector (CPD)
pmd cpd --minimum-tokens 50 --files src/ --language python

# Simpler approach: hash-based duplicate detection
find . -type f -exec md5sum {} \; | sort | uniq -w32 -dD
```

### Detect Unused Files

**Criteria for "unused":**
- Not imported/required by any other file
- No git commits in last 90 days (configurable)
- Not referenced in any documentation
- Test file with no corresponding source file
- Script file not referenced in any command

**Detection Strategy:**
```bash
# Find files with no recent git activity
git log --all --pretty=format: --name-only --since="90 days ago" | sort -u > recent_files.txt
find . -type f ! -path "./.git/*" | sort > all_files.txt
comm -23 all_files.txt recent_files.txt > potentially_unused.txt

# Cross-reference with import analysis
# Only mark as unused if BOTH no git activity AND no imports
```

### Detect Outdated Documentation

**Patterns:**
- Files named `*.draft.md`, `*.old.md`, `*.bak`
- Spec files for merged/deleted branches
- Multiple versions of same doc (plan-v1.md, plan-v2.md)
- Documentation for removed features

```bash
# Find draft and backup files
find . -name "*.draft.md" -o -name "*.old.md" -o -name "*.bak"

# Find specs for deleted branches
for spec_dir in specs/*/; do
  branch=$(basename "$spec_dir")
  if ! git rev-parse --verify "$branch" >/dev/null 2>&1; then
    echo "$spec_dir is for deleted branch"
  fi
done
```

## Phase 2: Dry Run Report

Generate a detailed report of proposed changes WITHOUT executing them:

```markdown
# Cleanup Dry Run Report
**Generated**: [timestamp]
**Branch**: [current-branch]
**Backup Branch**: cleanup-backup-[timestamp]

## Summary
- **Dead Code**: 15 files (3,500 LOC to remove)
- **Duplicate Code**: 8 blocks (500 LOC to consolidate)
- **Unused Files**: 23 files
- **Outdated Docs**: 12 files
- **Total Space Savings**: ~4,000 LOC, ~300KB

## Dead Code Details

### src/models/legacy_user.py (250 LOC)
**Reason**: Class never imported, last commit 6 months ago
**Risk**: LOW - No external references found
**Action**: ARCHIVE to .archived/2024-01/legacy_user.py

### src/utils/old_helpers.py (180 LOC)
**Reason**: All functions unused per static analysis
**Risk**: LOW - Only imported in commented code
**Action**: DELETE (backed up in git)

[... more entries ...]

## Duplicate Code Details

### Duplicate Block #1 (45 LOC)
**Locations**:
- src/services/auth.py:123-168
- src/services/admin_auth.py:89-134
**Similarity**: 98%
**Recommendation**: Extract to shared function in src/utils/auth_helpers.py
**Risk**: MEDIUM - Requires refactoring

[... more entries ...]

## Unused Files Details

### tests/test_old_feature.py
**Reason**: Feature removed in commit abc123, test orphaned
**Risk**: LOW - Feature confirmed removed
**Action**: DELETE

### scripts/migrate-v1-v2.sh
**Reason**: Migration script for v1→v2, now on v4
**Risk**: LOW - Migration complete 6 months ago
**Action**: ARCHIVE to .archived/migrations/

[... more entries ...]

## Outdated Documentation

### specs/001-old-login/spec.md
**Reason**: Branch merged 3 months ago
**Risk**: LOW - Feature live in production
**Action**: ARCHIVE to .archived/completed-features/

### docs/design-draft-v1.md
**Reason**: Draft version, superseded by design.md
**Risk**: LOW - Confirmed outdated
**Action**: DELETE

[... more entries ...]

## Risk Assessment

| Risk Level | Count | Description |
|------------|-------|-------------|
| 🟢 LOW | 42 | Safe to remove, no dependencies |
| 🟡 MEDIUM | 8 | Requires refactoring or testing |
| 🔴 HIGH | 0 | Complex changes, needs review |

## Recommended Actions

### Immediate (Low Risk)
- Delete 35 unused files
- Archive 12 outdated docs
- Remove 10 dead code files

### Requires Review (Medium Risk)
- Refactor 8 duplicate blocks
- Consolidate 3 similar modules

### Manual Review Required (High Risk)
- (none)
```

## Phase 3: User Confirmation

**Interactive Approval Flow:**

```
🧹 Cleanup Dry Run Complete

Found 58 items to clean up:
- 🗑️  Delete: 45 items (LOW risk)
- 📦 Archive: 12 items (LOW risk)
- 🔄 Refactor: 8 items (MEDIUM risk - requires changes)

Would you like to:
1. [Proceed with LOW risk deletions only] (recommended)
2. [Proceed with ALL changes]
3. [Customize selections]
4. [Cancel]

Your choice: _
```

**Selection Options:**

```
If user chooses "Customize selections":
  Show categorized list with checkboxes
  [✓] src/models/legacy_user.py (DELETE)
  [✓] tests/test_old_feature.py (DELETE)
  [ ] src/services/auth.py duplicate (REFACTOR) - skipped
  ...

If user chooses "Proceed with LOW risk only":
  Execute only items marked as LOW risk
  Skip MEDIUM and HIGH risk items

If user chooses "Cancel":
  Exit without changes
  Backup branch remains for reference
```

## Phase 4: Safe Cleanup

### Execution Order:
1. **Commit current state** (if any unstaged changes)
2. **Create cleanup branch**: `git checkout -b cleanup-{timestamp}`
3. **Execute deletions in batches** (10 files at a time)
4. **Test after each batch** (run validation if available)
5. **Commit each batch**: `git commit -m "chore: remove dead code batch 1/N"`
6. **Handle refactorings separately** (manual review required)

### For Dead Code Removal:
```bash
# Remove file safely
git rm path/to/file.py

# Or for untracked file
rm path/to/file.py

# Commit
git commit -m "chore: remove unused {file_description}

- Reason: {why_unused}
- Last used: {last_commit_date}
- Analysis: {tool_used}"
```

### For Duplicates (if auto-refactoring enabled):
```bash
# Extract common code
# Create new file with shared logic
# Update both original files to import shared code
# Run tests
# Commit as refactor
git commit -m "refactor: consolidate duplicate code in {location}

- Extracted {num_lines} LOC to {new_file}
- Updated {num_files} files to use shared code
- Reduces code by {percent}%"
```

### For Archiving:
```bash
# Create archive directory if needed
mkdir -p .archived/$(date +%Y-%m)

# Move files to archive
git mv old/path/.archived/$(date +%Y-%m)/filename

# Or for documentation
mv specs/old-feature/ .archived/completed-features/

# Commit
git commit -m "chore: archive {item} to historical records"
```

## Phase 5: Verification

After cleanup, verify nothing broke:

```bash
# 1. Run linters
[language-specific linter commands]

# 2. Run tests (if available)
[test commands from package.json or makefile]

# 3. Check imports
[verify no broken imports]

# 4. Validate remaining code
# Use /validate command if available

# 5. Check file count changes
git diff --stat cleanup-backup-{timestamp}..HEAD
```

**Verification Report:**
```markdown
## Verification Results

✅ All linters pass
✅ All tests pass (145/145)
✅ No broken imports detected
✅ File count: -58 files, -4,000 LOC
⚠️  Manual review recommended for refactored duplicate blocks

**Next Steps:**
1. Review changes: git diff cleanup-backup-{timestamp}
2. Test application manually if critical
3. If satisfied: merge cleanup branch
4. If issues: rollback (see below)
```

## Phase 6: Rollback Instructions

Always provide rollback commands in the report:

```markdown
## Rollback Instructions

If you need to undo the cleanup:

### Option 1: Soft Rollback (Undo last commits)
```bash
# Return to state before cleanup
git reset --hard cleanup-backup-{timestamp}

# Or revert the cleanup commits
git revert {first_cleanup_commit}^..{last_cleanup_commit}
```

### Option 2: Cherry-pick Restoration (Restore specific files)
```bash
# Restore a specific file
git checkout cleanup-backup-{timestamp} -- path/to/file

# Restore multiple files
git checkout cleanup-backup-{timestamp} -- path/to/dir/
```

### Option 3: Full Recovery (Restore everything)
```bash
# Switch to backup branch
git checkout cleanup-backup-{timestamp}

# Create new branch from backup
git checkout -b recovery-{timestamp}

# Merge needed changes from current branch
git cherry-pick {commits_to_keep}
```

### Archived Files Recovery
Files in `.archived/` can be restored anytime:
```bash
# View archived files
ls -la .archived/

# Restore from archive
cp .archived/2024-01/filename src/original/location/
```
```

## Configuration File (Optional)

Users can create `.specify/cleanup-config.json`:

```json
{
  "cleanup": {
    "dead_code": {
      "enabled": true,
      "min_confidence": 80,
      "exclude_patterns": ["*/migrations/*", "*/fixtures/*"],
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
      "exclude_patterns": ["*.md", "LICENSE", "README*"],
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

## Usage Patterns

### Standard cleanup (dry run first)
```bash
/clean
# Review report
# Confirm when prompted
```

### Specific cleanup types
```bash
/clean --type dead-code
/clean --type duplicates
/clean --type unused-files
/clean --type outdated-docs
```

### Aggressive cleanup (with confirmation)
```bash
/clean --aggressive
# Includes medium-risk items
```

### Archive-only mode (no deletions)
```bash
/clean --archive-only
# Moves everything to .archived/ instead of deleting
```

## Integration with Workflow

**When to run `/clean`:**
1. **After feature completion** - Remove feature-specific scaffolding
2. **Before major refactor** - Clean slate for new architecture
3. **Quarterly maintenance** - Regular housekeeping
4. **After merging branches** - Clean up obsolete specs and docs
5. **Before release** - Remove dead code for production
6. **When specs/ directory grows large** - Archive completed features

## Language-Specific Tools Integration

### Python
```bash
# Dead code detection
vulture . --min-confidence 80
autoflake --remove-all-unused-imports -r .
pylint --disable=all --enable=W0613,W0612,R0801

# Duplicate detection
pylint --disable=all --enable=R0801 --min-similarity-lines=4
```

### JavaScript/TypeScript
```bash
# Dead code detection
npx ts-prune
npx eslint . --no-eslintrc --rule 'no-unused-vars: error'
npx deadcode .

# Duplicate detection
npx jscpd .
```

### Go
```bash
# Dead code detection
go run golang.org/x/tools/cmd/deadcode@latest ./...
golangci-lint run --disable-all --enable unused

# Duplicate detection
dupl -threshold 50 ./...
```

### Rust
```bash
# Dead code detection
cargo clippy -- -W dead_code
cargo machete

# Duplicate detection
cargo-geiger --features all
```

## Notes for AI Agents

- **SAFETY FIRST**: Never delete without backup and confirmation
- **BE CONSERVATIVE**: When in doubt, archive instead of delete
- **EXPLAIN DECISIONS**: Tell user WHY each item is flagged
- **SHOW EXAMPLES**: Include file paths and code snippets in dry run
- **PROVIDE ROLLBACK**: Always include detailed rollback instructions
- **BATCH OPERATIONS**: Process in small batches with verification
- **TEST BETWEEN BATCHES**: Verify nothing broke after each deletion batch
- **PRESERVE HISTORY**: Use git operations, not raw file deletions
- **ASK BEFORE REFACTORING**: Duplicate consolidation requires user review
- **DOCUMENT CLEANUP**: Generate comprehensive cleanup report
- **NO SILENT DELETIONS**: Every deletion must be in the report

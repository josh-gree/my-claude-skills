---
name: edit-and-commit
description: Edit a single file and automatically commit the changes with roborev pre-commit review. Enforces atomic commits by restricting edits to one file at a time. Use when the user wants to make a focused change to a specific file and commit it.
user-invocable: true
allowed-tools: Bash, Read, Edit, Write, Grep, Glob, AskUserQuestion
---

# Edit and Commit

## Purpose

Make focused, atomic commits by editing a single file and automatically committing it with an AI code review step. This skill enforces single-file editing to maintain clean git history and uses roborev for pre-commit code review.

## Prerequisites

- roborev must be installed at `/Users/josh-gree/.local/bin/roborev`
- Git repository must be initialised
- Working directory should be clean or have only the file being edited modified

## Workflow

### Step 1: Identify the File and Change

User will specify:
- Which file to edit
- What changes to make

If not clear, ask for clarification.

**STOP if:**
- User requests changes to multiple files → "This skill edits one file at a time. Please specify a single file."
- File path is ambiguous → Ask which file they mean

### Step 2: Read the File

Read the current file contents to understand context:

```bash
# Use Read tool to read the file
```

**STOP if:**
- File doesn't exist → Ask if they want to create a new file (requires Write tool, not Edit)

### Step 3: Make the Edit

Use the Edit tool to make the requested changes to the file.

Follow these principles:
- Make only the requested changes
- Preserve existing formatting and style
- Don't add unnecessary comments or documentation
- Don't refactor surrounding code unless requested

### Step 4: Run roborev Pre-commit Review

After editing but before committing, run roborev to review the changes:

```bash
/Users/josh-gree/.local/bin/roborev review --dirty --wait
```

The `--dirty` flag reviews uncommitted changes.
The `--wait` flag blocks until the review completes.

### Step 5: Display Review Results

Show the roborev review results to the user:

```bash
/Users/josh-gree/.local/bin/roborev show HEAD
```

Explain any issues or suggestions found by roborev.

### Step 6: User Decision

Ask the user:
- **Proceed with commit** - Changes look good, commit them
- **Make adjustments** - Address roborev feedback first

If adjustments needed, return to Step 3 with the additional changes.

### Step 7: Commit the Changes

Once user approves, commit the changes with a descriptive message:

```bash
git add <file-path>
git commit -m "<descriptive commit message>"
```

**Commit message guidelines:**
- Use present tense, imperative mood (e.g., "Add feature" not "Added feature")
- Be specific about what changed
- Focus on the "why" not just the "what"
- Keep it concise (one line preferred, under 72 characters)
- No Claude attribution per user's global CLAUDE.md

**Examples:**
- "Fix null pointer in user authentication"
- "Add rate limiting to API endpoints"
- "Refactor database connection pooling"
- "Update error messages for clarity"

### Step 8: Confirm Success

Report back to user:
- What file was edited
- What changes were made
- Commit SHA
- Any roborev feedback that was addressed

## Single-File Enforcement

This skill is designed for atomic commits. If the user asks to edit multiple files:

1. **Refuse the request** - Explain this skill handles one file at a time
2. **Suggest alternatives**:
   - Run the skill multiple times for separate files
   - Use standard editing workflow for multi-file changes
   - Consider if changes should be a single ticket with `/implement-ticket`

## Guidelines

**DO**:
- Edit exactly one file per invocation
- Read the file first to understand context
- Run roborev review before committing
- Show review results to user
- Write clear, descriptive commit messages
- Ask user to approve before committing

**DON'T**:
- Edit multiple files in one invocation
- Skip the roborev review step
- Commit without user approval after review
- Add Claude attribution to commits
- Make changes beyond what was requested
- Refactor or "improve" code unless asked

## Handling Issues

**roborev not found:**
Check if roborev is installed. The skill requires it at `/Users/josh-gree/.local/bin/roborev`.

**roborev review fails:**
Show the error to user and ask how to proceed. Can commit anyway with user approval.

**Merge conflicts or dirty tree:**
If there are other uncommitted changes, ask user to commit or stash them first, or proceed carefully.

**Review finds serious issues:**
Don't commit until issues are addressed or user explicitly approves anyway.

## Usage Examples

### Example 1: Fix a bug

User: "Fix the null pointer in auth.py line 42"

Skill response:
1. Read auth.py
2. Make the fix to line 42
3. Run roborev review
4. Show review results
5. Ask user to approve
6. Commit: "Fix null pointer in user authentication"

### Example 2: Add a feature

User: "Add logging to the database query function"

Skill response:
1. Read the file containing the database query function
2. Add logging statements
3. Run roborev review
4. Review notes missing error handling
5. Show review to user, ask if they want to add error handling too
6. User approves proceeding
7. Commit: "Add logging to database query function"

### Example 3: Review finds issues

User: "Update the API rate limit from 100 to 1000"

Skill response:
1. Read config file
2. Change rate limit value
3. Run roborev review
4. Review warns this may cause performance issues
5. Show warning to user
6. User decides to use 500 instead
7. Make adjustment
8. Run roborev review again
9. Review passes
10. Commit: "Increase API rate limit to 500"

## Checklist

- [ ] Identify single file to edit and what changes to make
- [ ] Read the file to understand context
- [ ] Make the requested edits
- [ ] Run roborev pre-commit review with --dirty --wait
- [ ] Display review results to user
- [ ] Get user approval to proceed or make adjustments
- [ ] Commit with descriptive message (no Claude attribution)
- [ ] Report success with commit SHA and summary

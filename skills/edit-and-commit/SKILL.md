---
name: edit-and-commit
description: Edit files and automatically commit the changes with roborev pre-commit review. Enforces atomic commits by ensuring changes form a meaningful, coherent unit of work. Use when the user wants to make focused changes and commit them.
user-invocable: true
allowed-tools: Bash, Read, Edit, Write, Grep, Glob, AskUserQuestion
---

# Edit and Commit

## Purpose

Make focused, atomic commits by editing files and automatically committing them with an AI code review step. This skill ensures changes form a meaningful, coherent commit and uses roborev for pre-commit code review.

## Prerequisites

- roborev must be installed at `/Users/josh-gree/.local/bin/roborev`
- Git repository must be initialised
- Working directory should be clean or have only the file being edited modified

## Workflow

### Step 1: Identify the Files and Changes

User will specify:
- Which file(s) to edit
- What changes to make

If not clear, ask for clarification.

**Check coherence:**
- Do the changes form a meaningful, atomic commit?
- Can they be described with a single, clear commit message?
- Are they logically related (e.g., fixing a bug, adding a feature, refactoring)?

**STOP if:**
- Changes are unrelated or should be separate commits → Suggest breaking into multiple commits
- File path is ambiguous → Ask which file they mean

### Step 2: Read the Files

Read the current file contents to understand context:

```bash
# Use Read tool to read each file
```

**STOP if:**
- File doesn't exist → Ask if they want to create a new file (requires Write tool, not Edit)

### Step 3: Make the Edits

Use the Edit/Write tools to make the requested changes to the files.

Follow these principles:
- Make only the requested changes
- Preserve existing formatting and style
- Don't add unnecessary comments or documentation
- Don't refactor surrounding code unless requested
- Ensure all changes are logically related and form a coherent commit

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
git add <file-paths...>
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
- What files were edited
- What changes were made
- Commit SHA
- Any roborev feedback that was addressed

## Atomic Commit Principle

This skill is designed for atomic commits - changes that form a meaningful, coherent unit of work.

**Good examples of atomic commits:**
- Fix a bug across multiple related files
- Add a feature that requires changes to implementation, tests, and configuration
- Refactor a function and update all its call sites
- Rename a symbol across multiple files

**Bad examples (should be separate commits):**
- Fix bug in auth.py AND add new feature to api.py (unrelated changes)
- Update dependencies AND refactor database code (separate concerns)
- Multiple unrelated bug fixes

If the user asks to make unrelated changes:
1. **Suggest splitting** - Explain these should be separate commits
2. **Offer to do them sequentially** - Run the skill multiple times for separate commits

## Guidelines

**DO**:
- Edit files that logically belong together in one commit
- Read files first to understand context
- Run roborev review before committing
- Show review results to user
- Write clear, descriptive commit messages
- Ask user to approve before committing
- Ensure changes form a coherent, atomic commit

**DON'T**:
- Mix unrelated changes in one commit
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

### Example 4: Multiple related files

User: "Rename the getUserData function to fetchUserData everywhere"

Skill response:
1. Search for all occurrences of getUserData
2. Read api.py, tests.py, and utils.py (all use the function)
3. Update function definition in api.py
4. Update function calls in tests.py
5. Update imports in utils.py
6. Run roborev review
7. Review passes
8. Show results to user
9. User approves
10. Commit: "Rename getUserData to fetchUserData"

## Checklist

- [ ] Identify files to edit and what changes to make
- [ ] Verify changes form a coherent, atomic commit
- [ ] Read files to understand context
- [ ] Make the requested edits
- [ ] Run roborev pre-commit review with --dirty --wait
- [ ] Display review results to user
- [ ] Get user approval to proceed or make adjustments
- [ ] Commit all changed files with descriptive message (no Claude attribution)
- [ ] Report success with commit SHA and summary

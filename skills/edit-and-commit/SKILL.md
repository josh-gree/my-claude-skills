---
name: edit-and-commit
description: IMPORTANT - Use this skill proactively whenever you need to edit files and commit changes. Automatically runs roborev pre-commit review and creates atomic commits. Use this instead of Edit+Bash for git operations. Required for all file modifications that should be committed.
user-invocable: false
allowed-tools: Bash, Read, Edit, Write, Grep, Glob, AskUserQuestion
---

# Edit and Commit

## Purpose

**CRITICAL: Use this skill proactively whenever you need to make changes to files in a git repository.**

This skill handles the complete edit-review-commit workflow:
1. Edit files using Edit/Write tools
2. Run roborev AI code review on changes
3. Show review results to user
4. Create atomic git commit with descriptive message

**When to use this skill:**
- ANY time you need to edit files and commit them
- When implementing features or fixes
- When refactoring code
- When updating documentation or configuration
- Basically: if you would normally use Edit then Bash for git commit, use this skill instead

**When NOT to use this skill:**
- Reading files only (no changes)
- Exploring/searching codebase
- Changes that shouldn't be committed yet

## Prerequisites

- roborev must be installed at `/Users/josh-gree/.local/bin/roborev`
- Git repository must be initialised
- Working directory should be clean or have only the file being edited modified

## Workflow

### Step 1: Plan the Changes

Before invoking this skill, determine:
- Which file(s) need to be edited
- What changes to make
- Whether changes form an atomic commit

**Check coherence:**
- Do the changes form a meaningful, atomic commit?
- Can they be described with a single, clear commit message?
- Are they logically related (e.g., fixing a bug, adding a feature, refactoring)?

**If changes are unrelated:**
- Use this skill multiple times for separate atomic commits
- Don't mix unrelated changes in one commit

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

Each invocation of this skill creates ONE atomic commit - changes that form a meaningful, coherent unit of work.

**Use this skill ONCE for these scenarios (one commit):**
- Fix a bug across multiple related files
- Add a feature that requires changes to implementation, tests, and configuration
- Refactor a function and update all its call sites
- Rename a symbol across multiple files
- Update documentation for a specific feature

**Use this skill MULTIPLE TIMES for these scenarios (separate commits):**
- Fix bug in auth.py AND add new feature to api.py (invoke twice: once for bug fix, once for feature)
- Update dependencies AND refactor database code (invoke twice: once for deps, once for refactor)
- Multiple unrelated bug fixes (invoke once per bug fix)
- Implement feature AND update unrelated documentation (invoke twice)

**Decision making:**
If you can write ONE clear commit message that describes all changes, use the skill once.
If you need MULTIPLE commit messages to describe what you're doing, use the skill multiple times.

## Guidelines for Agent

**ALWAYS use this skill when:**
- You need to edit files and commit changes
- You're implementing a feature, fix, or refactor
- You would normally use Edit tool + Bash git commands

**DO**:
- Use this skill proactively - don't wait for user to tell you to commit
- Edit files that logically belong together in one commit
- Read files first to understand context
- Run roborev review before committing
- Show review results to user
- Write clear, descriptive commit messages
- Ask user to approve before committing
- Ensure changes form a coherent, atomic commit

**DON'T**:
- Use Edit + Bash for git commits (use this skill instead)
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

Agent thinking: I need to fix a bug in auth.py, which requires editing and committing. I should use the edit-and-commit skill.

Agent action:
1. Invokes edit-and-commit skill
2. Skill reads auth.py
3. Skill makes the fix to line 42
4. Skill runs roborev review
5. Skill shows review results to user
6. Skill asks user to approve
7. Skill commits: "Fix null pointer in user authentication"

### Example 2: Add a feature

User: "Add logging to the database query function"

Agent thinking: This requires editing code and committing it. I'll use edit-and-commit skill.

Agent action:
1. Invokes edit-and-commit skill
2. Skill reads the database module
3. Skill adds logging statements
4. Skill runs roborev review
5. Review notes missing error handling
6. Skill shows review to user, asks if they want to add error handling
7. User approves proceeding
8. Skill commits: "Add logging to database query function"

### Example 3: Review finds issues

User: "Update the API rate limit from 100 to 1000"

Agent thinking: Need to update config and commit. Using edit-and-commit skill.

Agent action:
1. Invokes edit-and-commit skill
2. Skill reads config file
3. Skill changes rate limit value
4. Skill runs roborev review
5. Review warns this may cause performance issues
6. Skill shows warning to user
7. User decides to use 500 instead
8. Skill makes adjustment
9. Skill runs roborev review again
10. Review passes
11. Skill commits: "Increase API rate limit to 500"

### Example 4: Multiple related files

User: "Rename the getUserData function to fetchUserData everywhere"

Agent thinking: This affects multiple files but forms one atomic commit (rename refactor). I'll use edit-and-commit skill once for all files.

Agent action:
1. Agent searches for all occurrences of getUserData
2. Invokes edit-and-commit skill with plan to update api.py, tests.py, utils.py
3. Skill reads all three files
4. Skill updates function definition in api.py
5. Skill updates function calls in tests.py
6. Skill updates imports in utils.py
7. Skill runs roborev review
8. Review passes
9. Skill shows results to user
10. User approves
11. Skill commits: "Rename getUserData to fetchUserData"

### Example 5: Separate atomic commits

User: "Fix the auth bug and add a new API endpoint"

Agent thinking: These are two unrelated changes - should be separate commits. I'll use edit-and-commit skill twice.

Agent action (first commit):
1. Invokes edit-and-commit skill for auth bug fix
2. Skill handles auth.py edit, review, and commit

Agent action (second commit):
1. Invokes edit-and-commit skill for new API endpoint
2. Skill handles api.py edit, review, and commit

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

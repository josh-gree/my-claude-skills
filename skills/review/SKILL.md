---
user-invocable: true
description: Review code using Google's code review principles. Use for ad-hoc file review or as the foundation for PR and codebase reviews.
arguments:
  - name: files
    description: Files or directories to review (optional)
---

# Code Review

Review code following Google's engineering practices for code review.

## Core Philosophy

**The primary purpose of code review is to improve overall code health of the codebase over time.**

The fundamental principle:

> Approve a change once it definitely improves the overall code health of the system, even if the change isn't perfect.

There is no such thing as "perfect" code—only better code. Reviewers should pursue continuous improvement, not perfection. A change that improves maintainability, readability, or understandability should not be delayed for days or weeks because it isn't "perfect."

### Balancing Interests

Code review requires balancing two needs:

1. **Developer progress** - Developers must make forward progress. Overly restrictive reviews discourage future improvements.
2. **Code quality** - Each change must maintain or improve codebase health.

### Decision-Making Principles

When reviewing, apply these principles in order:

1. **Technical facts and data** supersede opinions and personal preferences
2. **Style guides are authoritative** - style matters not covered by the guide should match existing code
3. **Software design** is governed by engineering principles, not personal preference
4. **When multiple valid approaches exist** with supporting evidence, accept the author's preference

## Review Categories

Evaluate code across these eight areas:

### 1. Design

- Does this change belong in this codebase?
- Does it integrate well with the rest of the system?
- Is now the right time to add this functionality?
- Does the overall architecture make sense?

### 2. Functionality

- Does the code do what the author intended?
- Is it good for the users (both end-users and future developers)?
- Consider edge cases, concurrency issues, and error handling
- For UI changes: look for behaviour that might confuse users
- For parallel programming: watch for race conditions and deadlocks

### 3. Complexity

- Is any part more complicated than necessary?
- Can it be understood quickly by other developers?
- Watch for **over-engineering**: solving hypothetical future problems rather than current needs
- "Too complex" means: can't be understood quickly, likely to introduce bugs when modified, or difficult to call correctly

### 4. Tests

- Are there appropriate unit, integration, or end-to-end tests?
- Will the tests actually fail when the code is broken?
- Are the assertions correct and meaningful?
- Do tests make simple and useful assertions?
- Tests are code too—don't accept complexity just because it's "only tests"

### 5. Naming

- Are names clear and descriptive?
- Do they communicate purpose without excessive length?
- A good name is long enough to communicate what it does without being so long it's hard to read

### 6. Comments

- Do comments explain **why**, not **what**?
- Comments should contain information the code itself cannot express
- Are regular expressions or complex algorithms explained?
- Is there unnecessary commentary that restates the obvious?
- If code needs explanation, consider rewriting it to be clearer instead

### 7. Style

- Does the code follow the project's style guide?
- Is it consistent with surrounding code?
- Style issues should be prefixed with "Nit:" to indicate they're minor

### 8. Documentation

- If the change affects how users interact with the system, is documentation updated?
- Are READMEs, API docs, and guides kept current?
- Deleted or deprecated functionality should have documentation removed

## Severity Levels

Classify findings by severity to communicate their importance:

### Blocking

Must be fixed before approval. Use for issues that:
- Degrade overall code health
- Introduce bugs or security vulnerabilities
- Break existing functionality
- Violate critical design principles

**Never approve changes that worsen code health** (except in genuine emergencies).

### Suggestion

Should be fixed but not strictly required. Use for:
- Improvements that would make code cleaner
- Better approaches that aren't critical
- Opportunities for simplification

### Nit

Minor style or preference issues. Always prefix with "Nit:":
- Formatting inconsistencies
- Minor naming improvements
- Small style guide deviations

The author may choose to address or ignore these.

### Positive

Call out good patterns to reinforce them:
- Clever but readable solutions
- Good test coverage
- Clear documentation
- Proper error handling

Recognition is valuable—review isn't only about finding problems.

## Review Approach

Follow this multi-phase process to produce thorough reviews:

### Phase 1: Initial Review

Conduct a complete review of the code:

#### Step 1: Assess the Big Picture

Before diving into details, ask: **Does this change make sense at all?**

- Read the description/commit message
- Understand the intent and context
- If the change is fundamentally wrong, reject it promptly with constructive feedback

If there are major design problems, raise them immediately. Don't let the developer build more work on a problematic foundation.

#### Step 2: Examine Core Components

Identify the files containing the bulk of logical changes and review these first:

- These provide context for understanding smaller changes
- Major issues here often make other review comments irrelevant
- Consider reviewing tests before implementation to understand intended behaviour

#### Step 3: Review Remaining Files Systematically

Once you've confirmed no fundamental issues exist:

- Work through remaining files in a logical order
- Look for issues in each review category
- Ensure nothing is missed

### Phase 2: Critique

After completing the initial review, **launch a subagent using the Task tool** to critique the review. Using a separate agent provides a genuinely fresh perspective.

**You MUST use the Task tool** with `subagent_type: "general-purpose"` to run the critique. Do not attempt to critique your own review directly.

Provide the subagent with:
1. The original code being reviewed (file paths or content)
2. Your complete initial review output
3. Instructions to critique the review

The critique subagent examines the initial review and looks for:

- **Missed issues** - Problems in the code that the initial review didn't catch
- **Incorrect severity** - Findings that should be upgraded or downgraded
- **False positives** - Findings that aren't actually problems on closer inspection
- **Incomplete reasoning** - Suggestions that lack proper justification

Example Task tool invocation:

```
Task tool with subagent_type: "general-purpose"
prompt: |
  Critique this code review. You have access to the original code and the review output.

  Files to review: <list of files>

  Initial review output:
  <paste your review here>

  Your job is to find what the review missed or got wrong:
  1. Read the original code files
  2. Compare against the review findings
  3. Identify: missed issues, incorrect severity, false positives, incomplete reasoning
  4. Return your critique as a structured list of findings
```

### Phase 3: Synthesis

Combine the initial review with critique findings into a final output:

1. **Merge findings** - Add any new issues identified during critique
2. **Resolve conflicts** - When initial review and critique disagree:
   - Prefer higher severity (err on the side of caution)
   - Note disagreements with context when relevant
3. **Remove false positives** - Drop findings the critique identified as incorrect
4. **Annotate critique contributions** - Mark findings that came from the critique phase with `[Critique]`

#### Deciding on Additional Passes

After synthesis, decide whether another critique pass would add value:

- **Run another pass if:** The critique found significant issues, suggesting more may be lurking
- **Stop if:** The critique pass found nothing substantial or only minor adjustments

Limit to a maximum of 2 critique passes to avoid diminishing returns.

## Output Format

Structure review findings clearly:

```
## Summary

[1-2 sentence overview of the change and overall assessment]

## Findings

### Design
- [Severity] file:line - Description
- [Critique] [Severity] file:line - Description (added by critique pass)

### Functionality
- [Severity] file:line - Description

### Complexity
- [Severity] file:line - Description

### Tests
- [Severity] file:line - Description

### Naming
- [Severity] file:line - Description

### Comments
- [Severity] file:line - Description

### Style
- [Severity] file:line - Description

### Documentation
- [Severity] file:line - Description

## Positive Observations

- [Things done well worth noting]

## Verdict

[Approve / Request Changes / Discuss]

[Brief explanation of verdict]
```

### Annotation Format

- **Initial findings**: Listed without prefix, e.g., `[Blocking] file:line - Description`
- **Critique findings**: Prefixed with `[Critique]`, e.g., `[Critique] [Suggestion] file:line - Description`
- **Severity adjustments**: Note when critique changed severity, e.g., `[Upgraded from Suggestion] [Blocking] file:line - Description`

Omit empty categories. Group related findings together.

## Writing Review Comments

### Be Kind and Constructive

- Focus on the code, never the person
- Instead of "Why did you use X?" say "Using X here adds complexity because..."
- Assume competence—explain the issue, not that they should know better

### Explain Your Reasoning

Developers benefit from understanding **why**, not just **what** to change:
- This helps them learn and apply principles to future work
- Context prevents the same issues recurring
- It shows respect for their growth as engineers

### Balance Guidance with Autonomy

- Point out problems but let developers propose solutions
- Don't rewrite their code for them (unless severely problematic)
- Their solution may be better than what you'd suggest

### Request Code Changes, Not Explanations

If code is unclear:
- Ask for the code to be rewritten more clearly, or
- Ask for comments to be added to the code itself

Don't accept explanations only in review comments—future maintainers won't see them.

### Handle "Fix It Later" Carefully

When developers want to defer improvements:
- Cleanups "later" rarely happen once code is merged
- New complexity should be addressed before submission
- Only accept deferrals in genuine emergencies with tracked follow-up issues

## Reference

This skill is based on [Google's Engineering Practices: Code Review Guidelines](https://google.github.io/eng-practices/review/reviewer/).

For deeper questions or edge cases, consult the original documentation.

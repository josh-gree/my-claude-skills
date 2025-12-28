# Claude Code Skills Guide

A comprehensive guide to creating and managing Claude Code Skills.

## What Are Skills?

A **Skill** is a markdown file that teaches Claude how to do something specific. When you ask Claude something that matches a Skill's purpose, Claude automatically applies it.

**Key characteristics:**
- **Model-invoked**: Claude decides when to use them based on semantic matching with the description
- **Automatic discovery**: No need to explicitly call them
- **Context-aware**: Claude loads only metadata at startup, reading full instructions when needed
- **Shareable**: Can be distributed via projects, plugins, or organisation-wide settings

**Example use cases:**
- Reviewing PRs using your team's standards
- Generating commit messages in your preferred format
- Querying your company's database schema
- Processing PDFs with specific requirements

---

## How Skills Work

### Step 1: Discovery
At startup, Claude loads only the **name and description** of each available Skill. This keeps startup fast while giving Claude enough context to know when each Skill might be relevant.

### Step 2: Activation
When your request matches a Skill's description, Claude asks to use the Skill. You'll see a confirmation prompt before the full `SKILL.md` is loaded into context.

### Step 3: Execution
Claude follows the Skill's instructions, loading referenced files or running bundled scripts as needed.

---

## Creating Your First Skill

### Step 1: Create the Skill Directory

**Personal Skills** (available across all projects):
```bash
mkdir -p ~/.claude/skills/my-skill-name
```

**Project Skills** (shared with your team via git):
```bash
mkdir -p .claude/skills/my-skill-name
```

### Step 2: Write the SKILL.md File

Every Skill needs a `SKILL.md` file with YAML frontmatter and Markdown instructions:

```yaml
---
name: my-skill-name
description: Brief description of what this Skill does and when to use it
---

# My Skill Name

## Instructions
Provide clear, step-by-step guidance for Claude.

## Examples
Show concrete examples of using this Skill.
```

### Step 3: Load and Verify

Exit and restart Claude Code to load the new Skill. Then verify:
```
What Skills are available?
```

### Step 4: Test the Skill

Ask Claude a question matching the Skill's description. Claude should confirm it wants to use the Skill before loading the full content.

---

## File Structure

### Basic Structure (Single File)
```
my-skill/
└── SKILL.md (required)
```

### Complex Structure (Multiple Files)
```
my-skill/
├── SKILL.md              # Overview and navigation (required)
├── reference.md          # Detailed documentation
├── examples.md           # Usage examples
└── scripts/
    ├── helper.py         # Utility script
    └── validate.py       # Validation script
```

### Key Principles
- **Keep SKILL.md under 500 lines** for optimal performance
- **Use progressive disclosure**: Essential info in SKILL.md, detailed reference material in separate files
- **One level deep**: Reference files should link directly from SKILL.md, not nested multiple levels
- **Use forward slashes**: Always `reference/guide.md`, never `reference\guide.md`

---

## SKILL.md Reference

### Required YAML Fields

| Field | Details |
|-------|---------|
| `name` | Lowercase letters, numbers, hyphens only (max 64 characters). Should match directory name. Cannot contain "anthropic" or "claude" |
| `description` | What the Skill does and when to use it (max 1024 characters). Critical for discovery |

### Optional YAML Fields

| Field | Details |
|-------|---------|
| `allowed-tools` | Tools Claude can use without asking permission when this Skill is active. E.g., `Read, Grep, Glob` |
| `model` | Specific Claude model to use when this Skill is active |

### Example

```yaml
---
name: explaining-code
description: Explains code with visual diagrams and analogies. Use when explaining how code works, teaching about a codebase, or when the user asks "how does this work?"
allowed-tools: Read, Grep, Glob
---

# Explaining Code

When explaining code, always include:

1. **Start with an analogy**: Compare the code to something from everyday life
2. **Draw a diagram**: Use ASCII art to show the flow or relationships
3. **Walk through the code**: Explain step-by-step what happens
4. **Highlight a gotcha**: What's a common mistake or misconception?

Keep explanations conversational.
```

---

## Skill Locations

| Location | Path | Applies to |
|----------|------|-----------|
| Enterprise | Set by administrator | All users in your organisation |
| Personal | `~/.claude/skills/` | You, across all projects |
| Project | `.claude/skills/` | Anyone working in this repository |
| Plugin | `skills/` inside plugin directory | Anyone with the plugin installed |

**Priority**: Enterprise > Personal > Project > Plugin

---

## Progressive Disclosure Pattern

Keep SKILL.md focused by moving detailed content to separate files. Claude loads additional files only when needed.

### Example: High-Level Guide with References

````markdown
---
name: pdf-processing
description: Extracts text and tables from PDF files, fills forms, and merges documents. Use when working with PDF files.
---

# PDF Processing

## Quick start

Extract text with pdfplumber:
```python
import pdfplumber
with pdfplumber.open("file.pdf") as pdf:
    text = pdf.pages[0].extract_text()
```

## Advanced features

- **Form filling**: See [FORMS.md](FORMS.md) for complete guide
- **API reference**: See [REFERENCE.md](REFERENCE.md) for all methods
- **Examples**: See [EXAMPLES.md](EXAMPLES.md) for common patterns
````

---

## Best Practices

### Write Specific, Discoverable Descriptions

The description is how Claude decides whether to use your Skill.

**Good** (specific with trigger terms):
```yaml
description: Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.
```

**Bad** (too vague):
```yaml
description: Helps with documents
```

### Use Gerund Naming Convention

Skill names should use the `verb-ing` format:
- `processing-pdfs`
- `analysing-spreadsheets`
- `managing-databases`

**Avoid:**
- Vague names: `helper`, `utils`, `tools`
- Reserved words: `anthropic-helper`, `claude-tools`

### Keep Content Concise

Assume Claude is already very smart. Only add context Claude doesn't have.

**Good** (~50 tokens):
````markdown
## Extract PDF text

Use pdfplumber:
```python
import pdfplumber
with pdfplumber.open("file.pdf") as pdf:
    text = pdf.pages[0].extract_text()
```
````

**Bad** (~150 tokens):
```markdown
## Extract PDF text

PDF files are common. To extract text, use a library like pdfplumber.
First install it... Then use it like this... PDF files can be...
```

### Set Appropriate Degrees of Freedom

**High freedom** (guidance only):
```markdown
## Code review process
1. Analyse code structure and organisation
2. Check for potential bugs
3. Suggest improvements for readability
```

**Low freedom** (specific instructions):
````markdown
## Database migration

Run exactly this script:
```bash
python scripts/migrate.py --verify --backup
```

Do not modify the command.
````

### Use Workflows for Complex Tasks

````markdown
## PDF form filling workflow

Progress checklist:
- [ ] Step 1: Analyse the form (run analyse_form.py)
- [ ] Step 2: Create field mapping (edit fields.json)
- [ ] Step 3: Validate mapping (run validate_fields.py)
- [ ] Step 4: Fill the form (run fill_form.py)
````

### Include Feedback Loops

```markdown
## Document editing process

1. Make your edits to the document
2. **Validate immediately**: `python scripts/validate.py`
3. If validation fails:
   - Review the error message
   - Fix the issues
   - Run validation again
4. **Only proceed when validation passes**
```

### Provide Examples

````markdown
## Commit message format

**Example 1:**
Input: Added user authentication
Output:
```
feat(auth): implement JWT-based authentication

Add login endpoint and token validation middleware
```
````

---

## Tool Restrictions

Use `allowed-tools` to limit what Claude can do when a Skill is active:

```yaml
---
name: reading-files-safely
description: Read files without making changes.
allowed-tools: Read, Grep, Glob
---
```

### Bash Tool Restrictions

Format: `Bash(category:*)`

Examples:
- `Bash(python:*)` - Run any Python command
- `Bash(git:*)` - Run git commands
- `Bash(curl:*)` - Use curl for HTTP requests

---

## Sharing and Distribution

### Project Skills (Team Sharing via Git)

```bash
mkdir -p .claude/skills/my-skill
# Create SKILL.md
git add .claude/skills/
git commit -m "Add my-skill"
```

Anyone who clones the repository gets the Skills automatically.

### Plugin Distribution

Create a plugin with a `skills/` directory:

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json
└── skills/
    └── my-skill/
        └── SKILL.md
```

---

## Troubleshooting

### Skill Not Triggering

**Problem**: You created a Skill but Claude doesn't use it.

**Solution**: The description is likely too vague. Good descriptions answer:
1. What does this Skill do? (specific actions)
2. When should Claude use it? (trigger keywords)

### Skill Doesn't Load

**Check the file path** (must be case-sensitive `SKILL.md`):
- Personal: `~/.claude/skills/my-skill/SKILL.md`
- Project: `.claude/skills/my-skill/SKILL.md`

**Check YAML syntax**:
- `---` must start on line 1 with no blank lines before it
- Use spaces (not tabs) for indentation
- Required fields: `name` and `description`

### Skill Has Errors

1. Check dependencies are installed
2. Check script permissions: `chmod +x scripts/*.py`
3. Check file paths: Use forward slashes only

---

## Skills vs Other Customisation Options

| Use this | When you want to | When it runs |
|----------|-----------------|--------------|
| **Skills** | Give Claude specialised knowledge | Claude chooses when relevant |
| **Slash commands** | Create reusable prompts | You type `/command` |
| **CLAUDE.md** | Set project-wide instructions | Loaded in every conversation |
| **Subagents** | Delegate tasks to separate context | Claude delegates or you invoke |
| **Hooks** | Run scripts on events | Fires on specific tool events |
| **MCP servers** | Connect Claude to external tools | Claude calls MCP tools as needed |

---

## Complete Example: PR Review Skill

```bash
mkdir -p .claude/skills/pr-review
```

**`.claude/skills/pr-review/SKILL.md`:**

```yaml
---
name: reviewing-pull-requests
description: Reviews pull requests for code quality, best practices, security issues, and adherence to team standards. Use when reviewing code changes or pull requests.
allowed-tools: Read, Grep, Glob
---

# PR Review

## Review checklist

When reviewing a PR, check:

1. **Code quality**
   - Clear variable and function names
   - Appropriate comments explaining complex logic
   - No obvious performance issues

2. **Best practices**
   - Follows project coding standards
   - Proper error handling
   - Appropriate test coverage

3. **Security**
   - No credential exposure
   - Input validation
   - SQL injection prevention (if applicable)

4. **Completeness**
   - Handles edge cases
   - Documentation updated
   - Tests included

See [CHECKLIST.md](CHECKLIST.md) for detailed review criteria.
```

---

## Key Takeaways

1. **Skills are discovered by description**: Write specific descriptions with trigger keywords
2. **Keep SKILL.md focused**: Use progressive disclosure for detailed content
3. **One level of file references**: Link directly from SKILL.md to supporting files
4. **Use forward slashes**: Always `reference/guide.md`
5. **Name with gerunds**: `processing-pdfs` not `pdf-processor`
6. **Handle errors in scripts**: Don't punt error handling to Claude
7. **Include workflows**: Break complex tasks into clear steps
8. **Test with all models**: Verify with Haiku, Sonnet, and Opus
9. **Share via git**: Commit `.claude/skills/` to share with your team

#!/bin/bash

set -e

# Get the directory where this script lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SOURCE="$SCRIPT_DIR/skills"
SKILLS_TARGET="$HOME/.claude/skills"

# Create target directory if it doesn't exist
if [ ! -d "$SKILLS_TARGET" ]; then
    mkdir -p "$SKILLS_TARGET"
    echo "Created $SKILLS_TARGET"
fi

# Symlink each skill
for skill_dir in "$SKILLS_SOURCE"/*/; do
    skill_name=$(basename "$skill_dir")
    source_path="$SKILLS_SOURCE/$skill_name"
    target_path="$SKILLS_TARGET/$skill_name"

    # Remove existing symlink if present
    if [ -L "$target_path" ]; then
        rm "$target_path"
    fi

    ln -s "$source_path" "$target_path"
    echo "Linked: $skill_name"
done

echo "Done."

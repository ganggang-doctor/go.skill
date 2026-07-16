#!/usr/bin/env bash
# go (开工) — Skill Discovery Engine v1.0
# Scans installed skills and reports their names + descriptions for capability matching.
# Called by go SKILL.md at startup and when user installs new skills.
# Output: JSON to stdout (for programmatic use) + human-readable summary to stderr.

SKILL_DIR="${SKILL_DIR:-$HOME/.claude/skills}"
MCP_CONFIG="${MCP_CONFIG:-$HOME/.claude/settings.json}"

echo '{ "skills": [' >&2  # header to stderr for debug
first=true

# --- Scan skills ---
for skill_dir in "$SKILL_DIR"/*/; do
    name=$(basename "$skill_dir")
    skmd="$skill_dir/SKILL.md"

    if [ -f "$skmd" ]; then
        # Extract frontmatter fields
        desc=$(head -40 "$skmd" | grep -E '^description:' | head -1 | sed 's/^description:\s*//' | sed 's/>-//' | sed 's/>//' | tr -d '\n' | sed 's/  */ /g' | sed 's/^"//;s/"$//')
        skill_name=$(head -10 "$skmd" | grep -E '^name:' | head -1 | sed 's/^name:\s*//' | tr -d '"')
        [ -z "$skill_name" ] && skill_name="$name"

        # Scan for sub-skills
        sub_count=$(find "$skill_dir" -name "SKILL.md" -not -path "$skill_dir/SKILL.md" 2>/dev/null | wc -l)

        # Output JSON
        if [ "$first" = true ]; then first=false; else echo ','; fi
        cat <<JSONENTRY
    {
      "dir": "$name",
      "name": "$skill_name",
      "description": "$desc",
      "sub_skills": $sub_count,
      "path": "$skill_dir"
    }
JSONENTRY
    fi
done

# --- Scan MCP servers ---
echo ',' >&2
cat <<MCPENTRY
    {
      "_type": "mcp_servers",
      "source": "$MCP_CONFIG"
    }
MCPENTRY

echo '] }' >&2

# --- Human-readable summary (stderr) ---
echo "" >&2
echo "=== go (开工) Skill Scan $(date +%Y-%m-%d) ===" >&2
echo "Skills found: $(ls -d "$SKILL_DIR"/*/ 2>/dev/null | wc -l)" >&2
echo "" >&2
echo "Tip: Run 'python3 scripts/go_config.py --rescan' to update go's capability mapping." >&2

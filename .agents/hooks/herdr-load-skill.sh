#!/bin/sh
# SessionStart hook: pre-load the herdr skill into context so pane/tab control is
# available without invoking the Skill tool first.
#
# Shared across Claude Code profiles. Referenced from the SessionStart hooks in:
#   ~/.claude/settings.json
#   ~/.claude-akuity/settings.json
#
# Reads the skill from ~/.agents/skills/herdr (the source of truth the per-profile
# skills/ symlinks point at), so it works from any profile.
# No-op outside a Herdr-managed pane.

set -eu

# Drain the hook's stdin payload; we don't need it.
cat >/dev/null 2>&1 || true

[ "${HERDR_ENV:-}" = "1" ] || exit 0

SKILL_FILE="${HOME}/.agents/skills/herdr/SKILL.md"
[ -r "$SKILL_FILE" ] || exit 0
command -v python3 >/dev/null 2>&1 || exit 0

SKILL_FILE="$SKILL_FILE" python3 <<'PY'
import json
import os

with open(os.environ["SKILL_FILE"], encoding="utf-8") as handle:
    skill = handle.read()

header = (
    "Herdr is active in this session (HERDR_ENV=1). "
    "workspace={workspace} tab={tab} pane={pane} (this agent's own pane).\n"
    "The herdr skill is pre-loaded below, so you may inspect and control panes, "
    "tabs, workspaces, and other agents directly — no need to invoke the Skill "
    "tool for it first. Still follow its safety rules.\n\n"
).format(
    workspace=os.environ.get("HERDR_WORKSPACE_ID", "?"),
    tab=os.environ.get("HERDR_TAB_ID", "?"),
    pane=os.environ.get("HERDR_PANE_ID", "?"),
)

print(json.dumps({
    "hookSpecificOutput": {
        "hookEventName": "SessionStart",
        "additionalContext": header + skill,
    },
    "suppressOutput": True,
}))
PY

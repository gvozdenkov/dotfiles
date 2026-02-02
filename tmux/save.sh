#!/usr/bin/env bash
# tmux-save.sh: save tmux sessions, windows, panes, layouts, and full commands.

set -euo pipefail

TMUX_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SNAPSHOT_FILE="${TMUX_DIR}/.session"
d=$'\t'

# 1) Save window layouts (per window)
# Format: session_name<TAB>window_index<TAB>window_name<TAB>window_layout
tmux list-windows -a -F "#S${d}#I${d}#W${d}#{window_layout}" \
  > "${SNAPSHOT_FILE}.layouts"

# 2) Save panes (per pane) to a temporary file including pane_pid
# Temp format: session  win_idx  win_name  pane_idx  pane_path  pane_cmd  pane_pid
tmp_panes="$(mktemp)"
tmux list-panes -a -F "#S${d}#I${d}#W${d}#P${d}#{pane_current_path}${d}#{pane_current_command}${d}#{pane_pid}" \
  > "${tmp_panes}"

# 3) Post-process panes: resolve full command from pane_pid and write final .panes
# Final format: session  win_idx  win_name  pane_idx  pane_path  full_cmd
{
  while IFS=$'\t' read -r session win_idx win_name pane_idx pane_path short_cmd pane_pid; do
    full_cmd=""

    # Try to get full command from direct children of the shell (common case)
    if full_cmd=$(ps -o args= --ppid "${pane_pid}" 2>/dev/null | head -n1 | sed 's/[[:space:]]*$//'); then
      :
    fi

    # Fallback to the pane process itself if children are empty
    if [ -z "${full_cmd}" ]; then
      full_cmd=$(ps -o args= -p "${pane_pid}" 2>/dev/null | head -n1 | sed 's/[[:space:]]*$//') || true
    fi

    # Final fallback: use the short command tmux gave us
    if [ -z "${full_cmd}" ]; then
      full_cmd="${short_cmd}"
    fi

    # If it's just a shell (-bash, bash, zsh, etc.), treat as "no command"
    case "${full_cmd}" in
      -bash|bash|-zsh|zsh|-sh|sh)
        full_cmd=""
        ;;
    esac

    printf '%s\t%s\t%s\t%s\t%s\t%s\n' \
      "${session}" "${win_idx}" "${win_name}" "${pane_idx}" "${pane_path}" "${full_cmd}"
  done < "${tmp_panes}"
} > "${SNAPSHOT_FILE}.panes"

rm -f "${tmp_panes}"

echo "Saved tmux snapshot to ${SNAPSHOT_FILE}.layouts and ${SNAPSHOT_FILE}.panes"

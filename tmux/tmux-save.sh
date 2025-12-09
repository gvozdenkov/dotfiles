#!/usr/bin/env bash
# tmux-save.sh: save tmux sessions, windows, panes, and layouts.

set -euo pipefail

SNAPSHOT_FILE="$(pwd)/.session"

d=$'\t'

# 1) Save window layouts (per window)
# Format: session_name<TAB>window_index<TAB>window_name<TAB>window_layout
tmux list-windows -a -F "#S${d}#I${d}#W${d}#{window_layout}" \
  > "${SNAPSHOT_FILE}.layouts"

# 2) Save panes (per pane)
# Format: session_name<TAB>window_index<TAB>window_name<TAB>pane_index<TAB>pane_current_path<TAB>pane_current_command
tmux list-panes -a -F "#S${d}#I${d}#W${d}#P${d}#{pane_current_path}${d}#{pane_current_command}" \
  > "${SNAPSHOT_FILE}.panes"

echo "Saved tmux snapshot to ${SNAPSHOT_FILE}.layouts and ${SNAPSHOT_FILE}.panes"

#!/usr/bin/env bash
# tmux-restore.sh: restore tmux sessions, windows, panes, and layouts (1-based).

set -euo pipefail

BASE_SNAPSHOT="$(pwd)/.session"
LAYOUT_FILE="${BASE_SNAPSHOT}.layouts"
PANES_FILE="${BASE_SNAPSHOT}.panes"

[ -f "${LAYOUT_FILE}" ] || { echo "No layout file: ${LAYOUT_FILE}" >&2; exit 1; }
[ -f "${PANES_FILE}" ] || { echo "No panes file: ${PANES_FILE}" >&2; exit 1; }

declare -A WINDOW_LAYOUTS
declare -A CREATED_WINDOWS
declare -A CREATED_PANES

# ---------- 1) Load window layouts ----------
# LAYOUT_FILE: session  win_idx  win_name  layout
while IFS=$'\t' read -r session win_idx win_name layout; do
  win_key="${session}:${win_idx}"
  WINDOW_LAYOUTS["${win_key}"]="${layout}"
done < "${LAYOUT_FILE}"

# ---------- 2) Create sessions/windows and panes ----------
# PANES_FILE: session  win_idx  win_name  pane_idx  pane_path  pane_cmd
while IFS=$'\t' read -r session win_idx win_name pane_idx pane_path pane_cmd; do
  win_key="${session}:${win_idx}"
  pane_key="${win_key}:${pane_idx}"

  # Create session if missing (first window index = 1, first pane index = 1)
  if ! tmux has-session -t "${session}" 2>/dev/null; then
    echo "Creating session: ${session}"
    tmux new-session -d -s "${session}" -n "${win_name}" -c "${pane_path}"
    CREATED_WINDOWS["${win_key}"]=1
    CREATED_PANES["${win_key}:1"]=1

    # First pane in first window (pane 1)
    if [ "${pane_idx}" -eq 1 ] && [ -n "${pane_cmd}" ]; then
      tmux send-keys -t "${session}:1.1" "${pane_cmd}" C-m
    fi
    continue
  fi

  # Create window if missing
  if [ -z "${CREATED_WINDOWS[${win_key}]+x}" ]; then
    echo "Creating window ${win_idx} (${win_name}) in ${session}"
    tmux new-window -t "${session}" -n "${win_name}" -c "${pane_path}"
    CREATED_WINDOWS["${win_key}"]=1
    CREATED_PANES["${win_key}:1"]=1

    # First pane in this window
    if [ "${pane_idx}" -eq 1 ] && [ -n "${pane_cmd}" ]; then
      tmux send-keys -t "${session}:${win_idx}.1" "${pane_cmd}" C-m
    fi
    continue
  fi

  # Additional panes (pane_idx > 1)
  if [ "${pane_idx}" -gt 1 ] && [ -z "${CREATED_PANES[${pane_key}]+x}" ]; then
    echo "Adding pane ${pane_idx} to ${session}:${win_idx}"
    # Split from last pane in this window; your config uses -h / -v with -c already
    tmux split-window -t "${session}:${win_idx}." -c "${pane_path}"

    # New pane is the most recent ('.')
    if [ -n "${pane_cmd}" ]; then
      tmux send-keys -t "${session}:${win_idx}." "${pane_cmd}" C-m
    fi

    CREATED_PANES["${pane_key}"]=1
  fi
done < "${PANES_FILE}"

# ---------- 3) Apply stored layouts ----------
for key in "${!WINDOW_LAYOUTS[@]}"; do
  layout="${WINDOW_LAYOUTS[${key}]}"
  echo "Applying layout for ${key}: ${layout}"
  tmux select-layout -t "${key}" "${layout}" 2>/dev/null || true
done

echo "Tmux sessions restored from ${BASE_SNAPSHOT}.*"

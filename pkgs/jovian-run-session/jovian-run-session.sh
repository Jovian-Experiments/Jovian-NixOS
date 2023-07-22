#!/usr/bin/env bash
# Copyright 2020 Oliver Smith
# Copyright 2023 Jovian Experiments contributors
# SPDX-License-Identifier: GPL-3.0-or-later

# Modified for Jovian-NixOS from tinydm 1.1.3 (https://gitlab.com/postmarketOS/tinydm)
# This is just a `.desktop` launcher, intended to be run in an existing
# PAM session.

# $1: file
# $2: key
parse_xdg_desktop() {
	grep "^$2=" "$1" | cut -d "=" -f 2-
}

# $1: Exec line from .desktop file
run_session_wayland() {
	export XDG_SESSION_TYPE=wayland
	exec "$@"
}

# $1: Exec line from .desktop file
run_session_x() {
	export XDG_SESSION_TYPE=X11

	# startx needs the absolute executable path, otherwise it will not
	# recognize the executable as command to be executed
	cmd_startx="startx $(command -v "$1")"

	# 'Exec' in desktop entries may contain arguments for the executable:
	# https://specifications.freedesktop.org/desktop-entry-spec/desktop-entry-spec-latest.html#exec-variables
	shift
	for arg in "$@"; do
		cmd_startx="$cmd_startx $arg"
	done

	# shellcheck disable=SC2086
	exec $cmd_startx
}

run_session_jovian() {
	# Jovian: Search for the preferred session in XDG_DATA_DIRS
	#
	# We use Bash-isms here

	session="$1"

	session_dirs=()
	resolved=""
	resolved_type=""

	IFS=: command eval 'session_dirs=(${XDG_DATA_DIRS:-/usr/share})'

	while read -r candidate; do
		case "$(basename "$(dirname "$candidate")")" in
			wayland-sessions)
				resolved="$candidate"
				resolved_type="wayland"
				break
				;;
			xsessions)
				resolved="$candidate"
				resolved_type="x11"
				break
				;;
		esac
	done < <(find "${session_dirs[@]}" -maxdepth 2 -xtype f -name "$session.desktop" || true)

	if [[ -z "$resolved" ]]; then
		echo "ERROR: could not find '$session' session!"
		exit 1
	fi

	# The rest is basically the same

	desktop="$(basename "$resolved" | sed 's/\.desktop$//')"
	export XDG_SESSION_DESKTOP="$desktop"
	cmd="$(parse_xdg_desktop "$resolved" "Exec")"

	desktop_names="$(parse_xdg_desktop "$resolved" "DesktopNames")"
	if [ -n "$desktop_names" ]; then
		export XDG_CURRENT_DESKTOP="$desktop_names"
	fi

	echo "--- jovian-run-session ---"
	echo "Date:    $(date)"
	echo "Session: $resolved"
	echo "Desktop: $desktop"
	echo "Exec:    $cmd"
	echo "---"

	case "$resolved_type" in
		wayland)
			# shellcheck disable=SC2086
			run_session_wayland $cmd
			;;
		x11)
			# shellcheck disable=SC2086
			run_session_x $cmd
			;;
		*)
			echo "ERROR: could not detect session type!"
			exit 1
			;;
	esac
}

run_session_jovian "$1"

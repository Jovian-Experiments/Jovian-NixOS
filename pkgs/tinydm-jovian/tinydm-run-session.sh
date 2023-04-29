#!/usr/bin/env bash
# Copyright 2020 Oliver Smith
# SPDX-License-Identifier: GPL-3.0-or-later

# Modified for Jovian-NixOS from tinydm 1.1.3
# Upstream: https://gitlab.com/postmarketOS/tinydm
# Our modifications are contained in run_session_jovian

setup_log() {
	logfile=${XDG_STATE_HOME:-~/.local/state}/tinydm.log
	mkdir -p "$(dirname "$logfile")"
        if [ -f "$logfile" ]; then
		# keep previous log file around
		mv "$logfile" "$logfile".old
        fi

	exec >"$logfile" 2>&1
}

source_profile() {
	for profile in /etc/profile "$HOME"/.profile; do
		if [ -f "$profile" ]; then
			# shellcheck disable=SC1090
			. "$profile"
		fi
	done
}

# $1: session type (i.e. 'wayland', or 'x11')
source_session_profiles() {
	session_type="$1"
	if [ "$session_type" != "wayland" ] && [ "$session_type" != "x11" ]; then
		echo "Unknown session type: $session_type"
		exit 1
	fi

	for file in "/etc/tinydm.d/env-${session_type}.d/"*; do
		if ! [ -e "$file" ]; then
			continue
		fi

		echo "tinydm: sourcing file: $file"
		# shellcheck disable=SC1090
		. "$file"
	done
}


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

run_session() {
	target="/var/lib/tinydm/default-session.desktop"

	if ! [ -e "$target" ]; then
		echo "ERROR: no session configured!"
		exit 1
	fi

	resolved="$(realpath "$target")"
	desktop="$(basename "$resolved" | sed 's/\.desktop$//')"
	export XDG_SESSION_DESKTOP="$desktop"
	cmd="$(parse_xdg_desktop "$resolved" "Exec")"

	desktop_names="$(parse_xdg_desktop "$resolved" "DesktopNames")"
	if [ -n "$desktop_names" ]; then
		export XDG_CURRENT_DESKTOP="$desktop_names"
	fi

	echo "--- tinydm ---"
	echo "Date:    $(date)"
	echo "Session: $resolved"
	echo "Desktop: $desktop"
	echo "Exec:    $cmd"
	echo "---"

	case "$resolved" in
		/usr/share/wayland-sessions*)
			source_session_profiles wayland
			# shellcheck disable=SC2086
			run_session_wayland $cmd
			;;
		/usr/share/xsessions*)
			source_session_profiles x11
			# shellcheck disable=SC2086
			run_session_x $cmd
			;;
		*)
			echo "ERROR: could not detect session type!"
			exit 1
			;;
	esac
}

run_session_jovian() {
	# Jovian: Search for the preferred session in XDG_DATA_DIRS
	#
	# We use Bash-isms here

	: "${JOVIAN_PREFERRED_SESSION:=*}"

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
	done < <(find "${session_dirs[@]}" -maxdepth 2 -xtype f -name "$JOVIAN_PREFERRED_SESSION.desktop" || true)

	if [[ -z "$resolved" ]]; then
		echo "ERROR: could not find preferred session!"
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

	echo "--- tinydm ---"
	echo "Date:    $(date)"
	echo "Session: $resolved"
	echo "Desktop: $desktop"
	echo "Exec:    $cmd"
	echo "---"

	case "$resolved_type" in
		wayland)
			source_session_profiles wayland
			# shellcheck disable=SC2086
			run_session_wayland $cmd
			;;
		x11)
			source_session_profiles x11
			# shellcheck disable=SC2086
			run_session_x $cmd
			;;
		*)
			echo "ERROR: could not detect session type!"
			exit 1
			;;
	esac
}

#setup_log
source_profile
run_session_jovian

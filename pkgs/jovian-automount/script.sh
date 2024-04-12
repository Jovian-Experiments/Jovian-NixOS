
pathtoname() {
	udevadm info -p /sys/"$1" | awk -v FS== '/DEVNAME/ {print $2}'
}
urlencode() {
# From https://gist.github.com/HazCod/da9ec610c3d50ebff7dd5e7cac76de05
	[ -z "$1" ] || echo -n "$@" | hexdump -v -e '/1 "%02x"' | sed 's/\(..\)/%\1/g'
}
 stdbuf -oL -- udevadm monitor --udev -s block | while read -r -- _ _ event devpath _; do
	if [ "$event" = add ]; then
		devname=$(pathtoname "$devpath")
		if [[ "${devname}" =~ ^/dev/[a-zA-Z]+[0-9]+$ ]]; then
			mountpath=$(udisksctl mount --block-device "$devname" --no-user-interaction | grep -o "/[^ ]*$")
			if [[ -n "$mountpath" ]]; then
				echo "Mounting $devname to $mountpath"

				if [ -d "$mountpath/SteamLibrary" ]; then
					echo "SteamLibrary Found"
					library="$mountpath/SteamLibrary"
					url=$(urlencode "$library")
					if pgrep -x "steam" > /dev/null; then
							echo "Add library $library to Steam"
							echo "url: $url"
							systemd-run -M 1000@ --user --collect --wait sh -c "steam steam://addlibraryfolder/''${url}"
					fi
				fi
			fi
		fi
	fi
 done

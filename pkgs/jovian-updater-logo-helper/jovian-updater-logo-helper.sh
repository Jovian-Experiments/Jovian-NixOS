#!/usr/bin/env bash

#
# Tips for debugging:
#
#  - Pass `'canvas:red[128x64!]'` as the input image.
#

set -o pipefail
set -e
set -u
PS4=" $ "

if (( $# != 2 )); then
	2>&1 echo "Error: expecting two arguments."
	echo "Usage: ${0##*/} <input> <output>"
	exit 1
fi

logo="$1"; shift
output="$1"; shift

# This is the number of degrees the native orientation of the display is at.
#
# Note that the updater applet applies the counter-rotation for us.
# This is used to correctly build up the image.
display_rotation=$(
	# drm_info will report the orientation this way:
	# ```
	# │   │       └───"panel orientation" (immutable): enum {Normal, Upside Down, Left Side Up, Right Side Up} = Right Side Up
	# ```
	# We're keeping the part after the `=`.
	case "$(drm_info | grep 'panel orientation' | head -n1 | cut -d'=' -f2)" in
		*Left*Side*)  echo '270';;
		*Upside*)     echo '180';;
		*Right*Side*) echo  '90';;
		*)            echo   '0';;
	esac
)

# Gets the "preferred" display resolution
resolution=$(
	# This following pipe will more than likely SIGPIPE.
	# So let's not fail...
	set +o pipefail
	# Prevent non-existent files from mucking up the output
	shopt -s nullglob
	(
		# Prefer eDP outputs, or else any DRM output
		cat /sys/class/drm/card*-eDP-*/modes /sys/class/drm/card*-*-*/modes /dev/null
		# pipe "nothing" in if `nullglob` fails to glob anything            ^^^^^^^^^
		# otherwise `cat` will expect to consume `stdin` if given no parameters.

		# If for some reason this fails, fallback on a safe resolution.
		echo "1920x1080"
	) | head -n1 # Save only the first match
)

# The image dimension will be used as our canvas size.
if [[ "$display_rotation" == "0" || "$display_rotation" == "180" ]]; then
	image_height=${resolution#*x}
	image_width=${resolution%x*}
else
	image_height=${resolution%x*}
	image_width=${resolution#*x}
fi

# Build up a `magick` invocation.
MAGICK_INVOCATION=(
	magick

	# Create an empty image, with the panel-native resolution
	"canvas:black[${image_width}x${image_height}!]"

	# Switch default composition gravity to top-left
	-gravity NorthWest
)

if [[ "$logo" == "--bgrt" ]]; then
	# Status field described here:
	#  - https://uefi.org/htmlspecs/ACPI_Spec_6_4_html/05_ACPI_Software_Programming_Model/ACPI_Software_Programming_Model.html#boot-graphics-resource-table-bgrt
	bgrt_rotation="$(( ($(cat /sys/firmware/acpi/bgrt/status) >> 1) & 2#11 ))"
	bgrt_xoffset=$(cat /sys/firmware/acpi/bgrt/xoffset)
	bgrt_yoffset=$(cat /sys/firmware/acpi/bgrt/yoffset)
	bgrt_dimensions="$(magick identify /sys/firmware/acpi/bgrt/image  | cut -d' ' -f3)"
	bgrt_height=${bgrt_dimensions#*x}
	bgrt_width=${bgrt_dimensions%x*}

	case "$bgrt_rotation" in
	"$(( 2#00 ))")
		bgrt_offset="+$((
			bgrt_xoffset
		))+$((
			bgrt_yoffset
		))"
		bgrt_counter_rotation="0"
		;;
	"$(( 2#01 ))") #  90
		bgrt_offset="+$((
			bgrt_yoffset
		))+$((
			image_width - bgrt_width - bgrt_xoffset
		))"
		bgrt_counter_rotation="-90"
		;;
	"$(( 2#10 ))") # 180
		bgrt_offset="+$((
			image_width - bgrt_width - bgrt_xoffset
		))+$((
			image_height - bgrt_height - bgrt_yoffset
		))"
		bgrt_counter_rotation="180"
		;;
	"$(( 2#11 ))") # -90
		bgrt_offset="+$((
			image_height - bgrt_height - bgrt_yoffset
		))+$((
			bgrt_xoffset
		))"
		bgrt_counter_rotation="90"
	;;
	esac

	MAGICK_INVOCATION+=(
		# Put the canvas back into the panel native orientation.
		-rotate $(( display_rotation ))

		# Add the BGRT (bmp image)
		# Group operation so we don't operate on the canvas.
		'('
			# Load the image
			"/sys/firmware/acpi/bgrt/image"

			# Rotate the BGRT to its expected rotation for composition
			-rotate $(( bgrt_counter_rotation ))

			# At its defined offset, again considering pre-composed rotation
			-geometry "$bgrt_offset"
		')'

		# (This means 'add' for the previous image)
		-composite

		# Undo the native orientation we added back.
		-rotate -$(( display_rotation ))
	)
else
	MAGICK_INVOCATION+=(
		# Add the logo
		"$logo"
		# Centered
		-gravity center
		# (This means 'add')
		-composite
	)
fi

# Final fixups to the image
MAGICK_INVOCATION+=(
	# Ensures crop crops a single image with gravity
	-gravity center

	# Crop to 16:9... always.
	# Steam scales the image, whichever dimensions to a 16:9 aspect ratio.
	# A 800px high image on steam deck will be scaled to 720p size.
	-crop 16:9

	# Save to this location.
	"$output"
)

# Run the command, and also print its invocation.
set -x
"${MAGICK_INVOCATION[@]}"

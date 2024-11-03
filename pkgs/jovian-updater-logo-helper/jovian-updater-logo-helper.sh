#!/usr/bin/env bash

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
resolution=$(cat /sys/class/drm/card*-eDP-*/modes | head -n1)

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
)

MAGICK_INVOCATION+=(
	# Add the logo
	"$logo"
	# Centered
	-gravity center
	# (This means 'add')
	-composite
)

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

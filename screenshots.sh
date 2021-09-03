#!/bin/bash

set -ex


function get_abs_path {
    local file_path="$1"
    echo "$( cd "$(dirname "$file_path")" >/dev/null 2>&1 ; pwd -P )"
}

mkdir -p screenshots

if [ "$1" = '--test-without-building' ]; then
    EXTRA_FAST_LANE_ARGS='--test_without_building'
    shift
fi

if [ $# -eq 1 ]; then
  LANGUAGES=$1
else
  for PATH in Blockzilla/*.lproj; do
    FILE="${PATH##*/}"
    if [ -n "$LANGUAGES" ]; then
      LANGUAGES="$LANGUAGES "
    fi
    LANGUAGES="$LANGUAGES${FILE%.lproj}"
  done
fi

echo "$LANGUAGES"
exit 0

DEVICE="iPhone 11"

for PRODUCT in Focus Klar; do
    echo "Snapshotting $PRODUCT on $DEVICE"
        DEVICEDIR="${DEVICE// /}"
        mkdir -p "screenshots/$PRODUCT/$DEVICEDIR"
        fastlane snapshot --project Blockzilla.xcodeproj --scheme "${PRODUCT}SnapshotTests" \
          --derived_data_path screenshots-derived-data \
          --skip_open_summary \
          --erase_simulator --localize_simulator \
          --devices "$DEVICE" \
          --languages "$LANGUAGES" \
          --output_directory "screenshots/$PRODUCT/$DEVICEDIR" \
           $EXTRA_FAST_LANE_ARGS
    echo "Fastlane exited with code: $?"
done

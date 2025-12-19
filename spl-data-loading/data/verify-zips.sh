#!/bin/sh
set -e

die () {
  echo >&2 "$@"
  exit 1
}

ZIPS_DIR=$1
EXPECTED_ZIP_COUNT=$2

ZIP_COUNT=$(find "$ZIPS_DIR" -name '*.zip' -exec ls {} \; | wc -l)

[ "$ZIP_COUNT" -eq "$EXPECTED_ZIP_COUNT" ] || \
  die "expected $EXPECTED_ZIP_COUNT zip files"

# Verify integrity of downloaded zip files.
for f in "$ZIPS_DIR"/*.zip; do
  unzip -tq "$f"
done

echo "All $ZIP_COUNT zip files passed integrity checks."
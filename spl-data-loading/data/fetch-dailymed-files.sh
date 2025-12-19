#!/bin/sh
set -e
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
# (Amazon) export https_proxy=http://10.172.18.7:8080/

DM_RELEASE_URL="https://dailymed-data.nlm.nih.gov/public-release-files"
RETRIES=10

echo "======================================================================="
echo "Downloading of DailyMed files started. [ $(date) ]"
echo "======================================================================="

DM_DIR="$SCRIPT_DIR"/dailymed
LABELING_DIR="$DM_DIR"/labeling

rm -f "$LABELING_DIR"/*.zip

# Download DailyMed labeling files.
cd "$LABELING_DIR"
xargs -n 1 -P 8 curl --remote-name --silent --show-error --retry $RETRIES << END_URLS
"$DM_RELEASE_URL"/dm_spl_release_human_rx_part1.zip
"$DM_RELEASE_URL"/dm_spl_release_human_rx_part2.zip
"$DM_RELEASE_URL"/dm_spl_release_human_rx_part3.zip
"$DM_RELEASE_URL"/dm_spl_release_human_rx_part4.zip
"$DM_RELEASE_URL"/dm_spl_release_human_rx_part5.zip
"$DM_RELEASE_URL"/dm_spl_release_human_otc_part1.zip
"$DM_RELEASE_URL"/dm_spl_release_human_otc_part2.zip
"$DM_RELEASE_URL"/dm_spl_release_human_otc_part3.zip
"$DM_RELEASE_URL"/dm_spl_release_human_otc_part4.zip
"$DM_RELEASE_URL"/dm_spl_release_human_otc_part5.zip
"$DM_RELEASE_URL"/dm_spl_release_human_otc_part6.zip
"$DM_RELEASE_URL"/dm_spl_release_human_otc_part7.zip
"$DM_RELEASE_URL"/dm_spl_release_human_otc_part8.zip
"$DM_RELEASE_URL"/dm_spl_release_human_otc_part9.zip
"$DM_RELEASE_URL"/dm_spl_release_human_otc_part10.zip
"$DM_RELEASE_URL"/dm_spl_release_homeopathic.zip
"$DM_RELEASE_URL"/dm_spl_release_animal.zip
"$DM_RELEASE_URL"/dm_spl_release_remainder.zip
END_URLS

# Verify DailyMed labeling files.
"$SCRIPT_DIR/verify-zips.sh" "$LABELING_DIR" 18

# Download DailyMed indexing files.
cd "$DM_DIR"
curl --remote-name --silent --show-error --retry $RETRIES  "$DM_RELEASE_URL"/pharmacologic_class_indexing_spl_files.zip
curl --remote-name --silent --show-error --retry $RETRIES "$DM_RELEASE_URL"/fda_initiated_inactive_ndcs_indexing_spl_files.zip

# Verify DailyMed indexing files.
"$SCRIPT_DIR/verify-zips.sh" "$DM_DIR" 2

echo "======================================================================="
echo "Downloading of DailyMed files completed. [ $(date) ]"
echo "======================================================================="

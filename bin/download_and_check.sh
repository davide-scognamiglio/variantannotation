#!/usr/bin/env bash
# set -eo pipefail

# Usage:
# download_and_check.sh <url> <tolerance_fraction> <method> <out>
# Example: download_and_check.sh "https://example.com/file.gz" 0.1 wget

URL="$1"
TOLERANCE_FRACTION="$2"
METHOD="${3:-wget}"  # default to wget if not specified
OUT="$4"

echo $URL
echo $TOLERANCE_FRACTION
echo $METHOD


echo "[INFO] Checking remote size for $OUT"

# Get remote file size
REMOTE_SIZE=$(curl -sIL "$URL" \
  | tr -d '\r' \
  | awk '/^[[:space:]]*[Cc]ontent-[Ll]ength:/ {size=$2} END{print size}')



echo "URL:"
echo $URL
echo "REMOTE_SIZE:"
echo $REMOTE_SIZE

echo "command output:"
curl -sI "$URL" 

if [ -z "$REMOTE_SIZE" ]; then
    echo "[ERROR] Unable to determine remote size for $OUT"
    exit 1
fi

# Compute absolute tolerance
TOLERANCE=$(awk "BEGIN {printf \"%d\", $REMOTE_SIZE * $TOLERANCE_FRACTION}")

echo "[INFO] Remote size: $REMOTE_SIZE bytes"
echo "[INFO] Allowed tolerance: $TOLERANCE bytes"

# Download file
if [ "$METHOD" == "wget" ]; then
    wget --no-check-certificate -c --tries=5 --timeout=30 "$URL" -O "$OUT"
elif [ "$METHOD" == "curl" ]; then
    curl -L --retry 5 --retry-delay 5 --retry-max-time 300 -o "$OUT" "$URL"
else
    echo "[ERROR] Unknown method: $METHOD"
    exit 1
fi

# Check downloaded file size
LOCAL_SIZE=$(stat -c%s "$OUT")
DIFF=$(( REMOTE_SIZE > LOCAL_SIZE ? REMOTE_SIZE - LOCAL_SIZE : LOCAL_SIZE - REMOTE_SIZE ))

if [ "$DIFF" -gt "$TOLERANCE" ]; then
    echo "[ERROR] File size mismatch for $OUT"
    echo "        Remote:  $REMOTE_SIZE"
    echo "        Local:   $LOCAL_SIZE"
    echo "        Diff:    $DIFF"
    echo "        Allowed: $TOLERANCE"
    exit 1
fi

echo "[INFO] $OUT downloaded successfully and within tolerance"
echo "        Remote:  $REMOTE_SIZE"
echo "        Local:   $LOCAL_SIZE"
echo "        Diff:    $DIFF"
echo "        Allowed: $TOLERANCE"

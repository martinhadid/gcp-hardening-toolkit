#!/usr/bin/env bash
# Script Name: export_cai_state.sh
# Purpose: Zero-touch CAI state export with deterministic execution validation.

read -p "Enter target GCP Project ID: " PROJECT_ID
if [[ -z "$PROJECT_ID" ]]; then
  echo "Execution aborted: Project ID is required."
  exit 1
fi

DATASET_NAME="hardening_agent_cai_state"

echo "Ensuring Cloud Asset API is enabled for ${PROJECT_ID}..."
gcloud services enable cloudasset.googleapis.com --project="${PROJECT_ID}" --quiet

echo "Ensuring standardized BigQuery dataset '${DATASET_NAME}' exists..."
bq mk --force --dataset "${PROJECT_ID}:${DATASET_NAME}" 2>/dev/null || true

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
TABLE_NAME="cai_state_${TIMESTAMP}"
FULLY_QUALIFIED_TABLE="projects/${PROJECT_ID}/datasets/${DATASET_NAME}/tables/${TABLE_NAME}"

echo "Initiating CAI batch export to BigQuery table: ${DATASET_NAME}.${TABLE_NAME}..."

# Execute the export and capture the asynchronous output
EXPORT_OUT=$(gcloud asset export \
  --project="${PROJECT_ID}" \
  --asset-types="compute.googleapis.com/Instance,compute.googleapis.com/Firewall,iam.googleapis.com/ServiceAccount" \
  --content-type=resource \
  --bigquery-table="${FULLY_QUALIFIED_TABLE}" \
  --output-bigquery-force 2>&1)

# Echo the output so you have visibility
echo "$EXPORT_OUT"

# Extract the operation path using Regex
OP_PATH=$(echo "$EXPORT_OUT" | grep -oE "projects/[0-9]+/operations/ExportAssets/[a-zA-Z]+/[a-f0-9]+")

if [[ -z "$OP_PATH" ]]; then
  echo "Execution aborted: Failed to extract operation path. Review the logs above."
  exit 1
fi

echo "Export triggered. Polling GCP API for completion (this usually takes 30s - 3m)..."

# Blocking loop to validate operation state
while true; do
  # Query the operation status specifically for the 'done' boolean
  IS_DONE=$(gcloud asset operations describe "${OP_PATH}" --format="value(done)" 2>/dev/null)

  # The API returns 'True' when finished (either success or failure)
  if [[ "$IS_DONE" == "True" || "$IS_DONE" == "true" ]]; then
    echo -e "\nState capture complete and validated. Table ${DATASET_NAME}.${TABLE_NAME} is fully populated and ready for ingestion."
    break
  fi

  # Print a dot to show active polling and sleep for 5 seconds to avoid rate-limiting
  echo -n "."
  sleep 5
done

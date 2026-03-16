#!/usr/bin/env bash
# Script Name: export_scc_state.sh
# Purpose: Zero-touch SCC findings state export with deterministic execution validation.

read -p "Enter target GCP Project ID: " PROJECT_ID
if [[ -z "$PROJECT_ID" ]]; then
  echo "Execution aborted: Project ID is required."
  exit 1
fi

DATASET_NAME="hardening_agent_scc_state"

echo "Ensuring Security Command Center API is enabled for ${PROJECT_ID}..."
gcloud services enable securitycenter.googleapis.com --project="${PROJECT_ID}" --quiet

echo "Ensuring standardized BigQuery dataset '${DATASET_NAME}' exists..."
bq mk --force --dataset "${PROJECT_ID}:${DATASET_NAME}" 2>/dev/null || true

echo "Initiating SCC batch export to BigQuery dataset: ${DATASET_NAME}..."

# Execute the export and capture the asynchronous output
EXPORT_OUT=$(gcloud scc findings export-to-bigquery "projects/${PROJECT_ID}" \
  --dataset="projects/${PROJECT_ID}/datasets/${DATASET_NAME}" 2>&1)

echo "$EXPORT_OUT"

# Extract the raw UUID operation name from the YAML output
OP_NAME=$(echo "$EXPORT_OUT" | awk '/^name:/ {print $2}' | tr -d '\r')

if [[ -z "$OP_NAME" ]]; then
  echo "Execution aborted: Failed to extract operation ID. Review the logs above."
  exit 1
fi

# Reconstruct the full API path to bypass gcloud flag inconsistencies
if [[ "$OP_NAME" != projects/* && "$OP_NAME" != organizations/* && "$OP_NAME" != folders/* ]]; then
  OP_PATH="projects/${PROJECT_ID}/operations/${OP_NAME}"
else
  OP_PATH="$OP_NAME"
fi

echo "Export triggered. Polling GCP API for completion (Operation: ${OP_NAME})..."
echo "(This usually takes 30s - 3m depending on finding volume)"

# Blocking loop to validate operation state
while true; do
  # Query the operation status specifically for the 'done' boolean
  IS_DONE=$(gcloud scc operations describe "${OP_PATH}" --format="value(done)" 2>/dev/null)

  if [[ "$IS_DONE" == "True" || "$IS_DONE" == "true" ]]; then
    echo -e "\nState capture complete and validated. SCC findings are fully populated in ${DATASET_NAME}.findings and ready for ingestion."
    break
  fi

  echo -n "."
  sleep 5
done

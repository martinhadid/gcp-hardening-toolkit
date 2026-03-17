# GCP Hardening Toolkit - State Exporter

This directory contains scripts to export the state of your GCP projects for security hardening analysis.

## Prerequisites

Ensure you have the `gcloud` CLI and `bq` command-line tools installed and configured.

## Scripts

- `export_cai_state.sh [PROJECT_ID]`: Initiates Cloud Asset Inventory (CAI) resources export to BigQuery. After execution, it will provide a `gcloud` command to check the operation's status. The BigQuery table will be populated upon completion.

- `cleanup.sh [PROJECT_ID]`: Deletes the BigQuery dataset created by the CAI export script.

## Usage

To run the scripts, navigate to this directory in your terminal and execute the desired script with the required parameters.

### `export_cai_state.sh`

Exports Cloud Asset Inventory resources.

```bash
./export_cai_state.sh YOUR_GCP_PROJECT_ID
```

Replace `YOUR_GCP_PROJECT_ID` with the ID of your GCP project.



### `cleanup.sh`

Deletes the BigQuery dataset and its contents created by the `export_cai_state.sh` script.

```bash
./cleanup.sh YOUR_GCP_PROJECT_ID
```

Replace `YOUR_GCP_PROJECT_ID` with the ID of the GCP project where the dataset was created.

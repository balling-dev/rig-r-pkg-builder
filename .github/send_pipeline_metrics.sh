#!/bin/bash

# Pipeline Metrics Logger for GitHub Actions
# Sends a counter metric when pipeline starts
#

set -euo pipefail

# Function to display usage
usage() {
        cat <<EOF
GitHub Pipeline Metrics Logger - sends telemetry data

This script requires ALL configuration to be provided via environment variables.
No defaults are provided for security reasons in public repositories.

REQUIRED ENVIRONMENT VARIABLES:
    TELEMETRY_AZURE_CLIENT_ID       Azure client ID
    TELEMETRY_AZURE_CLIENT_SECRET   Azure client secret
    TELEMETRY_AZURE_SCOPE           Azure OAuth scope
    TELEMETRY_AZURE_TENANT_ID       Azure tenant ID
    TELEMETRY_API_URL               API URL

OPTIONAL ENVIRONMENT VARIABLES:
    SERVICE_VERSION                 Service version (default: "1.0.0")

AUTOMATIC VARIABLES:
    TELEMETRY_ID                    Used as telemetry service name

EXAMPLES:
    export TELEMETRY_AZURE_CLIENT_ID="your-client-id"
    export TELEMETRY_AZURE_CLIENT_SECRET="your-secret"
    # ... set other required variables
    ./send_pipeline_metrics.sh

EOF
}

# Check for help flag
if [[ "${1:-}" == "-h" ]] || [[ "${1:-}" == "--help" ]]; then
        usage
        exit 0
fi

# Check if jq is installed
if ! command -v jq &>/dev/null; then
        echo "Error: jq is not installed. Please install jq to use this script." >&2
        exit 1
fi

# Validate required environment variables
required_vars=(
        "TELEMETRY_AZURE_CLIENT_ID"
        "TELEMETRY_AZURE_CLIENT_SECRET"
        "TELEMETRY_AZURE_SCOPE"
        "TELEMETRY_AZURE_TENANT_ID"
        "TELEMETRY_API_URL"
        "TELEMETRY_ID"
)

missing_vars=()
for var in "${required_vars[@]}"; do
        if [[ -z "${!var:-}" ]]; then
                missing_vars+=("$var")
        fi
done

if [[ ${#missing_vars[@]} -gt 0 ]]; then
        echo "Error: Missing required environment variables:" >&2
        printf "  %s\n" "${missing_vars[@]}" >&2
        echo "" >&2
        echo "Run '$0 --help' for usage information." >&2
        exit 1
fi

# Set optional variables with defaults
SERVICE_VERSION="${SERVICE_VERSION:-1.0.0}"

# Use GitHub repository name as telemetry ID
TELEMETRY_ID="$TELEMETRY_ID"

# Generate timestamp
timestamp=$(date +%s000000000)

# Create metrics payload using the telemetry_id
metric_json='{
    "resourceMetrics": [
        {
            "resource": {
                "attributes": [
                    {
                        "key": "service.name",
                        "value": {
                            "stringValue": "'"$TELEMETRY_ID"'"
                        }
                    },
                    {
                        "key": "service.version",
                        "value": {
                            "stringValue": "'"$SERVICE_VERSION"'"
                        }
                    }
                ]
            },
            "scopeMetrics": [
                {
                    "scope": {
                        "name": "'"$TELEMETRY_ID"'.metrics",
                        "version": "'"$SERVICE_VERSION"'"
                    },
                    "metrics": [
                        {
                            "name": "'"$TELEMETRY_ID"'",
                            "unit": "1",
                            "description": "Execution events for automation tools and processes",
                            "gauge": {
                                "dataPoints": [
                                    {
                                        "asInt": "1",
                                        "timeUnixNano": "'"$timestamp"'",
																				"attributes": [
					    															{
						    															"key": "type",
						    															"value": { "stringValue": "gh_docker"}
					    															},
					    															{
						    															"key": "name",
						    															"value": { "stringValue": "'"$GITHUB_REPOSITORY"'"}
					    															},
					    															{
						    															"key": "env",
						    															"value": { "stringValue": "prd"}
					    															},
					    															{
						    															"key": "display_name",
						    															"value": { "stringValue": "R rig docker"}
					    															}
				        												] 
                                    }
                                ]
                            }
                        }
                    ]
                }
            ]
        }
    ]
}'

# Request access token
access_token=$(curl --silent --request POST \
        --url "https://login.microsoftonline.com/$TELEMETRY_AZURE_TENANT_ID/oauth2/v2.0/token" \
        --header 'content-type: application/x-www-form-urlencoded' \
        --data grant_type=client_credentials \
        --data client_id="$TELEMETRY_AZURE_CLIENT_ID" \
        --data client_secret="$TELEMETRY_AZURE_CLIENT_SECRET" \
        --data scope="$TELEMETRY_AZURE_SCOPE" | jq -r '.access_token')

if [[ "$access_token" == "null" || -z "$access_token" ]]; then
        echo "Error: Failed to obtain access token" >&2
        exit 1
fi

# Send metric to Bifrost
response=$(curl --silent --write-out "%{http_code}" --output /dev/null \
        -X POST \
        "https://$TELEMETRY_API_URL/v1/metrics" \
        --header 'Content-Type: application/json' \
        --header "Authorization: Bearer $access_token" \
        --data-raw "$metric_json")

if [[ "$response" == "200" ]]; then
        echo "? Successfully logged pipeline start metric for repository: $TELEMETRY_ID"
else
        echo "? Failed to send metric. HTTP status: $response" >&2
        exit 1
fi

#!/usr/bin/env bash
set -eux

NAMESPACE="managed-release-team-tenant"
RESOURCES_PATH="regular"
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";

tempDir=$(mktemp -d /tmp/m6.XXX)
trap 'rm -rf "$tempDir"' EXIT

create_resources() {
  kubectl apply -k "$SCRIPT_DIR/$RESOURCES_PATH"
}

create_resources

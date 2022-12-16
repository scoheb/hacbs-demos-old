#!/usr/bin/env bash
set -eux

COSIGN_SECRET_NAME="cosign-public-key"
NAMESPACE="managed-release-team"
RESOURCES_PATH="admin"
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";

tempDir=$(mktemp -d /tmp/m6.XXX)
trap 'rm -rf "$tempDir"' EXIT

create_resources() {
  kubectl apply -k "$SCRIPT_DIR/$RESOURCES_PATH"
}

create_cosign_secret() {
  cosign public-key --key k8s://tekton-chains/signing-secrets > "$tempDir/cosign.pub"
  kubectl create secret generic $COSIGN_SECRET_NAME -n "$NAMESPACE" --from-file="$tempDir/cosign.pub"
}

create_resources
create_cosign_secret

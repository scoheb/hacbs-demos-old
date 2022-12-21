#!/usr/bin/env bash
set -eux

COSIGN_SECRET_NAME="cosign-public-key"
NAMESPACE="managed-release-team"
QUAY_ROBOT_ACCOUNT="hacbs-release-tests+m5_robot_account"
QUAY_SECRET_NAME="hacbs-release-tests-token"
RESOURCES_PATH="regular"
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";

tempDir=$(mktemp -d /tmp/m6.XXX)
trap 'rm -rf "$tempDir"' EXIT

create_resources() {
  kubectl apply -k "$SCRIPT_DIR/$RESOURCES_PATH"
}

create_quay_secret() {
  podman login --username "$QUAY_ROBOT_ACCOUNT" --authfile "$tempDir/config.json" quay.io

  kubectl create secret generic "$QUAY_SECRET_NAME" -n "$NAMESPACE" \
      --from-file=.dockerconfigjson="$tempDir/config.json" --type=kubernetes.io/dockerconfigjson
}

create_resources
create_quay_secret

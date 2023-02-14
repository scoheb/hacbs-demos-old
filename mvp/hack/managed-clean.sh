#!/usr/bin/env bash

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";

oc delete application/simple-python

sleep 2

oc delete pr --all
oc delete snapshots --all
oc delete aseb --all
oc delete environment --all

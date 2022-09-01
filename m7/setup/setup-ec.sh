DEVWORKSPACE=ralphjbean
MANAGEDWORKSPACE=managed-rbean

## get dockerconfig from quay
curl -s https://raw.githubusercontent.com/hacbs-contract/enterprise-contract-controller/main/config/rbac/enterprisecontractpolicy_viewer_role.yaml | oc apply -f -
oc policy add-role-to-user enterprisecontractpolicy-viewer-role -z pipeline
oc policy add-role-to-user enterprisecontractpolicy-viewer-role -z m7-service-account -n $MANAGEDWORKSPACE
oc -n $DEVWORKSPACE secrets link pipeline redhat-appstudio-registry-pull-secret --for=pull,mount

curl -s https://raw.githubusercontent.com/hacbs-contract/enterprise-contract-controller/main/config/rbac/enterprisecontractpolicy_viewer_role.yaml | oc apply -f -
oc policy add-role-to-user enterprisecontractpolicy-viewer-role -z pipeline
oc policy add-role-to-user enterprisecontractpolicy-viewer-role -z m6-service-account -n managed-shebert
oc -n shebert secrets link pipeline redhat-appstudio-registry-pull-secret --for=pull,mount

# Setup

Create DEVWORKSPACE and MANAGEDWORKSPACE namespaces

We'll use

- DEVWORKSPACE = dev-release-team-tenant
- MANAGEDWORKSPACE = managed-release-team-tenant

Ensure both have the label:

```
oc label namespaces dev-release-team-tenant argocd.argoproj.io/managed-by=gitops-service-argocd
oc label namespaces managed-release-team-tenant argocd.argoproj.io/managed-by=gitops-service-argocd
```

Download scripts from the release-utils repo

```
curl https://raw.githubusercontent.com/hacbs-release/release-utils/main/copy-application.sh -o copy-application.sh
curl https://raw.githubusercontent.com/hacbs-release/release-utils/main/setup-quay-push-secret.sh -o setup-quay-push-secret.sh
```

Should you need to use different values follow these steps:

- Update values for *namespace* and *target* to correspond to the values of DEVWORKSPACE and MANAGEDWORKSPACE in:
  - dev/*
- Update values for *namespace* and *target* to correspond to the values of DEVWORKSPACE and MANAGEDWORKSPACE in:
  - release/*
- Update variables in:
  - release/managed-workspace/regular/bootstrap.sh
  - release/managed-workspace/admin/admin-bootstrap.sh

---

**NOTE: Since each workspace is associated to only one user, _you will have to switch back and forth using login
commands to access each namespace properly_.**

---

Download your docker config json file from Quay and place it in $HOME/docker.config

| **Login as the Dev User (use [registration service](https://registration-service-toolchain-host-operator.apps.stone-stg-host1.hjvn.p1.openshiftapps.com/) when accessing **Staging** cluster)**

Create secret in DEVWORKSPACE

```
oc create secret docker-registry redhat-appstudio-registry-pull-secret -n dev-release-team-tenant \
   --from-file=.dockerconfigjson=$HOME/docker.config
```

Create release plan

`oc apply -f release/dev-workspace/release_plan.yaml -n dev-release-team-tenant`

| **Login as a Cluster Admin User using Openshift Console**

Get the **cosign public key**

`cosign public-key --key k8s://tekton-chains/signing-secrets`
 
Update the Enterprise Contract Policy to include **cosign public key**

`vi release/managed-workspace/regular/ec-policy.yaml`

Note: this resource will get applied at a later stage.

| **Login as the Managed Workspace User (use [registration service](https://registration-service-toolchain-host-operator.apps.stone-stg-host1.hjvn.p1.openshiftapps.com/) when accessing **Staging** cluster)**

`sh release/managed-workspace/bootstrap.sh`

| **Login as a Cluster Admin User using Openshift Console**

`sh release/managed-workspace/admin-bootstrap.sh`

Link service accounts to secrets in DEVWORKSPACE

`oc secrets link appstudio-pipeline redhat-appstudio-registry-pull-secret --for=pull,mount -n dev-release-team-tenant`

| **Login as the Managed Workspace User (use [registration service](https://registration-service-toolchain-host-operator.apps.stone-stg-host1.hjvn.p1.openshiftapps.com/) when accessing **Staging** cluster)**


Create secret that will be used by the Release Service pipeline account in MANAGEDWORKSPACE to push content to quay

```
sh ./setup-quay-push-secret.sh
```

Create secret that will be used by Release pipeline to upload content to Pyxis

To create the secret required by Pyxis, you need to create 2 files: cert and key

To create cert:
* Goto https://vault.devshift.net/ui/vault/secrets/hacbs/show/hacbs-internal-services/pyxis/staging/pyxis-certificates
* Take content from hacbs-release-pyxis-staging.crt
* echo $CONTENT | base64 -d > cert

To create key:
* Goto https://vault.devshift.net/ui/vault/secrets/hacbs/show/hacbs-internal-services/pyxis/staging/pyxis-certificates
* take content from hacbs-release-pyxis-staging.key
* echo $CONTENT | base64 -d > key

then run:

```
oc create secret generic pyxis --from-file cert --from-file key -n managed-release-team-tenant
```

| **Login as the Dev User (use [registration service](https://registration-service-toolchain-host-operator.apps.stone-stg-host1.hjvn.p1.openshiftapps.com/) when accessing **Staging** cluster)**

Create applications and components

```
oc apply -f appstudio-application.yaml -n dev-release-team-tenant
oc apply -f simple-python-application.yaml -n dev-release-team-tenant
```

```
oc apply -f components/dcmetromap.yaml -n dev-release-team-tenant
oc apply -f components/devfile-sample-python-basic.yaml -n dev-release-team-tenant
```

Verify that builds have started in DEVWORKSPACE

`oc get pr`

Now we can set up the Application and Component for the **Deployment** scenario. This involves creating a copy of the 
application and component in the MANAGEDWORKSPACE.

| **Login as a Cluster Admin User using Openshift Console**

Clone the release-utils repo

```
sh ./copy-application.sh managed-release-team-tenant -a dev-release-team-tenant/simple-python
```

| **Login as the Dev User (use [registration service](https://registration-service-toolchain-host-operator.apps.stone-stg-host1.hjvn.p1.openshiftapps.com/) when accessing **Staging** cluster)**

Once builds complete, The Integration Service will create Snapshots in DEVWORKSPACE.

`oc get snapshot`

The Interation Service will create **Releases** and release pipelines will execute in MANAGEDWORKSPACE

| **Login as the Managed Workspace User (use [registration service](https://registration-service-toolchain-host-operator.apps.stone-stg-host1.hjvn.p1.openshiftapps.com/) with accessing **Staging** cluster)**

`oc get pr`

Verify that the Release pipelines complete successfully.

| **Login as the Dev User (use [registration service](https://registration-service-toolchain-host-operator.apps.stone-stg-host1.hjvn.p1.openshiftapps.com/) when accessing **Staging** cluster)**

For the Deployment scenario, consult the Deployment health via:

`oc get release`

Locate the simple-python **Release**

`oc get release/simple-python-tb5tc-gqgz2 -o json | jq .status.conditions`

You should see a **Condition** stating **AllComponentsDeployed**

```
- lastTransitionTime: '2023-01-18T21:00:02Z'
  message: 1 of 1 components deployed
  reason: CommitsSynced
  status: 'True'
  type: AllComponentsDeployed
```

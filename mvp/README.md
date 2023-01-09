# Setup

Create DEVWORKSPACE and MANAGEDWORKSPACE namespaces

We'll use

- DEVWORKSPACE = dev-release-team
- MANAGEDWORKSPACE = managed-release-team

Should you need to use different values follow these steps:

- Update values for *namespace* and *target* to correspond to the values of DEVWORKSPACE and MANAGEDWORKSPACE in:
  - dev/*
- Update values for *namespace* and *target* to correspond to the values of DEVWORKSPACE and MANAGEDWORKSPACE in:
  - release/*
- Update variables in:
  - release/managed-workspace/regular/bootstrap.sh
  - release/managed-workspace/admin/admin-bootstrap.sh

NOTE: Since each workspace is associated to only one user, you will have to switch back and forth using login
commands to access each namespace properly.

Download your docker config json file from Quay and place it in $HOME/docker.config

Login as the Dev User (use [registration service](https://registration-service-toolchain-host-operator.apps.appstudio-stage.x99m.p1.openshiftapps.com) when accessing **Staging** cluster)

Create secret in DEVWORKSPACE

> kubectl create secret docker-registry redhat-appstudio-registry-pull-secret -n dev-release-team --from-file=.dockerconfigjson=$HOME/docker.config

Apply default build bundle

> oc apply -f setup/default-build-bundle.yaml -n dev-release-team

Create release plan

> oc apply -f release/dev-workspace/release_plan.yaml -n dev-release-team

Login as a Cluster Admin User using Openshift Console

Get the **cosign public key**

> cosign public-key --key k8s://tekton-chains/signing-secrets
 
Update the Enterprise Contract Policy to include **cosign public key**

> vi release/managed-workspace/regular/ec-policy.yaml

Note: this resource will get applied at a later stage.

Login as the Managed Workspace User (use [registration service](https://registration-service-toolchain-host-operator.apps.appstudio-stage.x99m.p1.openshiftapps.com) when accessing **Staging** cluster)

> sh release/managed-workspace/bootstrap.sh

Login as a Cluster Admin User using Openshift Console

> sh release/managed-workspace/admin-bootstrap.sh

Link service accounts to secrets in DEVWORKSPACE

> oc secrets link pipeline redhat-appstudio-registry-pull-secret --for=pull,mount -n dev-release-team

Create image pull secret that will be used by the Release Service pipeline account in MANAGEDWORKSPACE

- Login to quay and navigate the robot account that has push permissions
- From settings, click **View Credentials**
- Download the **Kubernetes Secret** as a file
- Run oc apply as follows:

> oc apply -f ~/Downloads/hacbs-release-tests-m5-robot-account-secret.yml -n managed-release-team

Link this new secret to the Release Service pipeline account in MANAGEDWORKSPACE

> oc secrets link release-service-account hacbs-release-tests-m5-robot-account-pull-secret --for=mount -n managed-release-team

Login as the Dev User (use [registration service](https://registration-service-toolchain-host-operator.apps.appstudio-stage.x99m.p1.openshiftapps.com) when accessing **Staging** cluster)

Create application and component

> oc apply -f appstudio-application.yaml

> oc apply -f components/dcmetromap.yaml

Verify that build has started in DEVWORKSPACE

> oc get pr

Once build completes, The Integration Service will create a Snapshot in DEVWORKSPACE.
Since the Build was manually created as opposed to originating from a push event, we need to 
update the Snapshot to include the label:

> oc get snapshot

Record the name of the latest snapshot -> {snapshot name} 

> oc edit snapshot/{snapshot name}

Add label *pac.test.appstudio.openshift.io/event-type: push*

Once the Interation Service reconciles the newly updated Snapshot, a Release will get created 
and a release pipeline will execute in MANAGEDWORKSPACE

Login as the Managed Workspace User (use [registration service](https://registration-service-toolchain-host-operator.apps.appstudio-stage.x99m.p1.openshiftapps.com) with accessing **Staging** cluster)

> oc get pr

Verify that the Release pipeline complete successfully.
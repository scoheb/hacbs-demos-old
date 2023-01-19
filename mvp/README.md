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

`kubectl create secret docker-registry redhat-appstudio-registry-pull-secret -n dev-release-team --from-file=.dockerconfigjson=$HOME/docker.config`

Create release plan

`oc apply -f release/dev-workspace/release_plan.yaml -n dev-release-team`

Login as a Cluster Admin User using Openshift Console

Get the **cosign public key**

`cosign public-key --key k8s://tekton-chains/signing-secrets`
 
Update the Enterprise Contract Policy to include **cosign public key**

`vi release/managed-workspace/regular/ec-policy.yaml`

Note: this resource will get applied at a later stage.

Login as the Managed Workspace User (use [registration service](https://registration-service-toolchain-host-operator.apps.appstudio-stage.x99m.p1.openshiftapps.com) when accessing **Staging** cluster)

`sh release/managed-workspace/bootstrap.sh`

Login as a Cluster Admin User using Openshift Console

`sh release/managed-workspace/admin-bootstrap.sh`

Link service accounts to secrets in DEVWORKSPACE

`oc secrets link pipeline redhat-appstudio-registry-pull-secret --for=pull,mount -n dev-release-team`

Create image pull secret that will be used by the Release Service pipeline account in MANAGEDWORKSPACE

- Login to quay and navigate the robot account that has push permissions
- From settings, click **View Credentials**
- Download the **Kubernetes Secret** as a file
- Run oc apply as follows:

`oc apply -f ~/Downloads/hacbs-release-tests-m5-robot-account-secret.yml -n managed-release-team`

Link this new secret to the Release Service pipeline account in MANAGEDWORKSPACE

`oc secrets link release-service-account hacbs-release-tests-m5-robot-account-pull-secret --for=mount -n managed-release-team`

Login as the Dev User (use [registration service](https://registration-service-toolchain-host-operator.apps.appstudio-stage.x99m.p1.openshiftapps.com) when accessing **Staging** cluster)

Create applications and components

```
oc apply -f appstudio-application.yaml
oc apply -f simple-python-application.yaml
```

```
oc apply -f components/dcmetromap.yaml
oc apply -f components/devfile-sample-python-basic.yaml
```

Verify that builds have started in DEVWORKSPACE

`oc get pr`

Now we can set up the Application and Component for the **Deployment** scenario. This involves creating a copy of the 
application and component in the MANAGEDWORKSPACE.

Login as a Cluster Admin User using Openshift Console

Clone the release-utils repo

```
git clone https://github.com/hacbs-release/release-utils.git
cd release-utils
./copy-application.sh managed-release-team -a dev-release-team/simple-python
```

Login as the Dev User (use [registration service](https://registration-service-toolchain-host-operator.apps.appstudio-stage.x99m.p1.openshiftapps.com) when accessing **Staging** cluster)

Once builds complete, The Integration Service will create Snapshots in DEVWORKSPACE.

> oc get snapshot

The Interation Service will create **Releases** and release pipelines will execute in MANAGEDWORKSPACE

Login as the Managed Workspace User (use [registration service](https://registration-service-toolchain-host-operator.apps.appstudio-stage.x99m.p1.openshiftapps.com) with accessing **Staging** cluster)

> oc get pr

Verify that the Release pipelines complete successfully.

Login as the Dev User (use [registration service](https://registration-service-toolchain-host-operator.apps.appstudio-stage.x99m.p1.openshiftapps.com) when accessing **Staging** cluster)

For the Deployment scenario, consult the Deployment health via:

> oc get release

Locate the simple-python **Release**

> oc get release/simple-python-tb5tc-gqgz2 -o json | jq .status.conditions

You should see a **Condition** stating **AllComponentsDeployed**

```
- lastTransitionTime: '2023-01-18T21:00:02Z'
  message: 1 of 1 components deployed
  reason: CommitsSynced
  status: 'True'
  type: AllComponentsDeployed
```
# Setup

create DEVWORKSPACE and MANAGEDWORKSPACE namespaces

Since each workspace is associated to only one user, you will have to switch back and forth using login
commands to access each namespace properly.

download your docker config json file from Quay and place it in \<HOME\>/docker.config

Login as the Dev User

create secret in DEVWORKSPACE

> \# kubectl create secret docker-registry redhat-appstudio-registry-pull-secret -n <DEVWORKSPACE> --from-file=.dockerconfigjson=<HOME>/docker.config

apply default build bundle

> \# oc apply -f setup/default-build-bundle.yaml -n \<DEVWORKSPACE\>

update values for *namespace* and *target* to correspond to the values of DEVWORKSPACE and MANAGEDWORKSPACE in:

* dev/*

Create release plan

> \# oc apply -f dev/release_plan.yaml -n \<DEVWORKSPACE\>

Update values for *namespace* and *target* to correspond to the values of DEVWORKSPACE and MANAGEDWORKSPACE in:

* release/base/*
* release/admin/*

Update variables in: 

* release/bootstrap.sh
* release/admin-bootstrap.sh

Login as the Managed Workspace User

> \# sh release/bootstrap.sh

Login as a Cluster Admin User

> \# sh release/admin-bootstrap.sh

Login as the Dev User

create application and component

> \# oc apply -f appstudio-application.yaml

> \# oc apply -f components/dcmetromap.yaml

verify that build has started in DEVWORKSPACE

> \# oc get pr

Once build completes, The Integration Service will create a Snapshot in DEVWORKSPACE.
Since the Build was manually created as opposed to originating from a push event, we need to 
update the Snapshot to include the label:

> \# oc get snapshot

Record the name of the latest snapshot -> {snapshot name} 

> \# oc edit snapshot/{snapshot name}

Add label *pac.test.appstudio.openshift.io/event-type: push*

Once build completes, update Snapshot as described above.

Once the Interation Service reconciles the newly updated Snapshot, a Release will get created 
and a pipeline will execute in MANAGEDWORKSPACE

Login as the Managed Workspace User

> \# oc get pr


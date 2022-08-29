# Setup

create DEVWORKSPACE and MANAGEDWORKSPACE

download your docker config json file from Quay and place it in \<HOME\>/docker.config

create secret in DEVWORKSPACE

> \# kubectl create secret docker-registry  redhat-appstudio-registry-pull-secret -n <DEVWORKSPACE> --from-file=.dockerconfigjson=<HO
OME>/docker.config

apply default build bundle

> \# oc apply -f setup/default-build-bundle.yaml -n <DEVWORKSPACE>

update values for *namspace* and *target* to correspond to the values of DEVWORKSPACE and MANAGEDWORKSPACE in:

* release/base/*

update variables in: 

* release/bootstrap.sh

> \# sh release/bootstrap.sh

update DEVWORKSPACE and MANAGEDWORKSPACE in setup/setup-ec.sh

> \# sh setup/setup-ec.sh

create application and component

> \# oc apply -f appstudio-application.yaml

> \# oc apply -f components/java-springboot.yaml

verify that build has started in DEVWORKSPACE

once build complete, release should executed in MANAGEDWORKSPACE


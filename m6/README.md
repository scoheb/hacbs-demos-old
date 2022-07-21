# Setup

update DEVWORKSPACE and MANAGEDWORKSPACE in setup/setup-ec.sh

> \# sh setup/setup-ec.sh

> \# oc apply -f setup/default-build-bundle.yaml -n <DEVWORKSPACE>

update values for *namspace* and *target* in release/base/* to correspond to the values of DEVWORKSPACE and MANAGEDWORKSPACE

* release/base/persistent_volume_claim.yaml

update variables in release/bootstrap.sh

* release/bootstrap.sh

> \# sh release/bootstrap.sh

create application and component

> \# oc apply -f appstudio-application.yaml

> \# oc apply -f components/java-springboot.yaml

verify that build has started in DEVWORKSPACE

once build complete, release should executed in MANAGEDWORKSPACE




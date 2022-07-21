oc delete pod --field-selector=status.phase==Succeeded -n shebert
oc delete dependencybuild --all
oc delete artifactbuild --all
oc delete release --all
oc delete applicationsnapshots --all

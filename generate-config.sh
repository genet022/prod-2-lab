#!/bin/bash
# $1 fcelab dir
# $2 production dir
# $3 outdir

set -e
# copy content of $2/ into existing $3 without top level dirname
cp -r $2/* $3/
mkdir -p $3/generated/maas

# copy fcelab specific files
COPY_FROM_LAB="bucketsconfig.yaml hosts.yaml nodes.yaml"
for i in $COPY_FROM_LAB ; do
    cp $1/config/$i $3/config/
done

# change mtu 9000 to 1500
sed -i "s/9000/1500/" $3/config/networks.yaml

./modify_master.py $2/config/master.yaml $3/config/master.yaml

if [ $# -eq 4 ]  && [ $4 == 'k8s' ]
then
    ./modify_bundle.py $2/config/kubernetes_bundle.yaml $3/config/kubernetes_bundle.yaml k8s
else
    ./modify_bundle.py $2/config/bundle.yaml $3/config/bundle.yaml
fi

# modify rally files
sed  -i "s/times:.*$/times: 1/" $3/config/rally/*
sed  -i "s/concurrency:.*$/concurrency: 1/" $3/config/rally/*
sed  -i "s/users_per_tenant:.*$/users_per_tenant: 1/" $3/config/rally/*
sed  -i "s/tenants:.*$/tenants: 1/" $3/config/rally/*

set +e

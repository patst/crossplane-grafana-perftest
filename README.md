# Crossplane Grafana Provider Performance test

We have Kubernetes cluster with several hundred CRs of the [Crossplane Grafana Provider](https://github.com/grafana/crossplane-provider-grafana).

We observed a lot of performance issues while synchronizing dashboards, folders and other resources.

I was thrilled to read about some fixes in the [Upjet Framework](https://github.com/crossplane/upjet) which should boost the performance by a large factor. (see [#259](https://github.com/crossplane/upjet/pull/259))

This repository was created to establish a baseline before upgrading the Crossplane Grafana Provider - which is based on Upjet - to see if it really establishes the promised performance gain.

The tests are run on my M2 Macbook Pro with a local Kubernetes cluster and a local Grafana installation with a local Postgres database.

The provider was limited to 4 CPUs and 2 Gigabytes of RAM which is in my opinion more than enough for something doing a few API calls to create folders in Grafana.

## Setup

You need to run a (local) kubernetes cluster and have the kubecontext set to reach the cluster.

Then:

*Create the Grafana Postgres database with `./scripts/create_grafana_db.sh`
* run `kubectl apply -f deploy/0_grafana.yaml`
* run `kubectl apply -f deploy/1_provider.yaml`
* run `kubectl apply -f deploy/2_provider_config.yaml`
* check if everything is started (`kubectl get pods -A`)
* run the test with `time CR_INSTANCE_COUNT=100 ./scripts/create.sh`

The script will run until all folder managed resources are synced and healthy and output the time it takes to do so.

With `time CR_INSTANCE_COUNT=100 ./scripts/destroy.sh` you can delete all the resources and measure the time how long it does take


Tests results: 

Version *0.7.0* (based on Upjet version 0.8.0):

| # Folders | Time for creation | Time for destroy |
|:---------:|:-----------------:|:----------------:|
|    100    |     1:53 min      |     1:21 min     |
|   1000    |     19:32 min     |      25 min      |

Next Version  based on Upjet version 0.10.0: (see Pull Request at https://github.com/grafana/crossplane-provider-grafana/pull/49 )

| # Folders | Time for creation | Time for destroy |
|:---------:|:-----------------:|:----------------:|
|    100    |      50 sec       |      40 sec      |
|   1000    |     7:45  min     |     8:36 min     |

What is interesting is, that the folders are visible very early in Grafana, but are not yet marked as ready and healthy in the crossplane CRDs, because another reconcile loop is required to check the status (`Observe`).


One remark: Sometimes the tests do not finish successfully because single resources are stuck in creating state. This is due some annotations which are not set correctly in Crossplane, see https://github.com/crossplane/crossplane/issues/3037

Second remark: I don't know if the measurements are really comparable, because I ran them locally, but nevertheless they are a good indicator.

Links:

* [Crossplane](https://www.crossplane.io/)
* [Crossplane Grafana Provider](https://github.com/grafana/crossplane-provider-grafana)
* [Upjet Framework](https://github.com/crossplane/upjet)
* [Uptest](https://github.com/upbound/uptest) for advanced testing

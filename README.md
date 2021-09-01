# Terraform AKS Azure Kubernetes Service Infrastructure Setup

## Overview

This repository contains terraform configuration to set up a AKS Cluster. The cluster will be bootstrapped from zero and the most important infrastructure is deployed.

- Traefik Ingress with DNS-01 Wildcard support
- Instana APM
- Cluster Autoscaler
- Overprovisioner
- Kured
- Node-Problem-Detector

From there on you can work with the cluster using helm directly. If you want to extend the repo from here to deploy your workload from terraform.

## Why Overprovisioning?

The Cluster Autoscaler is deployed and [configured](cluster-autoscaler-values.tpl) to adjust the sizing of the cluster automatically. The events this version of the autoscaler handles are limited to the one that are fired if a Pod can not be scheduled because the capacity of the cluster is exceeded. Most of the time the cluster operator doesn't want to wait till it's to late to scale up. Scaling up takes time to boot up the VM and add the new node to the cluster.
The overprovisioner creates a workload in the [defined size](overprovisioner-values.yaml) to trigger a scale up if this workload can not be handled by the cluster. So in this case the autoscaler trigger if roughly less than 8GB or 2 cores are available.
This system is fairly flexible and in conjuction with the [cluster autoscaler](cluster-autoscaler-values.tpl) that will try to scale down the cluster if the capacity is no longer needed the cluster can dynamically handle variable load.

## Instructions

1) Make sure you have the azurecli installed and configured to your account. Set the default subscription to the helix internal one.
    To verify that you're logged in and have selected the correct subscription execute `az account list --refresh --output table`.
    In addition, you need to have certain rights in order to create the service principal. If you get
    an error like this:
      
    ```
    Error: graphrbac.ApplicationsClient#Create: Failure responding to request: StatusCode=403 -- Original Error: autorest/azure: Service returned an error. Status=403 Code="Unknown" Message="Unknown service error" Details=[{"odata.error":{"code":"Authorization_RequestDenied","date":"...","message":{"lang":"en","value":"Insufficient privileges to complete the operation."},"requestId":"..."}}]
   ```
   
   you are lacking these rights. Ask someone to grant them to you (Global Administrator works, but might be overkill).

2) `terraform init`

    This will initialize terraform in a local state and install all required plugins. If you want to persist your state
    remotely, copy ./remote-state/backend.tpl to ./backend.tf and run `terraform init` again. You will be asked to provide
    a blob key at which the terraform state will be stored. ***Be careful to not overwrite existing configurations!***

3) `terraform plan` will show you the operations that will be performed taking the current state into account.

4) To roll out the current changes you run `terraform apply`. This will show you the changes and allows you to review those. Once you are satisfied feel free to proceed.

5) Use the cluster:

    `az aks get-credentials --resource-group $(terraform output resource_group) --name $(terraform output cluster_name)`

    or 

    ```
    echo "$(terraform output kube_config)" > ./azurek8s
    export KUBECONFIG=./azurek8s
    kubectl -n kube-system get po
    ```

5) `terraform destroy`
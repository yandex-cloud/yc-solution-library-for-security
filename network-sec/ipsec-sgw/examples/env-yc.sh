#!/bin/bash

export TF_VAR_cloud_id=$(yc config get cloud-id)
export TF_VAR_folder_id=$(yc config get folder-id)
export YC_TOKEN=$(yc iam create-token)

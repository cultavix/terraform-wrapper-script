#!/bin/bash
# Author: James Gonzalez - This is a wrapper for Terraform

show_help() {
  cat >/dev/stdout <<END
$0 -b <bucket_name> -r <primary_region> -k <tf_state_s3_path> -R <region_of_infra> [ -d true # to destroy | -i true # to init only]
  Example:
  $0 -b my-cool-bucket -r eu-west-1 -k eu-west-1/dev/sevice/terraform.tfstate -R eu-west-2
  $0 -b my-cool-bucket -r eu-west-1 -k eu-west-1/dev/sevice/terraform.tfstate -R eu-west-2 -d true # DESTROY
  $0 -b my-cool-bucket -r eu-west-1 -k eu-west-1/dev/sevice/terraform.tfstate -R eu-west-2 -i true # INIT ONLY (debugging, allows you to run your normal terraform commands afterwards on local machines)
END
exit 0
}

## Defaults
BUCKET_KEY="terraform.tfstate" ## Example of how you can have a structure to your tfstate files
STATE_BUCKET_NAME="my-tfstate-bucket"
STATE_BUCKET_REGION="us-east-2"
REGION="us-east-2"

while getopts ":hb:k:d:i:r:R:" opt; do
  case ${opt} in
    b) STATE_BUCKET_NAME=${OPTARG} ;;
    k) BUCKET_KEY=${OPTARG} ;;
    r) STATE_BUCKET_REGION=${OPTARG} ;;
    R) REGION=${OPTARG} ;;
    i) INIT_ONLY=${OPTARG} ;;
    d) DESTROY=${OPTARG} ;;
    h | \? ) show_help
      ;;
  esac
done

init() {
  echo "---- Launching Terraform init ---"
  terraform init -backend-config="key=${BUCKET_KEY}" \
    -backend-config="bucket=${STATE_BUCKET_NAME}" \
    -backend-config="region=${STATE_BUCKET_REGION}" \
    -backend=true -force-copy -get=true -input=false -reconfigure
}

plan() {
  set -e
  echo "---- Launching Terraform plan ---"
  terraform plan -refresh=true -lock=true \
    -var "region=${REGION}" \
    -out terraform.plan
}

apply() {
  set -e
  echo "---- Launching Terraform apply ---"
  terraform apply -lock=true terraform.plan
}


destroy() {
  set -e
  echo "---- Launching Terraform apply ---"
  terraform apply -lock=true terraform.plan
}

if [[ ${INIT_ONLY} == "true" ]]; then
  echo " ## ONLY RUNNING TF INIT FOR LOCAL DEBUGGING ##"
  init
elif [[ ${DESTROY} == "true" ]]; then
  echo "RUNNING DESTROY!!!!!!!!! You have 10 seconds..."
  sleep 10
else
  init
  plan
  # apply
fi


exit 0

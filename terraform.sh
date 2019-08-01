#!/bin/bash

set -e

show_help() {
  cat >/dev/stdout <<END
$0 -b <bucket_name> -r <primary_region> -k <tf_state_s3_path> -R <region_of_infra> -I <extra_init_options> -P <extra_plan_options> [ -d true # to destroy | -i true # to init only | -D true # for debugging mode]
  Example:
  $0 -b my-cool-bucket -r eu-west-1 -k eu-west-1/dev/sevice/terraform.tfstate -I "-plugin-dir=/providers" -I no-color -P "-var-file=dev-env.tfvars"
  $0 -b my-cool-bucket -r eu-west-1 -k eu-west-1/dev/sevice/terraform.tfstate -d true # DESTROY
  $0 -b my-cool-bucket -r eu-west-1 -k eu-west-1/dev/sevice/terraform.tfstate -i true # INIT ONLY (debugging, allows you to run your normal terraform commands afterwards on local machines)
END
  exit 0
}

## Defaults
BUCKET_KEY="" ## Example of how you can have a structure to your tfstate files
STATE_BUCKET_NAME=""
STATE_BUCKET_REGION="us-east-2"
TF_IN_AUTOMATION="1"

export TF_IN_AUTOMATION

while getopts ":hb:k:d:i:r:I:P:D:" opt; do
  case ${opt} in
    b) STATE_BUCKET_NAME=${OPTARG} ;;
    k) BUCKET_KEY=${OPTARG} ;;
    r) STATE_BUCKET_REGION=${OPTARG} ;;
    i) INIT_ONLY=${OPTARG} ;;
    d) DESTROY=${OPTARG} ;;
    D) DEBUGGING=${OPTARG} ;;
    I) EXTRA_INIT+=("$OPTARG") ;;
    P) EXTRA_PLAN+=("$OPTARG") ;;
    h | \?)
      show_help
      ;;
  esac
done
shift $((OPTIND - 1))

init() {
  echo "---- Launching Terraform init ---"
  terraform init -backend-config="key=${BUCKET_KEY}" \
    -backend-config="bucket=${STATE_BUCKET_NAME}" \
    -backend-config="region=${STATE_BUCKET_REGION}" \
    -backend=true -force-copy -get=true -input=false -reconfigure "${EXTRA_INIT[@]}"
}

plan() {
  set -e
  echo "---- Launching Terraform plan ---"
  terraform plan -refresh=true -lock=true -no-color \
    -out terraform.plan "${EXTRA_PLAN[@]}"
}

apply() {
  set -e
  echo "---- Launching Terraform apply ---"
  terraform apply -no-color -lock=true terraform.plan
}

destroy() {
  set -e
  echo "---- Launching Terraform destroy ---"
  terraform destroy -no-color -lock=true terraform.plan
}

if [[ ${DEBUGGING} == "true" ]]; then
  export TF_LOG="DEBUG"
  echo "Terraform options: Running with TF_LOG set to: ${TF_LOG}"
fi

echo "Terraform options: Running with TF_IN_AUTOMATION set to : ${TF_IN_AUTOMATION}"

if [[ ${INIT_ONLY} == "true" ]]; then
  echo " ## ONLY RUNNING TF INIT FOR LOCAL DEBUGGING ##"
  init
elif [[ ${DESTROY} == "true" ]]; then
  echo "RUNNING DESTROY!!!!!!!!! You have 10 seconds..."
  sleep 10
else
  init
  plan
  apply
fi

exit 0

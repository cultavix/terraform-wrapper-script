# terraform-wrapper-script
Bash wrapper script to allow you to run a remote state without hard-coding it

## Features
Allows you to specify the following parameters to Terraform for execution
  - Bucket Name (for tfstate file) ## Default set in the script
  - Key (path for tfstatefile on the bucket) ## Default set in the script
  - Bucket Region (where you want your bucket to live)
  - Infra region (where you want your terraform code to execute from/on to, say you want to keep your state in eu-west-1 and create another bucket/or an instance/whatever, on another region
  - Init only option - To allow you to basically run `terraform init` but with either your default or your parameter based options
  - Destroy (to destroy, once again just with default options or by specifying them

## Why
I've worked for many companies and it's almost always the case, that I'll see:
```hcl
terraform {
  backend "s3" {
    bucket         = "example-bucket-terraform-state"
    key            = "terraform.tfstate"
    region         = "us-east-2"
    encrypt        = "true"
    dynamodb_table = "terraform-lock"
  }
}
```

This will allow you to simply have:
```hcl
terraform {
  backend "s3" {
  }
}
```

## How to use
As explained above, your Terraform code-base, make sure you have either in your `main.tf` or `state.tf` or wherever you'd like, the following:
```hcl
terraform {
  backend "s3" {
  }
}
```

```
./terraform.sh -b <bucket_name> -r <primary_region> -k <tf_state_s3_path> -R <region_of_infra> [ -d true # to destroy | -i true # to init only]
  Example:
  ./terraform.sh -b my-cool-bucket -r eu-west-1 -k eu-west-1/dev/sevice/terraform.tfstate -R eu-west-2
  ./terraform.sh -b my-cool-bucket -r eu-west-1 -k eu-west-1/dev/sevice/terraform.tfstate -R eu-west-2 -d true # DESTROY
  ./terraform.sh -b my-cool-bucket -r eu-west-1 -k eu-west-1/dev/sevice/terraform.tfstate -R eu-west-2 -i true # INIT ONLY (debugging, allows you to run your normal terraform commands afterwards on local machines)
 ```
 
## Coming soon
* Testing
* Automated versioning
* Docker version (Docker Hub)

## Contributing
Please, all feed-back and potential tweaks are welcome! Please see this [great article](https://akrabat.com/the-beginners-guide-to-contributing-to-a-github-project/) on how to contribute if you haven't done so before.

### Authors
[James Gonzalez](https://github.com/cultavix)
  

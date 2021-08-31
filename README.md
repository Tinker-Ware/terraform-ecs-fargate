# ECS Fargate Cluster + associated resources
This repo allows you to create an ECS cluster with 3 apps deployed with Fargate launch mode, and assumes App 3 will access your MySQL RDS instance. The DB doesn't have public access, so you need an EC2 instance to act as a gateway for that.

# Requirements
- Terraform v0.15.5+
    - AWS provider plugin v3.37.0+
- Open `variable_values.tfvars` and update accordingly
- Check you have **at least** the `default` aws profile configured in `$HOME/.aws/credentials`
- Update S3 backend accordingly in `main.tf`


## How to deploy
- `terraform init`   
- `terraform apply`

## Access DB externally
Once the deploy has finished, go check the [EC2 instances running](https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Instances:instanceState=running) and get the SSH command to connecto to "Bastion DB", _keep in mind you may need to change region_.   
Something like this:
```sh
ssh -i "your_ssh_key" ec2-user@ec2-XXX-XXX-XXX-XXX.compute-1.amazonaws.com
```

Then inside the EC2 instance you will connect to the DB with a command like this:
```sh
mysql -u XXX -h hv-stage-db.cviobqjmbuxe.us-east-1.rds.amazonaws.com --port XXXX -p
```

## Deploy Notes
- ensure webservice is exposing and listening in por 80
- apply terraform
- build/deploy webservice
- in the aws console in the section:
 `api gateway > hv-vpc-api > authorizers > hv-api-authorizer`
  click edit and save, this adds the trigger to the lambda authorizer
- deploy `stage` in api gateway
- update endpoints on fronoffice and backoffice
  - if you didn't update endpoint on frontoffice endpoint, deploy public webservice
- deploy clinical history backend pointing to new private service discovery url ej. http://stage-api...
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

## Notes
theres a bug with the api gateway authorizer where the lambda doesn't get its trigger added after the deployment.
to fix it you need to go to the api gateway in the AWS console, in the authorizers section, click edit and then save in the authorizer, that should be enough to fix it.

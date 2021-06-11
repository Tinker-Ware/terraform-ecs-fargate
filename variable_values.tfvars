aws_profile             = "default"
cluster_name            = "tw-fargate-ecs"
db_snapshot_identifier  = "db-snapshot-id"
db_version              = "x.x.x"
db_user                 = "xxx"
db_password             = "xxx"
db_port                 = 3306

aws_ami_id  = "ami-xxxxxxxxxxxxxxxxxx" # You could select an instance with MySQL already installed
key_pair    = "keys-name"

domain                = "google.com"
service_name_1        = "service-1"
ecr_repo_1            = "hello-world"
subdomain_1           = "service-1"
create_front_redirect = false

service_name_2  = "service-2"
ecr_repo_2      = "hello-world"
subdomain_2     = "service-2"

service_name_3  = "service-3"
ecr_repo_3      = "hello-world"
subdomain_3     = "service-3"
aws_profile = "default"
cluster_name = "ecs-test-cluster"
domain = "domain.com"
domain = "sub"
db_version = "5.7"
db_user = "root"
db_password = "root"
db_port = 3306

# -------------------------------------------------------------------
# Service 1
# -------------------------------------------------------------------
service_name_1          = "ecs_service_1"
ecr_repo_1              = "hello-world"

# -------------------------------------------------------------------
# Service 2
# -------------------------------------------------------------------
service_name_2 = "ecs_service_2"
ecr_repo_2 = "hello-world"

# -------------------------------------------------------------------
# Service 3
# -------------------------------------------------------------------
service_name_3 = "ecs_service_3"
ecr_repo_3 = "hello-world"
task_definition_cpu_1   = 512
task_definition_ram_1   = 1024

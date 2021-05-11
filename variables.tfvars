aws_profile   = "default"
cluster_name  = "ecs-test-cluster"
db_version    = "5.7"
db_user       = "root"
db_password   = "root"
db_port       = 3306

domain        = "domain.com"
subdomains    = ["sub1", "sub2", "sub3"]
service_names = ["ecs_service_1", "ecs_service_2", "ecs_service_3"]
ecr_repos     = ["hello-world", "hello-world", "hello-world"]

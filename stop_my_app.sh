cd ./terraform/api_gateway
terraform init
terraform destroy --auto-approve
cd ../..

cd ./terraform/cloud_run
terraform init
terraform destroy --auto-approve
cd ../..
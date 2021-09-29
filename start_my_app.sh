project=roi-takeoff-user92
region=us-central1

cd ./terraform/cloud_run
terraform init
terraform apply --auto-approve
cd ../..

cp ./events-app/spec.yaml ./terraform/api_gateway
cloudrun_url=$(gcloud run services describe events-app --platform managed --project $project --region $region --format 'value(status.url)' | cut -d '/' -f3)
sed -i.bak "s/CLOUD_RUN_URL/$cloudrun_url/g" ~/gitprojects/ndowgun-lvl-2/terraform/api_gateway/spec.yaml

cd ./terraform/api_gateway
terraform init
terraform apply --auto-approve
cd ../..
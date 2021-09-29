cd ./events-app
docker build --tag=gcr.io/roi-takeoff-user92/events-app:latest .
gcloud builds submit --tag=gcr.io/roi-takeoff-user92/events-app:latest .
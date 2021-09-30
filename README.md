# ndowgun-lvl-2

This repo currently supports a basic API for creating, reading and deleting "Events", but may be used for experimentation.

# Usage

If deploying to a new project, make sure to adjust publish_my_app and the "app_project" in all .tfvars files appropriately.

To publish new version of app as "latest": ```./publish_my_app.sh```

To deploy the Cloud Run app and API gateway: 
- Make sure to set variables appropriately in ```./start_my_app```

To remove the app and API gateway: ```./stop_my_app```

# Contributors

- ndowgun

Thanks to:
- This cool guy for his Terraform https://github.com/vinycoolguy2015/awslambda/tree/master/gcp_cloudrun_apigateway 
- Doug for his Go starter app https://github.com/drehnstrom/go-api 
- Ruth Morrison for her openapi spec skills
# Deploy Script for 3-Tier App

This script will zip your application tiers and upload them to the S3 bucket created by Terraform.

## Prerequisites
1. Run `terraform apply` first to create the bucket.
2. Note the bucket name from the AWS console (starts with `three-tier-app-code-`).

## Deployment Steps

### 1. Build the Frontend
Go to `application-code/web-tier` and run:
```bash
npm install
npm run build
# Zip the build folder
cd build && zip -r ../../../web-tier-build.zip . && cd ../../../
```

### 2. Prepare the Backend
Go to `application-code/app-tier` and run:
```bash
# Zip the entire folder
zip -r ../../app-tier.zip .
cd ../../
```

### 3. Upload to S3
Replace `[BUCKET_NAME]` with your actual bucket name and run:
```bash
aws s3 cp web-tier-build.zip s3://[BUCKET_NAME]/web-tier-build.zip
aws s3 cp app-tier.zip s3://[BUCKET_NAME]/app-tier.zip
aws s3 cp application-code/nginx.conf s3://[BUCKET_NAME]/nginx.conf
```

### 4. Refresh Instances
Since we use Auto Scaling Groups, the easiest way to redeploy is to "refresh" the instances:
```bash
aws autoscaling start-instance-refresh --auto-scaling-group-name three-tier-app-web-asg
aws autoscaling start-instance-refresh --auto-scaling-group-name three-tier-app-app-asg
```
This will replace the old "Welcome to Nginx" instances with new ones that download your code from S3 automatically.

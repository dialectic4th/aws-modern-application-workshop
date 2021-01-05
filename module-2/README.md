# Module 2: Creating a Service with AWS Fargate

![Architecture](/images/module-2/architecture-module-2.png)

**Time to complete:** 60 minutes

**Services used:**
* [AWS CloudFormation](https://aws.amazon.com/cloudformation/)
* [AWS Identity and Access Management (IAM)](https://aws.amazon.com/iam/)
* [Amazon Virtual Private Cloud (VPC)](https://aws.amazon.com/vpc/)
* [Amazon Elastic Load Balancing](https://aws.amazon.com/elasticloadbalancing/)
* [Amazon Elastic Container Service (ECS)](https://aws.amazon.com/ecs/)
* [AWS Fargate](https://aws.amazon.com/fargate/)
* [AWS Elastic Container Registry (ECR)](https://aws.amazon.com/ecr/)
* [AWS CodeCommit](https://aws.amazon.com/codecommit/)
* [AWS CodePipeline](https://aws.amazon.com/codepipeline/)
* [AWS CodeDeploy](https://aws.amazon.com/codedeploy/)
* [AWS CodeBuild](https://aws.amazon.com/codebuild/)


### Creating the Core Infrastructure using AWS CloudFormation
* [**An Amazon VPC**](https://aws.amazon.com/vpc/) - a network environment that contains four subnets (two public and two private) in the 10.0.0.0/16 private IP space, as well as all the needed Route Table configurations.  The subnets for this network are created in separate AWS Availability Zones (AZ) to enable high availability across multiple physical facilities in an AWS Region. Learn more about how AZs can help you achieve High Availability [here](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.RegionsAndAvailabilityZones.html).
* [**Two NAT Gateways**](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html) (one for each public subnet, also spanning multiple AZs) - allow the containers we will eventually deploy into our private subnets to communicate out to the Internet to download necessary packages, etc.
* [**A DynamoDB VPC Endpoint**](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/vpc-endpoints-dynamodb.html) - our microservice backend will eventually integrate with [Amazon DynamoDB](https://aws.amazon.com/dynamodb/) for persistence (as part of module 3).
* [**A Security Group**](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html) - Allows your docker containers to receive traffic on port 8080 from the Internet through the Network Load Balancer.
* [**IAM Roles**](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html) - Identity and Access Management Roles are created. These will be used throughout the workshop to give AWS services or resources you create access to other AWS services like DynamoDB, S3, and more.
```
aws cloudformation create-stack --stack-name MythicalMysfitsCoreStack --capabilities CAPABILITY_NAMED_IAM --template-body file://~/environment/aws-modern-application-workshop/module-2/cfn/core.yml   
aws cloudformation describe-stacks --stack-name MythicalMysfitsCoreStack

"StackStatus": "CREATE_IN_PROGRESS" → "StackStatus": "CREATE_COMPLETE"

aws cloudformation describe-stacks --stack-name MythicalMysfitsCoreStack > ~/environment/cloudformation-core-output.json
```



## Module 2b: Deploying a Service with AWS Fargate
### Step1: Creating a Flask Service Container

```
cd ~/environment/aws-modern-application-workshop/module-2/app
docker build . -t REPLACE_ME_ACCOUNT_ID.dkr.ecr.REPLACE_ME_REGION.amazonaws.com/mythicalmysfits/service:latest
docker run -p 8080:8080 REPLACE_ME_WITH_DOCKER_IMAGE_TAG
```

```
aws ecr create-repository --repository-name mythicalmysfits/service
$(aws ecr get-login --no-include-email)
docker push REPLACE_ME_WITH_DOCKER_IMAGE_TAG
aws ecr describe-images --repository-name mythicalmysfits/service
```
### Step2: Configuring the Service Prerequisites in Amazon ECS

```
aws ecs create-cluster --cluster-name MythicalMysfits-Cluster
aws logs create-log-group --log-group-name mythicalmysfits-logs
vim ~/environment/aws-modern-application-workshop/module-2/aws-cli/task-definition.json
aws ecs register-task-definition --cli-input-json file://~/environment/aws-modern-application-workshop/module-2/aws-cli/task-definition.json
```

### Step3: Enabling a Load Balanced Fargate Service

```
aws elbv2 create-load-balancer --name mysfits-nlb --scheme internet-facing --type network --subnets REPLACE_ME_PUBLIC_SUBNET_ONE REPLACE_ME_PUBLIC_SUBNET_TWO > ~/environment/nlb-output.json
aws elbv2 create-target-group --name MythicalMysfits-TargetGroup --port 8080 --protocol TCP --target-type ip --vpc-id REPLACE_ME_VPC_ID --health-check-interval-seconds 10 --health-check-path / --health-check-protocol HTTP --healthy-threshold-count 3 --unhealthy-threshold-count 3 > ~/environment/target-group-output.json
aws elbv2 create-listener --default-actions TargetGroupArn=REPLACE_ME_NLB_TARGET_GROUP_ARN,Type=forward --load-balancer-arn REPLACE_ME_NLB_ARN --port 80 --protocol TCP > /environment/listiner-output.json
```



### Step4: Creating a Service with Fargate
```
aws ecs create-service --cli-input-json file://~/environment/aws-modern-application-workshop/module-2/aws-cli/service-definition.json > ~/environment/ecs-service-output.json
cutl http://REPLACE_ME_DNS_NAME/mysfits
vim ~/environment/aws-modern-application-workshop/module-2/web/index.html
    var mysfitsApiEndpoint = 'REPLACE_ME'; 
aws s3 cp ~/environment/aws-modern-application-workshop/module-2/web/index.html s3://INSERT-YOUR-BUCKET-NAME/index.html
```

 Open your website using the same URL used at the end of Module 1 in order to see your new Mythical Mysfits website, which is retrieving JSON data from your Flask API running within a docker container deployed to AWS Fargate!


## Module 2c: Automating Deployments using AWS Code Services
**Replace Github and CirclcCI later** 
![Architecture](/images/module-2/architecture-module-2b.png)
### Step1: Creating the CI/CD Pipeline

```
aws s3 mb s3://REPLACE_ME_CHOOSE_ARTIFACTS_BUCKET_NAME
aws s3api put-bucket-policy --bucket REPLACE_ME_ARTIFACTS_BUCKET_NAME --policy file://~/environment/aws-modern-application-workshop/module-2/aws-cli/artifacts-bucket-policy.json
aws codecommit create-repository --repository-name MythicalMysfitsService-Repository
aws codebuild create-project --cli-input-json file://~/environment/aws-modern-application-workshop/module-2/aws-cli/code-build-project.json
aws codepipeline create-pipeline --cli-input-json file://~/environment/aws-modern-application-workshop/module-2/aws-cli/code-pipeline.json
aws ecr set-repository-policy --repository-name mythicalmysfits/service --policy-text file://~/environment/aws-modern-application-workshop/module-2/aws-cli/ecr-policy.json
```


### Step2: Test the CI/CD Pipeline

```
git config --global user.name "REPLACE_ME_WITH_YOUR_NAME"
git config --global user.email REPLACE_ME_WITH_YOUR_EMAIL@example.com
git config --global credential.helper '!aws codecommit credential-helper $@'
git config --global credential.UseHttpPath true
cd ~/environment/
git clone https://git-codecommit.REPLACE_REGION.amazonaws.com/v1/repos/MythicalMysfitsService-Repository
cp -r ~/environment/aws-modern-application-workshop/module-2/app/* ~/environment/MythicalMysfitsService-Repository/
cd ~/environment/MythicalMysfitsService-Repository/
git add .
git commit -m "I changed the age of one of the mysfits."
git push
```


[Proceed to Module 3](/module-3)

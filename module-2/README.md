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
- `sh scripts/00run_cloudformation.sh REPLACE_ME_STACK_NAME`
- **Pay attention to the charge(Especially NAT gateway)**
```
aws cloudformation create-stack --stack-name STACK_NAME --capabilities CAPABILITY_NAMED_IAM --template-body file://$PWD/cfn/core.yml   
aws cloudformation describe-stacks --stack-name STACK_NAME
aws cloudformation describe-stacks --stack-name STACK_NAME  > $PWD/../outputs/cloudformation-core-output.json
```



## Module 2b: Deploying a Service with AWS Fargate
### Step1: Creating a Flask Service Container
- `sh scripts/01run_container.sh REPLACE_ME_ACCOUNT_ID REPLACE_ME_REOPOSITORY_NAME TAG_NAME`
```
cd ~/environment/aws-modern-application-workshop/module-2/app
docker build . -t REPLACE_ME_ACCOUNT_ID.dkr.ecr.REPLACE_ME_REGION.amazonaws.com/REPLACE_ME_REOPOSITORY_NAME:TAG_NAME
docker run -p 8080:8080 REPLACE_ME_ACCOUNT_ID.dkr.ecr.REPLACE_ME_REGION.amazonaws.com/REPLACE_ME_REOPOSITORY_NAME:TAG_NAME
curl http://0.0.0.0:8080/ 
{"message":"Nothing here, used for health check. Try /mysfits instead."}
```

```
aws ecr create-repository --repository-name REPLACE_ME_REOPOSITORY_NAME
aws ecr get-login-password --region REPLACE_ME_REGION | docker login --username AWS --password-stdin REPLACE_ME_ACCOUNT_ID.dkr.REPLACE_ME_REGION.amazonaws.com
docker push REPLACE_ME_ACCOUNT_ID.dkr.ecr.REPLACE_ME_REGION.amazonaws.com/REPLACE_ME_REOPOSITORY_NAME:TAG_NAME
aws ecr describe-images --repository-name REPLACE_ME_REOPOSITORY_NAME:TAG_NAME
```
### Step2: Configuring the Service Prerequisites in Amazon ECS
- `vim aws-cli/task-definition.json`
- `sh scripts/02run_ecs.sh CLUSTER-NAME LOG-GROUP-NAME`
```
aws ecs create-cluster --cluster-name CLUSTER-NAME
aws logs create-log-group --log-group-name LOG-GROUP-NAME
aws ecs register-task-definition --cli-input-json file://$PWD/aws-cli/task-definition.json
```

### Step3: Enabling a Load Balanced Fargate Service
- `sh scripts/03Arun_nlb.sh NLB-NAME　PUBLIC_SUBNET_ONE_ID PUBLIC_SUBNET_TWO_ID`
```
aws elbv2 create-load-balancer --name $1 --scheme internet-facing --type network --subnets $2 $3 > $PWD/../outputs/nlb-output.json
```

- `sh scripts/03Brun_nlb.sh TARTGET_GROUP_NAME VPC_ID`
```
aws elbv2 create-target-group --name $1 --port 8080 --protocol TCP --target-type ip --vpc-id $2 --health-check-interval-seconds 10 --health-check-path / --health-check-protocol HTTP --healthy-threshold-count 3 --unhealthy-threshold-count 3 > $PWD/../outputs/target-group-output.json
```

- `sh scripts/03Crun_nlb.sh TARGET_GROUP_ARN LOAD_BALANCER_ARN`
```
aws elbv2 create-listener --default-actions TargetGroupArn=$1,Type=forward --load-balancer-arn $2 --port 80 --protocol TCP > $PWD/../outputs/listiner-output.json
```

### Step4: Creating a Service with Fargate
- select public or private subnet 
- if you use private subnet
    - `aws aws cloudformation create-stack --stack-name REPLACE_ME_STACK_NAME --capabilities CAPABILITY_NAMED_IAM --template-body file://$PWD/cfn/nat.yml `
    - `aws cloudformation describe-stacks --stack-name REPLACE_ME_STACK_NAME  > $PWD/../outputs/cloudformation-nat-output.json`
- **Pay attention to the charge(Especially NAT gateway)**
- `vim aws-cli/service-definition.json`
- `sh scripts/04run_service.sh`
- `open DNSName`(in nlb-output.json)

```
service-definition
      "assignPublicIp": "ENABLED or DISABLED",
      "securityGroups": [
        "sg-0ee5beb57b1ce3562"
      ],
      "subnets": [
        "PUBLIC ONE or PRIVATE ONE",
        "PUBLIC ONE or PRIVATE ONE"

aws ecs create-service --cli-input-json file://$PWD/aws-cli/service-definition.json > $PWD/../outputs/ecs-service-output.json
```



### Step5: Update Mythical Mysfits to Call the NLB
- `sh scripts/05run_html.sh INSERT-YOUR-BUCKET-NAME`
```
aws s3 cp $PWD/web/index.html s3://$1/index.html
open http://$1.s3-website-us-west-2.amazonaws.com
```

## Module 2c: Automating Deployments using AWS Code Services
### Replace Github and CirclcCI and AWS CLI
- show `scripts/08update_service.sh`
- When you want to update task-container, write docker-tag in `aws-cli/task-definition.json` and run `sh scripts/08update_service.sh REPLACE_ME_ACCOUNT_ID REPLACE_ME_REOPOSITORY_NAME TAG_NAME`
- `Ignore the following`
![Architecture](/images/module-2/architecture-module-2b.png)

### Step1: Creating the CI/CD Pipeline
- `vim aws-cli/artifacts-bucket-policy.json`
- `vim app/buildspec.yml`
- `vim aws-cli/code-build-project.json`
- `vim aws-cli/code-pipeline.json`
- `vim aws-cli/ecr-policy.json`
- `sh 06edit_CICD.sh`
```
aws s3 mb s3://REPLACE_ME_CHOOSE_ARTIFACTS_BUCKET_NAME
aws s3api put-bucket-policy --bucket REPLACE_ME_ARTIFACTS_BUCKET_NAME --policy file://~/environment/aws-modern-application-workshop/module-2/aws-cli/artifacts-bucket-policy.json
aws codecommit create-repository --repository-name MythicalMysfitsService-Repository
aws codebuild create-project --cli-input-json file://~/environment/aws-modern-application-workshop/module-2/aws-cli/code-build-project.json
aws codepipeline create-pipeline --cli-input-json file://~/environment/aws-modern-application-workshop/module-2/aws-cli/code-pipeline.json
aws ecr set-repository-policy --repository-name mythicalmysfits/service --policy-text file://~/environment/aws-modern-application-workshop/module-2/aws-cli/ecr-policy.json
```

### Step2: Test the CI/CD Pipeline
- `sh 07test_CICD.sh`
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

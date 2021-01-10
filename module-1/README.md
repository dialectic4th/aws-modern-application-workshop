# Module 1: IDE Setup and Static Website Hosting
### intro
![Architecture](/images/module-1/architecture-module-1.png)

**Time to complete:** 20 minutes

**Services used:**
* [AWS Cloud9](https://aws.amazon.com/cloud9/)
* [Amazon Simple Storage Service (S3)](https://aws.amazon.com/s3/)


#### Step1 :Cloud9
- Sign In to the AWS Console us-west-2 (Oregon)
- Click **Create Environment** on the Cloud9 home page:
- Name your environment **MythicalMysfitsIDE** with any description you'd like, and click **Next Step**:
- Leave the Environment settings as their defaults and click **Next Step**:
- Click **Create Environment**:
- (If you stop to work in Cloud9, stop this EC2 instance.)

#### Step2: Cloning Repository
- fork and clone it 
```
git clone -b python https://github.com/REPLACE_ACCOUT_NAME/aws-modern-application-workshop.git
cd aws-modern-application-workshop
```

#### Step3: Creating a Static Website in Amazon S3
- `sh run.sh REPLACE_ME_BUCKET_NAME`
```
aws s3 mb s3://REPLACE_ME_BUCKET_NAME
aws s3 website s3://REPLACE_ME_BUCKET_NAME --index-document index.html
aws s3api put-bucket-policy --bucket REPLACE_ME_BUCKET_NAME --policy file://~/environment/aws-modern-application-workshop/module-1/aws-cli/website-bucket-policy.json
aws s3 cp ~/environment/aws-modern-application-workshop/module-1/web/index.html s3://REPLACE_ME_BUCKET_NAME/index.html
curl http://REPLACE_ME_BUCKET_NAME.s3-website-REPLACE_ME_YOUR_REGION.amazonaws.com
```


### Next:Step2
[Proceed to Module 2](/module-2)



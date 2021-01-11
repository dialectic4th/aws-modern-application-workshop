# not working test complete (use github and circleci)
echo "edit aws-cli/artifacts-bucket-policy.json" 
echo "write bucket name when running"
echo "exmaple is mythical-mysfits-python-practice-archifacts-103362761098 MythicalMysfitsService-Repository mythicalmysfits/service"
echo $1
echo $2
echo $3
aws s3 mb s3://$1
aws s3api put-bucket-policy --bucket $1 --policy file://$PWD/aws-cli/artifacts-bucket-policy.json
aws codecommit create-repository --repository-name $2
aws codebuild create-project --cli-input-json file://$PWD/aws-cli/code-build-project.json
aws codepipeline create-pipeline --cli-input-json file://$PWD/aws-cli/code-pipeline.json
aws ecr set-repository-policy --repository-name $3 --policy-text file://$PWD/aws-cli/ecr-policy.json

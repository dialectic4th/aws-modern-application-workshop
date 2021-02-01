echo "write stack name"
echo "stack name exmaple is MythicalMysfitsCoreStack"
echo "STACK-NAME" $1
aws cloudformation create-stack --stack-name $1 --capabilities CAPABILITY_NAMED_IAM --template-body file://$PWD/cfn/core.yml   
aws cloudformation describe-stacks --stack-name $1
aws cloudformation describe-stacks --stack-name $1  > $PWD/../outputs/cloudformation-core-output.json
# aws cloudformation create-stack --stack-name NATStack --capabilities CAPABILITY_NAMED_IAM --template-body file://$PWD/cfn/nat.yml   
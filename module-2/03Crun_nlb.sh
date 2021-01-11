echo "write target-group arn and load-balancer arn"
echo "exmaples is arn:aws:elasticloadbalancing:us-west-2:1***:targetgroup/xxx arn:aws:elasticloadbalancing:us-west-2:1***:loadbalancer/xxx"
echo "TARGET_GROUP_ARN" $1
echo "LOAD_BALANCER_ARN" $2
aws elbv2 create-listener --default-actions TargetGroupArn=$1,Type=forward --load-balancer-arn $2 --port 80 --protocol TCP > $PWD/../outputs/listiner-output.json

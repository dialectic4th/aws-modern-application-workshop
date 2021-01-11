echo "write target-group name and vpc id"
echo "exmaples is MythicalMysfits-TargetGroup vpc-0***"
echo "TARTGET_GROUP_NAME" $1
echo "VPC_ID" $2

aws elbv2 create-target-group --name $1 --port 8080 --protocol TCP --target-type ip --vpc-id $2 --health-check-interval-seconds 10 --health-check-path / --health-check-protocol HTTP --healthy-threshold-count 3 --unhealthy-threshold-count 3 > $PWD/../outputs/target-group-output.json

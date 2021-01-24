echo "write closter name and log group name"
echo "exmaples is MythicalMysfits-Cluster mythicalmysfits-logs"
echo "CLUSTER-NAME" $1
echo "LOG-GROUP-NAME" $2
aws ecs create-cluster --cluster-name $1
aws logs create-log-group --log-group-name $2
aws ecs register-task-definition --cli-input-json file://$PWD/aws-cli/task-definition.json > $PWD/../outputs/ecs-task-definition-output.json
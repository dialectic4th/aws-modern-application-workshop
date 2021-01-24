echo "edit service-definition.json referring to task-definition.json (public or private subnet)"
echo "ex. taskDefinition in servicedefinition =   family in task-definition.json"

aws ecs create-service --cli-input-json file://$PWD/aws-cli/service-definition.json > $PWD/../outputs/ecs-service-output.json
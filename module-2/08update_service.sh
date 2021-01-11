echo "write account id, repository name, repository tag"
echo "exmaples is 123456789012, mythicalmysfits/service, v1"
echo "ACCUOUNT_ID" $1
echo "REPOSITORY_NAME" $2
echo "REPOSITORY_TAG" $3

# push new image
docker build ./app/. -t $1.dkr.ecr.us-west-2.amazonaws.com/$2:$3
# docker run -p 8080:8080 $1.dkr.ecr.us-west-2.amazonaws.com/$2:$3
# curl http://0.0.0.0:8080/ 
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin $1.dkr.ecr.us-west-2.amazonaws.com
docker push $1.dkr.ecr.us-west-2.amazonaws.com/$2:$3

# update task in service
aws ecs register-task-definition --cli-input-json file://$PWD/aws-cli/task-definition.json > $PWD/../outputs/ecs-task-definition-output.json
aws ecs update-service --cluster MythicalMysfits-Cluster --service MythicalMysfits-Service --task-definition mythicalmysfitsservice > $PWD/../outputs/ecs-service-update-output.json

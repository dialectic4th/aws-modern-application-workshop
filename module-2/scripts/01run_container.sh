echo "write account id, repository name, repository tag"
echo "exmaples is 123456789012, mythicalmysfits/service, v1"
echo "ACCUOUNT_ID" $1
echo "REPOSITORY_NAME" $2
echo "REPOSITORY_TAG" $3

docker build ./app/. -t $1.dkr.ecr.us-west-2.amazonaws.com/$2:$3
# local test
# docker run -p 8080:8080 $1.dkr.ecr.us-west-2.amazonaws.com/$2:$3
# curl http://0.0.0.0:8080/ 
# {"message":"Nothing here, used for health check. Try /mysfits instead."}
#aws ecr create-repository --repository-name $2
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin $1.dkr.ecr.us-west-2.amazonaws.com
docker push $1.dkr.ecr.us-west-2.amazonaws.com/$2:$3
aws ecr describe-images --repository-name $2
aws ecr describe-images --repository-name $2 > $PWD/../outputs/ecr-image-output.json
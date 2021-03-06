echo "write bucket name to website-bucket-policy.json and argument when running"
echo "bucket name example is mythical-mysfits-python-practice-accountid"
echo "REPLACE_ME_BUCKET_NAME" $1
aws s3 mb s3://$1
aws s3 website s3://$1 --index-document index.html
aws s3api put-bucket-policy --bucket $1 --policy file://$PWD/aws-cli/website-bucket-policy.json
aws s3 cp web/index.html s3://mythical-mysfits-python-practice/index.html
open http://mythical-mysfits-python-practice.s3-website-us-west-2.amazonaws.com
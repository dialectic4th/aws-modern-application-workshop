echo "edit web/index.html and dewrite bucket name"
echo "exmaple is mythical-mysfits-python-practice"
aws s3 cp $PWD/web/index.html s3://$1/index.html
open http://$1.s3-website-us-west-2.amazonaws.com
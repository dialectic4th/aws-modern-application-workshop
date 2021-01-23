echo "write nlb name and public subnet id 1&2"
echo "exmaples is mysfits-nlb subnet-0*** subnet-0***"
echo "NLB-NAME" $1
echo "PUBLIC_SUBNET_ONE_ID" $2
echo "PUBLIC_SUBNET_TWO_ID" $3

aws elbv2 create-load-balancer --name $1 --scheme internet-facing --type network --subnets $2 $3 > $PWD/../outputs/nlb-output.json

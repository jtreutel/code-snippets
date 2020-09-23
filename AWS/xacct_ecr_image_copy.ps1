#You should run this on from a machine with a fast connection and enough space to temporarily host all of the images locally.
#Running this from a temporary EC2 instance is recommended.

$sourceAcctProfile 	= "some_aws_profile_name"
$sourceAcctRegion 	= "us-east-1"

$destAcctProfile    = "some_other_aws_profile_name"
$destAcctRegion 	  = "us-west-1"

$targetImages 		  = "foo","bar","baz"
$imageTag 			    = "SOMETAG"

$sourceAcctNo = (aws sts get-caller-identity --profile $sourceAcctProfile --region $sourceAcctRegion | ConvertFrom-Json).Account
$destAcctNo = (aws sts get-caller-identity --profile $destAcctProfile --region $destAcctRegion | ConvertFrom-Json).Account


# Pull down Docker images locally from source ECR repos
aws ecr get-login-password --region $sourceAcctRegion --profile $sourceAcctProfile | docker login --username AWS --password-stdin https://$sourceAcctNo.dkr.ecr.$sourceAcctRegion.amazonaws.com
foreach($image in $targetImages) {
  docker pull "$sourceAcctNo.dkr.ecr.$sourceAcctRegion.amazonaws.com/${image}:${imageTag}"
}
docker logout https://$sourceAcctNo.dkr.ecr.$sourceAcctRegion.amazonaws.com


# Retag Docker images locally
foreach($image in $targetImages) {
  docker tag "$sourceAcctNo.dkr.ecr.$sourceAcctRegion.amazonaws.com/${image}:${imageTag}" "$destAcctNo.dkr.ecr.$destAcctRegion.amazonaws.com/${image}:${imageTag}"
}


# Push retagged Docker images  to destination repo
aws ecr get-login-password --region $destAcctRegion --profile $destAcctProfile | docker login --username AWS --password-stdin https://$destAcctNo.dkr.ecr.$destAcctRegion.amazonaws.com
foreach($image in $targetImages) {
  docker push "$destAcctNo.dkr.ecr.$destAcctRegion.amazonaws.com/${image}:${imageTag}"
}
docker logout https://$sourceAcctNo.dkr.ecr.$sourceAcctRegion.amazonaws.com
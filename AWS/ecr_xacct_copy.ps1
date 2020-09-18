$sourceAcctProfile = "source_account_aws_profile"
$sourceAcctRegion = "us-west-1"
$destAcctProfile = "dest_account_aws_profile"
$destAcctRegion = "us-west-1"
$targetImages = "foo","bar","baz"
$imageTag = "SOMETAG"
$sourceAcctNo = (aws sts get-caller-identity --profile $sourceAcctProfile --region $sourceAcctRegion | ConvertFrom-Json).Account
$destAcctNo = (aws sts get-caller-identity --profile $destAcctProfile --region $destAcctRegion | ConvertFrom-Json).Account

# Pull images from source ECR
aws ecr get-login-password --region $sourceAcctRegion --profile $sourceAcctProfile | docker login --username AWS --password-stdin https://$sourceAcctNo.dkr.ecr.$sourceAcctRegion.amazonaws.com
foreach($image in $targetImages) {
  docker pull "$sourceAcctNo.dkr.ecr.$sourceAcctRegion.amazonaws.com/${image}:${imageTag}"
}
docker logout https://$sourceAcctNo.dkr.ecr.$sourceAcctRegion.amazonaws.com

# Retag images locally
foreach($image in $targetImages) {
  docker tag "$sourceAcctNo.dkr.ecr.$sourceAcctRegion.amazonaws.com/${image}:${imageTag}" "$destAcctNo.dkr.ecr.$destAcctRegion.amazonaws.com/${image}:${imageTag}"
}

# Push images to target ECR
aws ecr get-login-password --region $destAcctRegion --profile $destAcctProfile | docker login --username AWS --password-stdin https://$destAcctNo.dkr.ecr.$destAcctRegion.amazonaws.com
foreach($image in $targetImages) {
  docker push "$destAcctNo.dkr.ecr.$destAcctRegion.amazonaws.com/${image}:${imageTag}"
}
docker logout https://$sourceAcctNo.dkr.ecr.$sourceAcctRegion.amazonaws.com

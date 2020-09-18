SOURCE_ACCT_PROFILE="source_account_aws_profile"
SOURCE_ACCT_REGION="us-west-1"
DEST_ACCT_PROFILE="dest_account_aws_profile"
DEST_ACCT_REGION="us-west-1"
TARGET_IMAGES=("foo" "bar" "baz")
IMAGE_TAG="SOMETAG"
SOURCE_ACCT_NO=$(aws sts get-caller-identity --profile $SOURCE_ACCT_PROFILE --region $SOURCE_ACCT_REGION | jq -r '.Account')
DEST_ACCT_NO=$(aws sts get-caller-identity --profile $DEST_ACCT_PROFILE --region $DEST_ACCT_REGION | jq -r '.Account')

# Pull images from source ECR
docker login -u AWS -p $(aws ecr get-login-password --region $SOURCE_ACCT_REGION --profile $SOURCE_ACCT_PROFILE) $SOURCE_ACCT_NO.dkr.ecr.$SOURCE_ACCT_REGION.amazonaws.com
for IMAGE in ${TARGET_IMAGES[@]}; do
  docker pull "$SOURCE_ACCT_NO.dkr.ecr.$SOURCE_ACCT_REGION.amazonaws.com/$IMAGE:$IMAGE_TAG"
done

# Retag images locally
docker logout $SOURCE_ACCT_NO.dkr.ecr.$SOURCE_ACCT_REGION.amazonaws.com
for IMAGE in ${TARGET_IMAGES[@]}; do
  docker tag "$SOURCE_ACCT_NO.dkr.ecr.$SOURCE_ACCT_REGION.amazonaws.com/$IMAGE:$IMAGE_TAG" "$DEST_ACCT_NO.dkr.ecr.$DEST_ACCT_REGION.amazonaws.com/$IMAGE:$IMAGE_TAG"
done

# Push images to target ECR
docker login -u AWS -p $(aws ecr get-login-password --region $DEST_ACCT_REGION --profile $DEST_ACCT_PROFILE) $DEST_ACCT_NO.dkr.ecr.$DEST_ACCT_REGION.amazonaws.com
for IMAGE in ${TARGET_IMAGES[@]}; do
  docker push "$DEST_ACCT_NO.dkr.ecr.$DEST_ACCT_REGION.amazonaws.com/$IMAGE:$IMAGE_TAG"
done
docker logout $DEST_ACCT_NO.dkr.ecr.$DEST_ACCT_REGION.amazonaws.com
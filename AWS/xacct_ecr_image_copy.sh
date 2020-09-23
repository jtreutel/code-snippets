#You should run this on from a machine with a fast connection and enough space to temporarily host all of the images locally.
#Running this from a temporary EC2 instance is recommended.

SOURCE_ACCT_PROFILE="some_aws_profile_name"
SOURCE_ACCT_REGION="us-east-1"

DEST_ACCT_PROFILE="some_other_aws_profile_name"
DEST_ACCT_REGION="us-west-1"

TARGET_IMAGES=("foo" "bar" "baz")
IMAGE_TAG="SOMETAG"

SOURCE_ACCT_NO=$(aws sts get-caller-identity --profile $SOURCE_ACCT_PROFILE --region $SOURCE_ACCT_REGION | jq -r '.Account')
DEST_ACCT_NO=$(aws sts get-caller-identity --profile $DEST_ACCT_PROFILE --region $DEST_ACCT_REGION | jq -r '.Account')

# Pull down Docker images locally from source ECR repos
docker login -u AWS -p $(aws ecr get-login-password --region $SOURCE_ACCT_REGION --profile $SOURCE_ACCT_PROFILE) $SOURCE_ACCT_NO.dkr.ecr.$SOURCE_ACCT_REGION.amazonaws.com
for IMAGE in ${TARGET_IMAGES[@]}; do
  docker pull "$SOURCE_ACCT_NO.dkr.ecr.$SOURCE_ACCT_REGION.amazonaws.com/$IMAGE:$IMAGE_TAG"
done
docker logout $SOURCE_ACCT_NO.dkr.ecr.$SOURCE_ACCT_REGION.amazonaws.com

# Retag Docker images locally
for IMAGE in ${TARGET_IMAGES[@]}; do
  docker tag "$SOURCE_ACCT_NO.dkr.ecr.$SOURCE_ACCT_REGION.amazonaws.com/$IMAGE:$IMAGE_TAG" "$DEST_ACCT_NO.dkr.ecr.$DEST_ACCT_REGION.amazonaws.com/$IMAGE:$IMAGE_TAG"
done

# Push retagged Docker images  to destination repo
docker login -u AWS -p $(aws ecr get-login-password --region $DEST_ACCT_REGION --profile $DEST_ACCT_PROFILE) $DEST_ACCT_NO.dkr.ecr.$DEST_ACCT_REGION.amazonaws.com
for IMAGE in ${TARGET_IMAGES[@]}; do
  docker push "$DEST_ACCT_NO.dkr.ecr.$DEST_ACCT_REGION.amazonaws.com/$IMAGE:$IMAGE_TAG"
done
docker logout $DEST_ACCT_NO.dkr.ecr.$DEST_ACCT_REGION.amazonaws.com
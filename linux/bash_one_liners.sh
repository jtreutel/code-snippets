#Check cert chain for MITM
openssl s_client -showcerts -verify 32 -connect sts.amazonaws.com:443

#Get the latest CircleCI CLI tarball for Linux
curl https://api.github.com/repos/CircleCI-Public/circleci-cli/releases/latest | jq -r '.assets[] | select(.name | contains("linux_amd64")) | .browser_download_url' | wget -qi -
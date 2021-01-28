#Check cert chain for MITM
openssl s_client -showcerts -verify 32 -connect sts.amazonaws.com:443


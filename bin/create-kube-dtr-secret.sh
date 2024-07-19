#!/bin/sh
printf "Enter the registry username: "
read username
printf "Enter the registry password: "
stty -echo
read password
stty echo
printf "\n"
printf "Enter the registry name: "
read registry_name
printf "Enter the name of the secret object: "
read secret_name

username_base64=$(printf $username | base64)
password_base64=$(printf $password | base64)
credentials_base64=$(printf "$username:$password" | base64)
temp_manifest=$(mktemp)

cat > $temp_manifest <<- EOF
apiVersion: v1
kind: Secret
metadata:
  name: $secret_name
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: $(printf "{\"auths\":{\"${registry_name}\":{\"username\":\"${username}\",\"password\":\"${password}\",\"auth\":\"${credentials_base64}\"}}}" | base64 | tr -d '\n')
EOF

cat $temp_manifest
kubectl apply -f $temp_manifest
rm $temp_manifest

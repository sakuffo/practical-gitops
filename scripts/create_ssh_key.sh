aws ec2 create-key-pair --key-name saku-gitops --query 'KeyMaterial' --output text > saku-gitops.pem
chmod 400 saku-gitops.pem
eval "$(ssh-agent -s)"
ssh-add saku-gitops.pem
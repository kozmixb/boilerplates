#! /bin/sh

# Config Docker
yum update -y
yum install -y amazon-efs-utils
amazon-linux-extras install docker
service docker start
usermod -a -G docker ec2-user
chkconfig docker on

# Mount EFS volume
sudo mkdir -p /mnt/efs
sudo su -c  "echo '${efs_id}:/ /mnt/efs efs _netdev,tls 0 0' >> /etc/fstab"
sleep 120
sudo mount /mnt/efs

# Start container
aws ecr get-login-password --region=${aws_region}| docker login -u AWS --password-stdin "https://${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com"
docker pull ${ecr_url}
docker run \
  --name satis \
  --restart unless-stopped \
  -v /mnt/efs/public:/var/www/html/public \
  -p ${container_port}:${container_port} \
  -d ${ecr_url}

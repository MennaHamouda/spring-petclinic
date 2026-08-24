#!/bin/bash
# modules/bastion/user-data.sh

set -e


# 1. Update system
yum update -y

# 2. Install required packages
yum install -y \
  curl \
  unzip \
  git \
  jq \
  htop \
  tree \
  nano \
  vim


# 3. Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
  -o "/tmp/awscliv2.zip"

unzip -q /tmp/awscliv2.zip -d /tmp

/tmp/aws/install \
  --bin-dir /usr/bin \
  --install-dir /usr/local/aws-cli \
  --update

rm -rf /tmp/aws /tmp/awscliv2.zip


# 4. Install kubectl
curl -Lo /tmp/kubectl \
  https://s3.us-west-2.amazonaws.com/amazon-eks/1.30.0/2024-05-12/bin/linux/amd64/kubectl

chmod +x /tmp/kubectl
mv /tmp/kubectl /usr/local/bin/kubectl


# 5. Install Helm
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash


# 6. Create eks-manager user
useradd -m -s /bin/bash eks-manager

usermod -aG wheel eks-manager


# 7. Configure AWS credentials
mkdir -p /home/eks-manager/.aws

cat > /home/eks-manager/.aws/credentials << EOF
[default]
aws_access_key_id = ${access_key_id}
aws_secret_access_key = ${secret_access_key}
EOF

cat > /home/eks-manager/.aws/config << EOF
[default]
region = ${aws_region}
output = json
EOF


# 8. Set AWS credentials permissions
chown -R eks-manager:eks-manager /home/eks-manager/.aws

chmod 700 /home/eks-manager/.aws

chmod 600 /home/eks-manager/.aws/credentials
chmod 600 /home/eks-manager/.aws/config


# 9. Create kubeconfig for eks-manager
mkdir -p /home/eks-manager/.kube

chown -R eks-manager:eks-manager /home/eks-manager/.kube

sudo -u eks-manager env HOME=/home/eks-manager \
  aws eks update-kubeconfig \
  --region ${aws_region} \
  --name ${cluster_name}


# 10. Verify kubectl configuration
chown -R eks-manager:eks-manager /home/eks-manager/.kube


# 11. Create Cluster Autoscaler YAML
cat > /home/eks-manager/cluster-autoscaler.yaml << 'EOF'
${cluster_autoscaler_yaml_content}
EOF

chown eks-manager:eks-manager \
  /home/eks-manager/cluster-autoscaler.yaml

chmod 644 /home/eks-manager/cluster-autoscaler.yaml
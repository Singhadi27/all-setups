#vim .bashrc
#export PATH=$PATH:/usr/local/bin/
#source .bashrc


#!/bin/bash

# Step 1: Configure AWS credentials
aws configure

# Step 2: Install kubectl and kops
curl -LO "https://dl.k8s.io/release/$(curl -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
wget https://github.com/kubernetes/kops/releases/download/v1.32.0/kops-linux-amd64

chmod +x kubectl kops-linux-amd64
mv kubectl /usr/local/bin/
mv kops-linux-amd64 /usr/local/bin/kops

# Step 3: Set up S3 bucket for KOPS state store
aws s3api create-bucket --bucket devopsbyaditya03.k8s.local --region us-east-1
aws s3api put-bucket-versioning --bucket devopsbyaditya03.k8s.local \
  --region us-east-1 \
  --versioning-configuration Status=Enabled

# Step 4: Export KOPS state store
export KOPS_STATE_STORE=s3://devopsbyaditya03.k8s.local
echo 'export KOPS_STATE_STORE=s3://devopsbyaditya03.k8s.local' >> ~/.bashrc

# Step 5: Create Kubernetes cluster
kops create cluster \
  --name aditya.k8s.local \
  --cloud=aws \
  --zones us-east-1a \
  --control-plane-count=1 \
  --control-plane-size=t2.medium \
  --node-count=2 \
  --node-size=t2.micro

# Step 6: Apply the cluster config
kops update cluster --name aditya.k8s.local --yes --admin

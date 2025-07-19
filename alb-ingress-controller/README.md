AWS Load Balancer Controller Install on AWS EKSAWS Load Balancer Controller Install on AWS EKS

+++++++++++++++++++++++

ALB controller creation:
IAM policy:

arn::
arn:aws:iam::979090212156:policy/AWSLoadBalancerControllerIAMPolicy

# Template
eksctl create iamserviceaccount \
  --cluster=eks-demo-terraform \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --attach-policy-arn=arn:aws:iam::979090212156:policy/AWSLoadBalancerControllerIAMPolicy \
  --override-existing-serviceaccounts \
  --approve
  
  ++++++++++
  
HELM install Application Loadbanacer controller

# Add the eks-charts repository.
helm repo add eks https://aws.github.io/eks-charts

# Update your local repo to make sure that you have the most recent charts.
helm repo update

# Install the AWS Load Balancer Controller.

## Replace Cluster Name, Region Code, VPC ID, Image Repo Account ID and Region Code  
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=eks-demo-terraform \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=us-east-1 \
  --set vpcId=vpc-00453b537ae0001ef \
  --set image.repository=public.ecr.aws/eks/aws-load-balancer-controller
  
output:
NAME: aws-load-balancer-controller
LAST DEPLOYED: Sat Jul 19 22:17:46 2025
NAMESPACE: kube-system
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
AWS Load Balancer controller installed!

# Verify that the controller is installed.
kubectl -n kube-system get deployment 
kubectl -n kube-system get deployment aws-load-balancer-controller
kubectl -n kube-system describe deployment aws-load-balancer-controller
AWS Load Balancer Controller Install on AWS EKSAWS Load Balancer Controller Install on AWS EKS
Create IAM Policy and make a note of Policy ARN
Create IAM Role and k8s Service Account and bound them together
Install AWS Load Balancer Controller using HELM3 CLI
Understand IngressClass Concept and create a default Ingress Class

https://github.com/kubernetes-sigs/aws-load-balancer-controller
+++++++++++++++++++++++

ALB controller creation:
#CLUSTER Creation:
eksctl create cluster --name=eksdemo1 \
                      --region=us-east-1 \
                      --zones=us-east-1a,us-east-1b \
                      --version="1.21" \
                      --without-nodegroup 

eksctl create nodegroup --cluster=eksdemo1 \
                        --region=us-east-1 \
                        --name=eksdemo1-ng-public \
                        --node-type=t3.medium \
                        --nodes-min=2 \
                        --nodes-max=4 \
                        --node-volume-size=20 \
                        --ssh-access \
                        --ssh-public-key=eks-terraform-key \
                        --managed \
                        --asg-access \
                        --external-dns-access \
                        --full-ecr-access \
                        --appmesh-access \
                        --alb-ingress-access \
                        --node-private-networking       

kubectl config get-contexts 
kubectl config view
kubectl config get-contexts
kubectl config use-context my-cluster-name 

IAM policy:

Create an IAM role for the AWS LoadBalancer Controller and attach the role to the Kubernetes service account:

# Download IAM Policy
## Download latest
curl -o iam_policy_latest.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json
## Verify latest
ls -lrta 

# Create IAM Policy using policy downloaded 
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy_latest.json

kubectl get sa -n kube-system
kubectl get sa aws-load-balancer-controller -n kube-system

arn:aws:iam::979090212156:policy/AWSLoadBalancerControllerIAMPolicy
#OIDC Provider
eksctl utils associate-iam-oidc-provider \
    --region us-east-1 \
    --cluster eks-demo-terraform \
    --approve

# Template
eksctl create iamserviceaccount \
  --cluster=eks-demo-terraform \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --attach-policy-arn=arn:aws:iam::979090212156:policy/AWSLoadBalancerControllerIAMPolicy \
  --override-existing-serviceaccounts \
  --approve

#To delete existing SA
eksctl delete iamserviceaccount \
  --cluster=eks-demo-terraform \
  --namespace=kube-system \
  --name=aws-load-balancer-controller
  
  # Verfy EKS Cluster
eksctl get cluster

# Verify EKS Node Groups
eksctl get nodegroup --cluster=eks-demo-terraform

# Verify if any IAM Service Accounts present in EKS Cluster
eksctl get iamserviceaccount --cluster=eks-demo-terraform

# Configure kubeconfig for kubectl
eksctl get cluster # TO GET CLUSTER NAME
aws eks --region <region-code> update-kubeconfig --name <cluster_name>
aws eks --region us-east-1 update-kubeconfig --name eks-demo-terraform

# Verify EKS Nodes in EKS Cluster using kubectl
kubectl get nodes
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
# 1. AWS LBC에 필요한 IAM 정책 생성
resource "aws_iam_policy" "aws_lb_controller_policy" {
  name   = "AWSLoadBalancerControllerIAMPolicy"
  policy = file("${path.module}/iam_policy.json") # 공식 정책 파일 참조
  # IAM 정책 파일 다운로드: https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json
}

# 2. IAM 역할 생성 및 정책 연결
resource "aws_iam_role" "aws_lb_controller_role" {
  name               = "AmazonEKSLoadBalancerControllerRole"
  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  EOF
}

resource "aws_iam_role_policy_attachment" "lb_controller_policy_attach" {
  role       = aws_iam_role.aws_lb_controller_role.name
  policy_arn = aws_iam_policy.aws_lb_controller_policy.arn
}

# 3. AWS LBC를 위한 Service Account 생성
resource "kubernetes_service_account" "aws_lb_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.aws_lb_controller_role.arn
    }
  }
}

# 4. CRDs 적용
# Terraform으로 CRDs를 관리하기 어려운 경우 kubectl 명령을 사용하거나 Terraform 외부 프로세스를 통해 적용
resource "null_resource" "apply_crds" {
  provisioner "local-exec" {
    command = <<EOT
      set GATEWAY_API_VERSION="v1.0.0"
      kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/%GATEWAY_API_VERSION%/standard-install.yaml
      kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller/crds?ref=master"
    EOT
  }
}

# 5. Helm을 사용하여 AWS Load Balancer Controller 설치
resource "helm_release" "aws_lb_controller" {
  name       = "aws-load-balancer-controller"
  chart      = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  namespace  = "kube-system"
  version    = "2.10.0"

  set {
    name  = "region"
    value = local.region # 클러스터가 위치한 리전
  }

  set {
    name  = "clusterName"
    value = module.eks.cluster_name # 클러스터 이름
  }

  set {
    name  = "serviceAccount.create"
    value = "false" # 기존 Service Account 사용
  }

  set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account.aws_lb_controller.metadata[0].name
  }
}

##############################################################
# AWS LBC에 필요한 CRDs 적용
# curl -L https://raw.githubusercontent.com/aws/eks-charts/master/stable/aws-load-balancer-controller/crds/crds.yaml >crds.yaml
# 근데 kubernetes_manifest는 한번에 1개의 리소스만 생성할 수 있음
# 이 파일에는 2개의 리소스가 존재해서 쪼개야함.
############################################################## 

####  중간에 오류가 많아서 테라폼 대신 helm과 kubectl로 돌리는게 더 빠를 수 있음
/*
공식 문서의 절차는 다음과 같다
1. curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json
2. aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy --policy-document file://iam-policy.json
3. eksctl create iamserviceaccount --cluster=<cluster-name> --namespace=kube-system --name=aws-load-balancer-controller --attach-policy-arn=arn:aws:iam::<AWS_ACCOUNT_ID>:policy/AWSLoadBalancerControllerIAMPolicy --approve
5. helm repo add eks https://aws.github.io/eks-charts
6. kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller/crds?ref=master"
7. helm upgrade -i aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set region=<cluster-region> --set clusterName=<k8s-cluster-name> --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller
*/

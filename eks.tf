# EKS 클러스터 구성
module "eks" {
  source  = "terraform-aws-modules/eks/aws" # Terraform 공식 EKS 모듈
  version = "~> 20.11" # EKS 모듈 버전

  # 클러스터 이름 및 버전
  cluster_name    = local.name # 클러스터 이름
  cluster_version = "1.30" # Kubernetes 버전

  # EKS 클러스터 API 공개 설정
  cluster_endpoint_public_access = true # 클러스터 엔드포인트를 퍼블릭으로 노출

  # 클러스터 관리자 권한 활성화 (Terraform 작업 계정)
  enable_cluster_creator_admin_permissions = true

  # EKS 클러스터 기본 애드온 설치
  cluster_addons = {
    coredns    = {} # DNS 관리
    kube-proxy = {} # 클러스터 간 트래픽 라우팅
    vpc-cni    = {} # VPC 네트워킹
  }

  # 클러스터와 서브넷 연결
  vpc_id     = module.vpc.vpc_id # VPC ID
  subnet_ids = module.vpc.private_subnets # 프라이빗 서브넷 ID

  # 관리형 워커 노드 그룹 구성
  eks_managed_node_groups = {
    sesac-univ-nodes = {
      instance_types = ["t2.micro"] # 워커 노드 인스턴스 타입
      min_size       = 1 # 최소 노드 수
      max_size       = 5 # 최대 노드 수
      desired_size   = 2 # 기본 노드 수
    }
    sesac-univ-nodes2 = {
      instance_types = ["t3.medium"] # 워커 노드 인스턴스 타입
      min_size       = 1 # 최소 노드 수
      max_size       = 3 # 최대 노드 수
      desired_size   = 1 # 기본 노드 수
    }
  }
  # Istio 관련 포트를 위한 보안 그룹 규칙 추가
  node_security_group_additional_rules = {
    ingress_15017 = {
      description                   = "Cluster API - Istio Webhook namespace.sidecar-injector.istio.io"
      protocol                      = "TCP" # 프로토콜
      from_port                     = 15017 # 시작 포트
      to_port                       = 15017 # 종료 포트
      type                          = "ingress" # 인바운드 트래픽
      source_cluster_security_group = true # 클러스터 보안 그룹에서 허용
    }
    ingress_15012 = {
      description                   = "Cluster API to nodes ports/protocols"
      protocol                      = "TCP"
      from_port                     = 15012
      to_port                       = 15012
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }

  # 공통 태그 적용
  tags = local.tags
}
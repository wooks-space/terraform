# Istio 관련 Helm 차트 설치
module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws" # Terraform EKS Blueprints Addons 모듈
  version = "~> 1.16" # Addons 모듈 버전

  # 클러스터 정보 전달
  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  # ALB Controller 활성화 (Ingress Gateway와 연동)
  enable_aws_load_balancer_controller = true

  # # Istio Helm 차트 배포
  # helm_releases = {
  #   # Istio Base 설치
  #   istio-base = {
  #     chart         = "base" # Helm 차트 이름
  #     chart_version = local.istio_chart_version # 차트 버전
  #     repository    = local.istio_chart_url # 차트 저장소
  #     name          = "istio-base" # 설치 이름
  #     namespace     = kubernetes_namespace_v1.istio_system.metadata[0].name # 네임스페이스
  #   }

  #   # Istio Control Plane 설치
  #   istiod = {
  #     chart         = "istiod" # Helm 차트 이름
  #     chart_version = local.istio_chart_version
  #     repository    = local.istio_chart_url
  #     name          = "istiod"
  #     namespace     = kubernetes_namespace_v1.istio_system.metadata[0].name

  #     # 추가 설정: 로그 출력 파일
  #     set = [
  #       {
  #         name  = "meshConfig.accessLogFile"
  #         value = "/dev/stdout"
  #       }
  #     ]
  #   }
  # }

  # 공통 태그 적용
  tags = local.tags
}

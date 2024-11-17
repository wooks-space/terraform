# AWS 프로바이더 설정
provider "aws" {
  region = local.region # AWS 리전 설정. 로컬 변수에서 값을 참조합니다.
}

# Kubernetes 프로바이더 설정
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint # EKS 클러스터 엔드포인트 URL
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data) # 클러스터의 CA 인증서를 디코딩하여 사용

  exec {
    api_version = "client.authentication.k8s.io/v1beta1" # Kubernetes 인증 API 버전
    command     = "aws" # AWS CLI 명령을 사용하여 인증 수행
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name] # EKS 인증 토큰 생성
  }
}

# Helm 프로바이더 설정
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint # Kubernetes API 서버 엔드포인트
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data) # 클러스터의 CA 인증서 디코딩

    exec {
      api_version = "client.authentication.k8s.io/v1beta1" # Kubernetes 인증 API 버전
      command     = "aws" # AWS CLI 명령어
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name] # EKS 인증 토큰 생성
    }
  }
}
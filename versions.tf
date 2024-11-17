terraform {
  # Terraform 버전 요구 사항 (최소 1.3 이상)
  required_version = ">= 1.3"

  # 프로젝트에서 필요한 프로바이더 설정
  required_providers {
    aws = {
      source  = "hashicorp/aws" # AWS 프로바이더 소스
      version = ">= 5.34" # AWS 프로바이더 최소 버전
    }
    helm = {
      source  = "hashicorp/helm" # Helm 프로바이더 소스
      version = ">= 2.9" # Helm 프로바이더 최소 버전
    }
    kubernetes = {
      source  = "hashicorp/kubernetes" # Kubernetes 프로바이더 소스
      version = ">= 2.20" # Kubernetes 프로바이더 최소 버전
    }
  }
  # Terraform 상태 관리 설정 (S3 백엔드 사용, 주석 처리)
  # ## 사용 시 아래 값을 수정해 활성화하세요.
  # backend "s3" {
  #   bucket = "terraform-ssp-github-actions-state" # S3 버킷 이름
  #   region = "ap-northeast-2" # 버킷이 위치한 AWS 리전
  #   key    = "e2e/istio/terraform.tfstate" # Terraform 상태 파일 저장 경로
  # }
}
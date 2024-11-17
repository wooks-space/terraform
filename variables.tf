# AWS 가용 영역 정보를 가져오는 데이터 소스
data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status" # 필터 조건: 가용 영역의 상태
    values = ["opt-in-not-required"] # 기본적으로 사용 가능한 AZ만 포함
  }
}

# 로컬 변수 정의
locals {
  name                = "sesac-univ-cluster"
  region              = "ap-northeast-3" # AWS 리전 설정
  vpc_cidr            = "10.0.0.0/16" # VPC CIDR 블록
  azs                 = slice(data.aws_availability_zones.available.names, 0, 3) # 상위 3개 가용 영역 선택
  istio_chart_url     = "https://istio-release.storage.googleapis.com/charts" # Istio Helm 차트 저장소 URL
  istio_chart_version = "1.20.2" # Istio Helm 차트 버전

  # 모든 리소스에 공통으로 적용할 태그
  tags = {
    Blueprint  = local.name # 프로젝트 이름
    GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints" # 프로젝트 관련 GitHub 저장소 URL
  }
}
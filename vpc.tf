# VPC 및 서브넷 구성
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws" # Terraform 공식 VPC 모듈 사용
  version = "~> 5.0" # VPC 모듈 버전

  # VPC의 이름과 CIDR 설정
  name = local.name
  cidr = local.vpc_cidr

  # 가용 영역 및 서브넷 설정
  azs              = local.azs # 사용할 AWS 가용 영역
  private_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)] # 각 가용 영역에 프라이빗 서브넷 생성
  public_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)] # 각 가용 영역에 퍼블릭 서브넷 생성

  # NAT Gateway 설정
  enable_nat_gateway = true # NAT Gateway 활성화
  single_nat_gateway = true # 단일 NAT Gateway 사용

  # 서브넷에 태그 추가 (ELB와 연동)
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1 # 퍼블릭 서브넷은 외부 ELB와 연동
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1 # 프라이빗 서브넷은 내부 ELB와 연동
  }

  # 모든 리소스에 공통 태그 적용
  tags = local.tags
}
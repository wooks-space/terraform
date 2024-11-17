# Kubectl 구성 명령어를 출력하는 Output 블록
output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  # 출력 설명:
  # - EKS 클러스터에 접근하기 위해 kubectl 설정 필요.
  # - AWS CLI 명령어를 사용하여 Kubeconfig 파일 업데이트.

  value = "aws eks --region ${local.region} update-kubeconfig --name ${module.eks.cluster_name}"
  # 출력 값:
  # - AWS CLI 명령어 형식:
  #   aws eks --region <리전> update-kubeconfig --name <클러스터 이름>
  # - local.region: AWS 리전 정보
  # - module.eks.cluster_name: EKS 클러스터 이름
}
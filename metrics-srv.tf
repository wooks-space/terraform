# resource "helm_release" "metrics_server" {
#   name       = "metrics-server"
#   chart      = "metrics-server"
#   repository = "https://kubernetes-sigs.github.io/metrics-server"
#   namespace  = "kube-system"
#   version    = "3.12.0" # Metrics Server의 최신 안정 버전 확인 후 사용

#   create_namespace = false # kube-system 네임스페이스는 기본적으로 존재함

#   # 추가 설정: 클러스터 내부에서 작동하도록 수정
#   set {
#     name  = "args"
#     value = "--kubelet-insecure-tls --kubelet-preferred-address-types=InternalIP" # Kubelet 인증서 오류 무시, Kubelet 내부 IP 사용
#   }
# }

#################################################### 
# Helm_release에 문제가 있어 아래와 같이 설치하면 정상 동작
# kubectl get deployment metrics-server -n kube-system 
resource "kubernetes_deployment" "nginx" {
  metadata {
    name      = "nginx"
    namespace = "istio-gateway" # HTTPRoute와 동일하게 조정
    labels = {
      app = "nginx"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "nginx"
      }
    }

    template {
      metadata {
        labels = {
          app = "nginx"
        }
      }

      spec {
        container {
          name  = "nginx"
          image = "nginx:latest"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "nginx" {
  metadata {
    name      = "nginx" # HTTPRoute에서 참조할 이름
    namespace = "istio-gateway" # HTTPRoute와 동일하게 조정
    labels = {
      app = "nginx"
    }
  }

  spec {
    selector = {
      app = "nginx"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_manifest" "aws_gateway_class" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "GatewayClass"
    metadata = {
      name = "aws-lb-class" # GatewayClass 이름
    }
    spec = {
      controllerName = "ingress.k8s.aws/aws-load-balancer-controller" # 필수 필드
      description    = "AWS Load Balancer Controller GatewayClass"   # 선택적 필드
      parametersRef = {
        group = "core"
        kind     = "ConfigMap"
        name     = "aws-lb-controller-config"
        namespace = "kube-system" # AWS LBC 컨트롤러 설정이 저장된 네임스페이스
      }
    }
  }
}

resource "kubernetes_manifest" "sesac_gateway" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "Gateway"
    metadata = {
      name      = "sesac-gateway"
      namespace = "istio-gateway"
      annotations = {
        "service.beta.kubernetes.io/aws-load-balancer-scheme"         = "internet-facing"
        "service.beta.kubernetes.io/aws-load-balancer-attributes"     = "load_balancing.cross_zone.enabled=true"
        "service.beta.kubernetes.io/aws-load-balancer-ssl-cert": "arn:aws:acm:ap-northeast-3:311141554934:certificate/949cdc18-6727-4df9-8650-3504577454ee"
        "service.beta.kubernetes.io/aws-load-balancer-ssl-ports": 443
      }
    }
    spec = {
      gatewayClassName = "aws-lb-class" # GatewayClass와 이름 일치
      listeners = [
        {
          name     = "http"
          hostname = "*.sesac-univ.click"
          port     = 80
          protocol = "HTTP"
          allowedRoutes = {
            namespaces = {
              from = "Selector"
              selector = {
                matchLabels = {
                  "shared-gateway-access" = "true"
                }
              }
            }
          }
        },
        {
          name     = "https"
          hostname = "*.sesac-univ.click"
          port     = 443
          protocol = "HTTPS"
          tls = {
            mode = "Terminate" # TLS 종료 방식 설정
            certificateRefs = [
              {
                name = "aws-cert" # ACM 인증서를 참조
                kind = "Secret"
              }
            ]
          }
          allowedRoutes = {
            namespaces = {
              from = "Selector"
              selector = {
                matchLabels = {
                  "shared-gateway-access" = "true"
                }
              }
            }
          }
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "sesac_http_route" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"
    metadata = {
      name      = "sesac-univ-route"
      namespace = "istio-gateway" # Nginx와 동일한 네임스페이스로 조정
      labels = {
        "shared-gateway-access" = "true" # Gateway와 일치하는 라벨 추가
      }
    }
    spec = {
      parentRefs = [
        {
          name      = "sesac-gateway" # Gateway 이름과 일치
          namespace = "istio-gateway"
        }
      ]
      hostnames = [
        "localhost"
      ]
      rules = [
        {
          matches = [
            {
              path = {
                type  = "PathPrefix"
                value = "/"
              }
            }
          ]
          backendRefs = [
            {
              name = "nginx" # Nginx Service 이름과 일치
              port = 80
            }
          ]
        }
      ]
    }
  }
}

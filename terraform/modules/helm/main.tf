resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  chart      = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  version    = "3.12.2"
  namespace  = "kube-system"
  atomic     = true

  values = [file("${path.module}/values/metrics-server.yaml")]


  depends_on = [var.eks_nodes_group]
}


resource "helm_release" "cluster_autoscaler" {
  name       = "my-cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  version    = "9.46.6" 
  namespace  = "kube-system"

  set = [
    {
      name  = "rbac.serviceAccount.name"
      value = "cluster-autoscaler"
    },
    {
      name  = "autoDiscovery.clusterName"
      value = var.eks_cluster_name
    },
    {
      name  = "awsRegion"
      value = var.region
    }
  ]

  depends_on = [helm_release.metrics_server]
}


resource "helm_release" "aws_lbc" {
  name       = "my-aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.13.3" 
  namespace  = "kube-system"


  set = [
    {
      name  = "clusterName"
      value = var.eks_cluster_name
    },
    {
      name  = "serviceAccount.name"
      value = "aws-load-balancer-controller"
    },
    {
      name = "vpcId",
      value = var.vpc_id
    }
  ]

  depends_on = [helm_release.cluster_autoscaler]
}
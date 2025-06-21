output "cluster_id" {
    value = aws_eks_cluster.eks.id
}

output "cluster_arn" {
    value = aws_eks_cluster.eks.arn
}

output "cluster_name" {
    value = aws_eks_cluster.eks.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.eks.endpoint
}

output "cluster_ca_certificate" {
  value = aws_eks_cluster.eks.certificate_authority
}

output "eks_nodes_group" {
    value = aws_eks_node_group.eks_nodes_group
}
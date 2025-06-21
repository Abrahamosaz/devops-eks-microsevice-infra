###############################################
#EKS IAM ROLE
###############################################
resource "aws_iam_role" "eks" {
    name = "${var.env}-${var.name}-eks-cluster"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Sid    = ""
                Principal = {
                    Service = "eks.amazonaws.com"
                }
            },
        ]
    })

    tags = {
        tag-key = "${var.env}-EKS-POLICY"
    }
}

resource "aws_iam_role_policy_attachment" "eks_policy_attachment" {
  role       = aws_iam_role.eks.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}


###############################################
#EKS CLUSTER
###############################################
resource "aws_eks_cluster" "eks" {
  name = var.name

  access_config {
    authentication_mode = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  role_arn = aws_iam_role.eks.arn
  version  = var.local_version

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_policy_attachment,
  ]

  tags = {
    Name = "${var.env}-${var.name}"
  }
}


###############################################
#EKS IAM NODE ROLE
###############################################
resource "aws_iam_role" "eks_nodes" {
  name = "${var.env}-${var.name}-eks-nodes"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "${var.env}-EKS-POLICY-NODES"
  }
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_container_registry_readonly" {
  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}


###############################################
#EKS NODE GROUP
###############################################
resource "aws_eks_node_group" "eks_nodes_group" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = var.node_label
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = var.subnet_ids
  
  capacity_type = var.capacity_type
  instance_types = var.instance_types

  scaling_config {
    desired_size = var.scaling_config.desired_size
    max_size     = var.scaling_config.max_size
    min_size     = var.scaling_config.min_size
  }

  update_config {
    max_unavailable = 1
  }


  labels = {
    role = var.node_label
  }


  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_container_registry_readonly,
    aws_iam_role_policy_attachment.eks_cni_policy
  ]
  
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

}
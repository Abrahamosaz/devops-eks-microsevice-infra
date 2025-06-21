##########################################################
# ADDONS
##########################################################
resource "aws_eks_addon" "addons" {
  for_each = var.addon_names
  cluster_name  = var.eks_cluster_name
  addon_name    = each.key
  addon_version = each.value
}


##########################################################
# IAM ROLES
##########################################################
resource "aws_iam_role" "cluster_autoscaler" {
  name = "${var.env}-${var.eks_cluster_name}-cluster-autoscaler"


  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
      },
    ]
  })
}


resource "aws_iam_role" "ebs_cli_driver" {
  name = "${var.env}-${var.eks_cluster_name}-ebs-cli-driver"


  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
      },
    ]
  })
}


##########################################################
# IAM POLICIES
##########################################################
resource "aws_iam_policy" "cluster_autoscaler" {
  name = "AmazonEKSClusterAdminPolicy"
 
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup"
        ],
        "Resource" : "*",
        "Condition" : {
          "StringEquals" : {
            "aws:ResourceTag/k8s.io/cluster-autoscaler/enabled" : "true",
            "aws:ResourceTag/k8s.io/cluster-autoscaler/${var.eks_cluster_name}" : "owned"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeScalingActivities",
          "autoscaling:DescribeTags",
          "ec2:DescribeImages",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:GetInstanceTypesFromInstanceRequirements",
          "eks:DescribeNodegroup"
        ],
        "Resource" : "*"
      }
    ]
  })
}


resource "aws_iam_policy" "ebs_cli_driver_encryption" {
  name = "${var.eks_cluster_name}-ebs-cli-driver-encryption"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "kms:Decrypt",
          "kms:GenerateDataKeyWithoutPlaintext",
          "kms:CreateGrant"
        ],
        "Resource" : "*",
      },
    ]
  })
}



##########################################################
# IAM POLICIES ATTACHMENTS
##########################################################
resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {
  role       = aws_iam_role.cluster_autoscaler.name
  policy_arn = aws_iam_policy.cluster_autoscaler.arn
}


resource "aws_iam_role_policy_attachment" "ebs_cli_driver" {
  role       = aws_iam_role.ebs_cli_driver.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}


resource "aws_iam_role_policy_attachment" "ebs_cli_driver_encryption" {
  role       = aws_iam_role.ebs_cli_driver.name
  policy_arn = aws_iam_policy.ebs_cli_driver_encryption.arn
}



##########################################################
# POD IDENTITY ASSOCIATIONS
##########################################################
resource "aws_eks_pod_identity_association" "cluster_autoscaler" {
  cluster_name    = var.eks_cluster_name
  namespace       = "kube-system"
  service_account = "cluster-autoscaler"
  role_arn        = aws_iam_role.cluster_autoscaler.arn
}


resource "aws_eks_pod_identity_association" "ebs_cli_driver" {
  cluster_name    = var.eks_cluster_name
  namespace       = "kube-system"
  service_account = "ebs-csi-controller-sa"
  role_arn        = aws_iam_role.ebs_cli_driver.arn
}
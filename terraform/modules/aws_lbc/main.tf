data "aws_iam_policy_document" "aws_lbc" {
  statement {

    effect = "Allow"

    principals {
        type = "Service"
        identifiers = ["pods.eks.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }

}


resource "aws_iam_role" "aws_lbc" {
  name = "${var.env}-${var.eks_cluster_name}-aws-lbc"
  assume_role_policy = data.aws_iam_policy_document.aws_lbc.json
}


resource "aws_iam_policy" "aws_lbc" {
  name = "AWSLoadBalancerControllerPolicy"
  policy = file("${path.module}/policies/aws-lbc.json")
}


resource "aws_iam_role_policy_attachment" "aws_lbc" {
  role       = aws_iam_role.aws_lbc.name
  policy_arn = aws_iam_policy.aws_lbc.arn
}


resource "aws_eks_pod_identity_association" "aws_lbc" {
  cluster_name    = var.eks_cluster_name
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"
  role_arn        = aws_iam_role.aws_lbc.arn
}
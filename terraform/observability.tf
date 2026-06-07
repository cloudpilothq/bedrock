resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = module.eks.eks_managed_node_groups["bedrock_nodes"].iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_eks_addon" "cloudwatch_observability" {
  cluster_name                = module.eks.cluster_name
  addon_name                  = "amazon-cloudwatch-observability"
  resolve_conflicts_on_update = "PRESERVE"
  depends_on                  = [module.eks, aws_iam_role_policy_attachment.cloudwatch_agent]
}

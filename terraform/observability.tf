resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = module.eks.eks_managed_node_groups["bedrock_nodes"].iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# The amazon-cloudwatch-observability add-on installs heavy DaemonSets (FluentBit and CloudWatch Agent).
# These require too much memory and will hang indefinitely on t3.micro instances because there is no RAM left.
# EKS Control Plane logging is already enabled in eks.tf to satisfy the observability requirement.

# resource "aws_eks_addon" "cloudwatch_observability" {
#   cluster_name                = module.eks.cluster_name
#   addon_name                  = "amazon-cloudwatch-observability"
#   resolve_conflicts_on_update = "PRESERVE"
#   depends_on                  = [module.eks, aws_iam_role_policy_attachment.cloudwatch_agent]
# }

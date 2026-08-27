variable "aws_region" {
  description = "AWS region for the bastion host and EKS cluster"
  type        = string
  default     = "eu-north-1"
}

variable "clustername" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "micro-cluster"
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.30"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnet_cidr_blocks" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnet_cidr_blocks" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "endpoint_private_access" {
  description = "Whether the Amazon EKS private API server endpoint is enabled"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Whether the Amazon EKS public API server endpoint is enabled"
  type        = bool
  default     = false
}

variable "endpoint_public_access_cidrs" {
  description = "CIDRs for public access to the EKS cluster endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "node_group_config" {
  description = "Configuration for the EKS managed node group"
  type = object({
    instance_types = list(string)
    ami_type       = string
    min_size       = number
    max_size       = number
    desired_size   = number
  })
  default = {
    instance_types = ["t3.medium"]
    ami_type       = "AL2_x86_64"
    min_size       = 1
    max_size       = 5
    desired_size   = 2
  }
}

variable "bastion_allowed_cidr_blocks" {
  description = "Allowed CIDR blocks for accessing the bastion host"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "bastion_instance_type" {
  description = "Instance type for the bastion host"
  type        = string
  default     = "t3.micro"
}
variable "key_pair_name" {
  description = "Name of the AWS key pair for bastion host"
  type        = string
}

variable "bastion_allowed_cidrs" {
  description = "CIDR blocks allowed to access bastion host"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
variable "ssh_private_key_path" {
  description = "Path to SSH private key"
  type        = string
  default     = "~/.ssh/id_rsa"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "EKS-Cluster"
    ManagedBy   = "Terraform"
  }
}
variable "velero_environment" {
  description = "Environment name used for the Velero backup bucket"
  type        = string
  default     = "production"
}

# ---------------------------------------------------------------------------
# Petclinic DB secret variables
# These are written to AWS Secrets Manager by Terraform and read by ESO.
# Override petclinic_db_password via env var: TF_VAR_petclinic_db_password
# ---------------------------------------------------------------------------
variable "petclinic_db_username" {
  description = "PostgreSQL username for petclinic"
  type        = string
  default     = "petclinic"
}

variable "petclinic_db_password" {
  description = "PostgreSQL password for petclinic (sensitive — override via TF_VAR or CI secret)"
  type        = string
  sensitive   = true
  default     = "changeme"
}

variable "petclinic_db_name" {
  description = "PostgreSQL database name"
  type        = string
  default     = "petclinic"
}

variable "petclinic_db_host" {
  description = "Kubernetes service hostname for PostgreSQL (must match Helm chart service name)"
  type        = string
  default     = "petclinic-postgresql"
}

variable "petclinic_db_port" {
  description = "PostgreSQL service port"
  type        = number
  default     = 5432
}

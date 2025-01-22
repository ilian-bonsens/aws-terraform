variable "aws_region" {
  description = "Région AWS pour le déploiement"
  type        = string
  default     = "eu-west-3"
}

variable "instance_count" {
  description = "Nombre d'instances EC2 à créer"
  type        = number
  default     = 2
}

variable "instance_type" {
  description = "Type d'instance EC2"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "ID de l'AMI Amazon Linux 2023"
  type        = string
}

variable "volume_size" {
  description = "Taille du volume en GB"
  type        = number
  default     = 8
}

variable "volume_type" {
  description = "Type de volume EBS"
  type        = string
  default     = "gp2"
}

variable "key_name" {
  description = "Nom de la paire de clés SSH"
  type        = string
}

variable "security_group_name" {
  description = "Nom du groupe de sécurité"
  type        = string
  default     = "security-group-vps"
}

variable "webpage_content" {
  description = "Contenu HTML de la page web par défaut"
  type        = string
  default     = "<html><head><title>Bienvenue sur mon serveur web</title></head><body><h1>Serveur Web Apache Déployé avec Succès sur Amazon Linux 2023 !</h1></body></html>"
}

variable "ssl_certificate_arn" {
  description = "ARN du certificat SSL importé dans ACM"
  type        = string
}
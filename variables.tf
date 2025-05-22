variable "key_name" {
  description = "chave-dev"
  type        = string
}

variable "public_key_path" {
  description = "Caminho para a chave pública"
  type        = string
}

variable "my_ip" {
  description = "meu ip"
  type        = string
}

variable "mongo_user" {
  description = "Usuário root do MongoDB"
  type        = string
  default     = "admin"
}

variable "mongo_pass" {
  description = "Senha do MongoDB"
  type        = string
}

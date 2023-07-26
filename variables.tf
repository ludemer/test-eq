variable "gcp_project" {
  type        = string
  default     = "test-eq-393918"
  description = "Especifique el ID del Proyecto Google donde se crearán los recursos"
}

variable "gcp_region" {
  type        = string
  default     = "us-central1"
  description = "Nombre de la región de Google donde se crearán los recursos."
}

variable "gcp_zone" {
  type        = string
  default     = "us-central1-a"
  description = "Nombre de la región de Google donde se crearán los recursos."
}

variable "path" {
  default     = "/mnt/c/Users/ludem/OneDrive/Documentos/test/test-eq"
  description = "path json para la conexion gcp terra"
}

variable "name_k8s" {
  type        = string
  default     = "test-eq"
  description = "Nombre de cluster."
}

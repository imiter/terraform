variable "mywebserver_security_group" {
  default = "allow_80"
  type = string
  description = "The name of the security group for mywebserver"
}

variable "server_port" {
    default = "80"
    type = number
    description = "web server port number"
}
terraform {
  required_version = ">= 1.0.0, < 2.0.0"
}

variable "names" {
    type = list(string)
    default = ["neo","trinity","morpheus"]
}

output "upper_names" {
    value = [for name in var.names : upper(name)]
}

output "short_upper_names" {
    value = [for name in var.names : upper(name) if length(name) < 5]
}


variable "hero_thousand_faces" {
  type = map(string)
  default = {
     neo = "value1"
     trinity = "value2"
     morpheus = "value3"
  }
}

output "bios" {
    value = [for name, role in var.hero_thousand_faces: "${name} is the ${role}"]
}
output "upper_roles" {
    value = {for name, role in var.hero_thousand_faces : upper(name) => upper(role)}
}
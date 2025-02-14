
output "address" {
    value = aws_db_instance.myDB.address
    description = "dbinstance db address"
}

output "port" {
    value = aws_db_instance.myDB.port
    description = "dbinstance db port"
}

output "username" {
    value = aws_db_instance.myDB.username
    sensitive = true
    description = "dbinstance db username"
}


output "password" {
    value = aws_db_instance.myDB.password
    sensitive = true
    description = "dbinstance db password"
}

output "dbname" {
    value = aws_db_instance.myDB.db_name
    description = "dbinstance db name"
}

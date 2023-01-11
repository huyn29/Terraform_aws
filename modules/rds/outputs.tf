output "name" {
    value = aws_db_instance.database.db_name
}
output "password" {
    value = aws_db_instance.database.password
}
output "address" {
    value = aws_db_instance.database.address
}
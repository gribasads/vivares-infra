output "ec2_public_ip" {
  value = aws_instance.mongo_ec2.public_ip
}

output "mongo_connection_string" {
  value = "mongodb://${var.mongo_user}:${var.mongo_pass}@${aws_instance.mongo_ec2.public_ip}:27017"
}

provider "aws" {
  region = "us-east-1"
}

# Bucket para arquivos do sistema
resource "aws_s3_bucket" "system_files" {
  bucket = "vivares-mongo-system-files"
}

# Configuração de acesso público para o bucket de arquivos
resource "aws_s3_bucket_public_access_block" "system_files" {
  bucket = aws_s3_bucket.system_files.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Habilita versionamento para o bucket de arquivos
resource "aws_s3_bucket_versioning" "system_files" {
  bucket = aws_s3_bucket.system_files.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Habilita criptografia para o bucket de arquivos
resource "aws_s3_bucket_server_side_encryption_configuration" "system_files" {
  bucket = aws_s3_bucket.system_files.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Configuração de CORS para o bucket de arquivos do sistema
resource "aws_s3_bucket_cors_configuration" "system_files" {
  bucket = aws_s3_bucket.system_files.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST", "DELETE"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

# Política de bucket para permitir acesso público apenas para leitura
resource "aws_s3_bucket_policy" "system_files" {
  bucket = aws_s3_bucket.system_files.id
  depends_on = [aws_s3_bucket_public_access_block.system_files]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.system_files.arn}/*"
      }
    ]
  })
}

resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

resource "aws_security_group" "mongo_sg" {
  name = "mongo-sg"

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    description = "MongoDB access"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "mongo_ec2" {
  ami                    = "ami-0c7217cdde317cfec" # Ubuntu 22.04 LTS (us-east-1)
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.deployer.key_name
  security_groups        = [aws_security_group.mongo_sg.name]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y docker.io
              systemctl enable docker
              systemctl start docker

              docker run -d \\
                --name mongo \\
                -p 27017:27017 \\
                -v /home/ubuntu/mongo-data:/data/db \\
                -e MONGO_INITDB_ROOT_USERNAME=${var.mongo_user} \\
                -e MONGO_INITDB_ROOT_PASSWORD=${var.mongo_pass} \\
                mongo:7
              EOF

  tags = {
    Name = "MongoDB-Dev"
  }
}

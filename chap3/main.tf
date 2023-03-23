
resource "aws_instance" "apache2_server" {
  ami = "ami-0fd2c44049dd805b8"
  instance_type = "t2.micro"
  user_data = <<EOF
         #!/bin/bash
         sudo apt update -y
         sudo apt install apache2 -y
     EOF
      
}
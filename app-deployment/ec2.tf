resource "aws_instance" "server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name  

  vpc_security_group_ids = [aws_security_group.webSg.id]
  subnet_id              = aws_subnet.sub1.id

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("/home/vishal/.ssh/ec2")  
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "/home/vishal/git/application-deployment-in-aws-terraform-provisioner/flask-app/app.py"
    destination = "/home/ubuntu/app.py"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Hello from the remote instance'",

      # Update and install Python, Pip, and venv properly
      "sudo apt update -y",
      "sudo apt install -y python3 python3-pip python3-venv",

      # Ensure Python3 is installed and can be found
      "python3 --version",

      # Create virtual environment and activate it
      "python3 -m venv /home/ubuntu/venv",
      "source /home/ubuntu/venv/bin/activate",

      # Upgrade pip and install Flask inside venv
      "pip install --upgrade pip",
      "pip install flask",

      # Run Flask app in the background
      "cd /home/ubuntu",
      "nohup python3 app.py > app.log 2>&1 &"
    ]
  }
}

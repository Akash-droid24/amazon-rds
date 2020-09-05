provider "kubernetes" {}



resource "kubernetes_deployment" "wordpress" {
  metadata {
    name = "my-word"
    labels = {
      test = "myword"
    }
  }


  spec {
    replicas = 2


    selector {
      match_labels = {
        test = "myword"
 }
    }


    template {
      metadata {
        labels = {
          test = "myword"
        }
      }


      spec {
        container {
          image = "wordpress"
          name  = "myword"
        }
      }
    }
  }
}

resource "kubernetes_service" "wordlb" {
  metadata {
    name = "wordlb"
  }
  spec {
    selector = {
      test = "${kubernetes_deployment.wordpress.metadata.0.labels.test}"
    }
    port {
      port = 80
      target_port = 80
    }


    type = "NodePort"
  }
}

resource "null_resource" "wpurl" {
 provisioner "local-exec" {
  command = "minikube service list"
 }
 
depends_on = [ kubernetes_service.wordlb ]

}


provider "aws" {
  region     = "ap-south-1"
  profile    = "mycred"
}
resource "aws_security_group" "allow_sql" {


  name        = "allow_sql"
  description = "Allow sql inbound traffic"
  vpc_id      = "vpc-cd879aa5"


  ingress {
    description = "sql from VPC"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "allow_sql"
  }
}


resource "aws_db_instance" "mysql" {
  identifier = "database-sql"
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7.30"
  instance_class       = "db.t2.micro"
  name                 = "mydb"
  username             = "atfreak"
  password             = "atfreak123"
  parameter_group_name = "default.mysql5.7"
  iam_database_authentication_enabled = true
  publicly_accessible = true
  skip_final_snapshot = true
  vpc_security_group_ids = [ "${aws_security_group.allow_sql.id}"]
}
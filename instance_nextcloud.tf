data "template_file" "nextcloud_installer"{ 
    template =  file("./nextcloud/install.sh.tp")
    vars = { 
      dbHost = aws_network_interface.db_local.private_ip 
      dbName = var.database_name
      dbUser = var.database_user
      dbPass = var.database_pass
      nxtUser = var.admin_user
      nxtPass = var.admin_pass
      
      REGION = var.region
      PUBLIC_IP = aws_eip.nextcloud.public_ip

      BUCKET_NAME = aws_s3_bucket.s3.bucket
      BUCKET_DOMAIN = aws_s3_bucket.s3.bucket_domain_name
      S3_KEY    = aws_iam_access_key.s3.id
      S3_SECRET = aws_iam_access_key.s3.secret
    }
}

resource "aws_network_interface" "server_public" {
  subnet_id       = aws_subnet.public.id
  security_groups = [aws_security_group.app2gw.id]

  tags = {
    Name = "nextcloud_nic_public"
  }
}
resource "aws_network_interface" "server_db" {
  subnet_id       = aws_subnet.local.id
  security_groups = [aws_security_group.app2db.id]

  tags = {
    Name = "nextcloud_nic_local"
  }
}

resource "aws_instance" "nexcloud" {
    ami                  = var.ami
    availability_zone    = var.availability_zone
    instance_type        = var.instance_type
    iam_instance_profile = aws_iam_instance_profile.app.name
    # user_data_base64     = data.cloudinit_config.app.rendered 

    tags = {
      "Name" = "nextcloud_instance_server"
    }

    network_interface {
      network_interface_id = aws_network_interface.server_public.id
      device_index         = 0
    }
    network_interface {
      network_interface_id = aws_network_interface.server_db.id
      device_index         = 1
    }

    depends_on = [
        aws_instance.db,
        aws_s3_bucket.s3,
    ]

    ## Setting up Instance
    user_data = data.template_file.nextcloud_installer.rendered
}
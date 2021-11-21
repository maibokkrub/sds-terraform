
data "template_file" "db_init"{ 
    template =  file("./db/install.sh.tp")
    vars = { 
      database_name = var.database_name
      database_user = var.database_user
      database_pass = var.database_pass
    }
}

resource "aws_network_interface" "db_NAT" {
  subnet_id       = aws_subnet.private.id
  security_groups = [aws_security_group.db2ngw.id]

  tags = {
    Name = "nextcloud_nic_db_nat"
  }
}
resource "aws_network_interface" "db_local" {
  subnet_id       = aws_subnet.local.id
  security_groups = [aws_security_group.db2app.id]

  tags = {
    Name = "nextcloud_nic_db_local"
  }
}

resource "aws_instance" "db" {
    ami                  = var.ami
    availability_zone    = var.availability_zone
    instance_type        = var.instance_type
    iam_instance_profile = aws_iam_instance_profile.db.name
    # user_data_base64     = data.cloudinit_config.db.rendered

    tags = {
      Name = "nextcloud_instance_db"
    }

    network_interface {
      network_interface_id = aws_network_interface.db_NAT.id
      device_index         = 0
    }
    network_interface {
      network_interface_id = aws_network_interface.db_local.id
      device_index         = 1
    }

    user_data = data.template_file.db_init.rendered
}
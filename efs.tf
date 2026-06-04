########################################
# EFS File System (Muli-Zone for High Availability)
########################################

resource "aws_efs_file_system" "neuefische-efs" {
  encrypted = true

  performance_mode = "generalPurpose"
  throughput_mode  = "bursting" # for cost saving in testing 

  # No backup policy -> for cost saving in testing
  # No lifecycle policy -> for cost saving in testing

  tags = {
    Name = "neuefische-efs"
  }
}

########################################
# Mount Target (in each private subnet)
########################################

resource "aws_efs_mount_target" "neuefische_efs_mt_1" {
  file_system_id = aws_efs_file_system.neuefische-efs.id

  # Must be in the same Availability Zone as the One Zone EFS (us-west-2a)
  subnet_id = aws_subnet.neuefische-private-1.id

  # Only inbound NFS from Webserver SG
  security_groups = [aws_security_group.neuefische_sg_efs.id]

}

resource "aws_efs_mount_target" "neuefische_efs_mt_2" {
  file_system_id = aws_efs_file_system.neuefische-efs.id

  # Must be in the same Availability Zone as the One Zone EFS (us-west-2a)
  subnet_id = aws_subnet.neuefische-private-2.id

  # Only inbound NFS from Webserver SG
  security_groups = [aws_security_group.neuefische_sg_efs.id]
}

########################################
# Access Point for /wp-content
########################################

resource "aws_efs_access_point" "neuefische_efs_ap" {
  file_system_id = aws_efs_file_system.neuefische-efs.id

  # Root directory for WordPress content
  root_directory {
    path = "/wp-content"

    creation_info {
      owner_uid   = 48 # Apache user
      owner_gid   = 48 # Apache group
      permissions = "0755"
    }
  }

  # All EFS operations run as Apache (UID/GID 48)
  posix_user {
    uid = 48
    gid = 48
  }

  tags = {
    Name = "neuefische_efs_ap"
  }
}

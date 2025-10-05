# import {
#   to = aws_vpc.vpc_789
#   id = "vpc-0b3629292bff4ffc6"
# }

# # --- Subnets ---
# import {
#   to = aws_subnet.org7_subnet
#   id = "subnet-093dd43a877d2f5d1"
# }

# import {
#   to = aws_subnet.org8_subnet
#   id = "subnet-09c3a22f442ab43e9"
# }

# import {
#   to = aws_subnet.org9_subnet
#   id = "subnet-00fecba6605905ce0"
# }

# # --- Instances ---
# import {
#   to = aws_instance.org7
#   id = "i-0856a7be43a86be38"
# }

# import {
#   to = aws_instance.org8
#   id = "i-0955cc36b0b8fdf85"
# }

# import {
#   to = aws_instance.org9
#   id = "i-02b1cc16b5e4eca7b"
# }

# # --- Networking ---
# import {
#   to = aws_security_group.swarm_group
#   id = "sg-03afad46a6d5ffa62"
# }

# import {
#   to = aws_route_table.VPC789-rt-VPC12_VPC456
#   id = "rtb-099fcd3979e08303e"
# }

# import {
#   to = aws_internet_gateway.igw
#   id = "igw-0e71b1b401a999474"
# }

# # --- Peering Connections ---
# # This is the existing peering connection to VPC-123
# import {
#   to = aws_vpc_peering_connection.peering_with_vpc123
#   id = "pcx-04bb64cdbe9429a76"
# }

# # This is the new peering connection, likely to VPC-456
# import {
#   to = aws_vpc_peering_connection.peering_with_vpc456
#   id = "pcx-0aafb24de9cc9b8eb"
# }

# # --- Peering Connection Accepters ---
# import {
#   to = aws_vpc_peering_connection_accepter.peering_vpc123
#   id = "pcx-04bb64cdbe9429a76"
# }

# import {
#   to = aws_vpc_peering_connection_accepter.peering_vpc456
#   id = "pcx-0aafb24de9cc9b8eb"
# }

# # --- Network ACL ---
# import {
#   to = aws_default_network_acl.default_nacl
#   id = "acl-0c39fc2876040ef03"
# }

# "vpc-0b3629292bff4ffc6"
resource "aws_vpc" "vpc_789" {
  cidr_block           = "10.0.3.0/24"
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name = "VPC789-subnet-public1-us-west-2a"
  }
}

# "igw-0e71b1b401a999474"
resource "aws_internet_gateway" "igw" {
  vpc_id = "vpc-0b3629292bff4ffc6"
}

# "subnet-093dd43a877d2f5d1"
resource "aws_subnet" "org7_subnet" {
  availability_zone = "us-west-2a"
  cidr_block        = "10.0.3.0/28"
  vpc_id            = "vpc-0b3629292bff4ffc6"
  
  tags = {
    Name = "VPC123-VPC789"
  }
}

# "subnet-09c3a22f442ab43e9"
resource "aws_subnet" "org8_subnet" {
  availability_zone = "us-west-2b"
  cidr_block        = "10.0.3.16/28"
  vpc_id            = "vpc-0b3629292bff4ffc6"
  
  tags = {
    Name = "VPC789-subnet-public2-us-west-2b"
  }
}

# "subnet-00fecba6605905ce0"
resource "aws_subnet" "org9_subnet" {
  availability_zone = "us-west-2c"
  cidr_block        = "10.0.3.32/28"
  vpc_id            = "vpc-0b3629292bff4ffc6"
  
  tags = {
    Name = "VPC789-subnet-public3-us-west-2c"
  }
}

# "sg-03afad46a6d5ffa62"
resource "aws_security_group" "swarm_group" {
  description = "All traffic for test"
  vpc_id      = "vpc-0b3629292bff4ffc6"
  
  ingress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = ""
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "-1"
    security_groups  = []
    self             = false
    to_port          = 0
  }]
  
  egress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = ""
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "-1"
    security_groups  = []
    self             = false
    to_port          = 0
  }]
  
  name = "BBVS_all"
  
  tags = {}
}

# "rtb-099fcd3979e08303e"
resource "aws_route_table" "VPC789-rt-VPC12_VPC456" {
  vpc_id = "vpc-0b3629292bff4ffc6"
  
  route = [{
    carrier_gateway_id         = null
    cidr_block                 = "0.0.0.0/0"
    core_network_arn           = null
    destination_prefix_list_id = null
    egress_only_gateway_id     = null
    gateway_id                 = "igw-0e71b1b401a999474"
    ipv6_cidr_block            = null
    local_gateway_id           = null
    nat_gateway_id             = null
    network_interface_id       = null
    transit_gateway_id         = null
    vpc_endpoint_id            = null
    vpc_peering_connection_id  = null
    }, {
    carrier_gateway_id         = null
    cidr_block                 = "10.0.1.0/24"
    core_network_arn           = null
    destination_prefix_list_id = null
    egress_only_gateway_id     = null
    gateway_id                 = null
    ipv6_cidr_block            = null
    local_gateway_id           = null
    nat_gateway_id             = null
    network_interface_id       = null
    transit_gateway_id         = null
    vpc_endpoint_id            = null
    vpc_peering_connection_id  = "pcx-04bb64cdbe9429a76"
    }, {
    carrier_gateway_id         = null
    cidr_block                 = "10.0.2.0/24"
    core_network_arn           = null
    destination_prefix_list_id = null
    egress_only_gateway_id     = null
    gateway_id                 = null
    ipv6_cidr_block            = null
    local_gateway_id           = null
    nat_gateway_id             = null
    network_interface_id       = null
    transit_gateway_id         = null
    vpc_endpoint_id            = null
    vpc_peering_connection_id  = "pcx-0aafb24de9cc9b8eb"
  }]
  
  tags = {
    Name = "VPC789-rt-VPC123&VPC456"
  }
}

# "pcx-04bb64cdbe9429a76"
resource "aws_vpc_peering_connection" "peering_with_vpc123" {
  peer_owner_id = "880110983955"
  peer_region   = "us-east-1"
  peer_vpc_id   = "vpc-0fc1f416a99367802"
  vpc_id        = "vpc-0b3629292bff4ffc6"
  
  accepter {
    allow_remote_vpc_dns_resolution = false
  }
  
  requester {
    allow_remote_vpc_dns_resolution = false
  }
  
  tags = {
    Name = "VPC123-VPC789"
  }
}

# "pcx-0aafb24de9cc9b8eb"
resource "aws_vpc_peering_connection" "peering_with_vpc456" {
  peer_owner_id = "880110983955"
  peer_region   = "us-east-2"
  peer_vpc_id   = "vpc-07b0b52d2ba27ab4f"
  vpc_id        = "vpc-0b3629292bff4ffc6"
  
  accepter {
    allow_remote_vpc_dns_resolution = false
  }
  
  requester {
    allow_remote_vpc_dns_resolution = false
  }
  
  tags = {
    Name = "VPC456-VPC789"
  }
}

# "pcx-04bb64cdbe9429a76"
resource "aws_vpc_peering_connection_accepter" "peering_vpc123" {
  vpc_peering_connection_id = "pcx-04bb64cdbe9429a76"
  
  accepter {
    allow_remote_vpc_dns_resolution = false
  }
  
  requester {
    allow_remote_vpc_dns_resolution = false
  }
  
  tags = {
    Name = "VPC123-VPC789"
  }
}

# "pcx-0aafb24de9cc9b8eb"
resource "aws_vpc_peering_connection_accepter" "peering_vpc456" {
  vpc_peering_connection_id = "pcx-0aafb24de9cc9b8eb"
  
  accepter {
    allow_remote_vpc_dns_resolution = false
  }
  
  requester {
    allow_remote_vpc_dns_resolution = false
  }
  
  tags = {
    Name = "VPC456-VPC789"
  }
}

# "acl-0c39fc2876040ef03"
resource "aws_default_network_acl" "default_nacl" {
  default_network_acl_id = "acl-0c39fc2876040ef03"
  subnet_ids             = ["subnet-00fecba6605905ce0", "subnet-093dd43a877d2f5d1", "subnet-09c3a22f442ab43e9"]
  
  egress {
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    icmp_code  = 0
    icmp_type  = 0
    protocol   = "-1"
    rule_no    = 100
    to_port    = 0
  }
  
  ingress {
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    icmp_code  = 0
    icmp_type  = 0
    protocol   = "-1"
    rule_no    = 100
    to_port    = 0
  }
  
  tags = {}
}

# "i-0856a7be43a86be38"
resource "aws_instance" "org7" {
  ami                    = "ami-075686beab831bb7f"
  instance_type          = "c7a.xlarge"
  key_name               = "BBVS_Oregon"
  private_ip             = "10.0.3.36"
  subnet_id              = "subnet-00fecba6605905ce0"
  vpc_security_group_ids = ["sg-03afad46a6d5ffa62"]
  
  cpu_options {
    core_count       = 4
    threads_per_core = 1
  }
  
  root_block_device {
    delete_on_termination = true
    volume_size           = 40
    volume_type           = "gp3"
    iops                  = 3000
    throughput            = 125
  }
  
  tags = {
    Name = "Org9"
  }
}

# "i-0955cc36b0b8fdf85"
resource "aws_instance" "org8" {
  ami                    = "ami-075686beab831bb7f"
  instance_type          = "c7a.xlarge"
  key_name               = "BBVS_Oregon"
  private_ip             = "10.0.3.6"
  subnet_id              = "subnet-093dd43a877d2f5d1"
  vpc_security_group_ids = ["sg-03afad46a6d5ffa62"]
  
  cpu_options {
    core_count       = 4
    threads_per_core = 1
  }
  
  root_block_device {
    delete_on_termination = true
    volume_size           = 40
    volume_type           = "gp3"
    iops                  = 3000
    throughput            = 125
  }
  
  tags = {
    Name = "Org7"
  }
}

# "i-02b1cc16b5e4eca7b"
resource "aws_instance" "org9" {
  ami                    = "ami-075686beab831bb7f"
  instance_type          = "c7a.xlarge"
  key_name               = "BBVS_Oregon"
  private_ip             = "10.0.3.23"
  subnet_id              = "subnet-09c3a22f442ab43e9"
  vpc_security_group_ids = ["sg-03afad46a6d5ffa62"]
  
  cpu_options {
    core_count       = 4
    threads_per_core = 1
  }
  
  root_block_device {
    delete_on_termination = true
    volume_size           = 40
    volume_type           = "gp3"
    iops                  = 3000
    throughput            = 125
  }
  
  tags = {
    Name = "Org8"
  }
}
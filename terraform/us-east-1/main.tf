# import {
#   to = aws_vpc.peer123_vpc
#   id = "vpc-0fc1f416a99367802"
# }

# import {
#   to = aws_subnet.public_1a
#   id = "subnet-09c877aeb82eed5c0"
# }

# import {
#   to = aws_subnet.public_1b
#   id = "subnet-080f6702562499c23"
# }

# import {
#   to = aws_subnet.public_1c
#   id = "subnet-05f4a1227e3f212f8"
# }

# import {
#   to = aws_instance.org1
#   id = "i-086fa90ecdb430d79"
# }

# import {
#   to = aws_instance.org2
#   id = "i-0e49c4a3d94ba6cf7"
# }

# import {
#   to = aws_instance.org3
#   id = "i-0f6324fa5021008b3"
# }

# import {
#   to = aws_security_group.Swarm_Group
#   id = "sg-0730fa3094d2251ac"
# }

# import {
#   to = aws_route_table.rt_vpc123_vpc456_vpc789
#   id = "rtb-0eb0efd3583dbd6ad"
# }

# import {
#   to = aws_internet_gateway.peer123_igw
#   id = "igw-03eebd7425eb277e2"
# }

# import {
#   to = aws_vpc_peering_connection.vpc123_to_vpc456
#   id = "pcx-068c3c652492096ac"
# }

# import {
#   to = aws_vpc_peering_connection.vpc789_to_vpc123
#   id = "pcx-04bb64cdbe9429a76"
# }

# import {
#   to = aws_vpc_peering_connection_accepter.VPC123-VPC789
#   id = "pcx-04bb64cdbe9429a76"
# }

# import {
#   to = aws_vpc_peering_connection_accepter.VPC123-VPC456
#   id = "pcx-068c3c652492096ac"
# }

# import {
#   to = aws_default_network_acl.default_nacl
#   id = "acl-0081b3fe550e7b311"
# }

# import {
#   to = aws_eip.org1_eip
#   id = "eipalloc-021c8ec29904b440a"
# }

# "igw-03eebd7425eb277e2"
resource "aws_internet_gateway" "peer123_igw" {
  region = "us-east-1"
  tags = {
    Name = "Peer123-igw"
  }
  tags_all = {
    Name = "Peer123-igw"
  }
  vpc_id = "vpc-0fc1f416a99367802"
}

# "pcx-068c3c652492096ac"
resource "aws_vpc_peering_connection" "vpc123_to_vpc456" {
  auto_accept   = null
  peer_owner_id = "880110983955"
  peer_region   = "us-east-2"
  peer_vpc_id   = "vpc-07b0b52d2ba27ab4f"
  region        = "us-east-1"
  tags = {
    Name = "VPC123-VPC456"
  }
  tags_all = {
    Name = "VPC123-VPC456"
  }
  vpc_id = "vpc-0fc1f416a99367802"
  accepter {
    allow_remote_vpc_dns_resolution = false
  }
  requester {
    allow_remote_vpc_dns_resolution = false
  }
}

# "pcx-068c3c652492096ac"
resource "aws_vpc_peering_connection_accepter" "VPC123-VPC456" {
  auto_accept = null
  region      = "us-east-1"
  tags = {
    Name = "VPC123-VPC456"
  }
  tags_all = {
    Name = "VPC123-VPC456"
  }
  vpc_peering_connection_id = "pcx-068c3c652492096ac"
  accepter {
    allow_remote_vpc_dns_resolution = false
  }
  requester {
    allow_remote_vpc_dns_resolution = false
  }
}


resource "aws_route_table" "rt_vpc123_vpc456_vpc789" {
  propagating_vgws = []
  region           = "us-east-1"
  route = [{
    carrier_gateway_id         = null
    cidr_block                 = "0.0.0.0/0"
    core_network_arn           = null
    destination_prefix_list_id = null
    egress_only_gateway_id     = null
    gateway_id                 = "igw-03eebd7425eb277e2"
    ipv6_cidr_block            = null
    local_gateway_id           = null
    nat_gateway_id             = null
    network_interface_id       = null
    transit_gateway_id         = null
    vpc_endpoint_id            = null
    vpc_peering_connection_id  = null
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
    vpc_peering_connection_id  = "pcx-068c3c652492096ac"
    }, {
    carrier_gateway_id         = null
    cidr_block                 = "10.0.3.0/24"
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
  }]
  tags = {
    Name = "VPC123-rt-VPC456&VPC789"
  }
  tags_all = {
    Name = "VPC123-rt-VPC456&VPC789"
  }
  vpc_id = "vpc-0fc1f416a99367802"
}

# "pcx-04bb64cdbe9429a76"
resource "aws_vpc_peering_connection" "vpc789_to_vpc123" {
  auto_accept   = null
  peer_owner_id = "880110983955"
  peer_region   = "us-east-1"
  peer_vpc_id   = "vpc-0fc1f416a99367802"
  region        = "us-east-1"
  tags = {
    Name = "VPC123-VPC789"
  }
  tags_all = {
    Name = "VPC123-VPC789"
  }
  vpc_id = "vpc-0b3629292bff4ffc6"
  accepter {
    allow_remote_vpc_dns_resolution = false
  }
  requester {
    allow_remote_vpc_dns_resolution = false
  }
}

# "pcx-04bb64cdbe9429a76"
resource "aws_vpc_peering_connection_accepter" "VPC123-VPC789" {
  auto_accept = null
  region      = "us-east-1"
  tags = {
    Name = "VPC123-VPC789"
  }
  tags_all = {
    Name = "VPC123-VPC789"
  }
  vpc_peering_connection_id = "pcx-04bb64cdbe9429a76"
  accepter {
    allow_remote_vpc_dns_resolution = false
  }
  requester {
    allow_remote_vpc_dns_resolution = false
  }
}

# "acl-0081b3fe550e7b311"
resource "aws_default_network_acl" "default_nacl" {
  default_network_acl_id = "acl-0081b3fe550e7b311"
  region                 = "us-east-1"
  subnet_ids             = ["subnet-05f4a1227e3f212f8", "subnet-080f6702562499c23", "subnet-09c877aeb82eed5c0"]
  tags                   = {}
  tags_all               = {}
  egress {
    action          = "allow"
    cidr_block      = "0.0.0.0/0"
    from_port       = 0
    icmp_code       = 0
    icmp_type       = 0
    ipv6_cidr_block = null
    protocol        = "-1"
    rule_no         = 100
    to_port         = 0
  }
  ingress {
    action          = "allow"
    cidr_block      = "0.0.0.0/0"
    from_port       = 0
    icmp_code       = 0
    icmp_type       = 0
    ipv6_cidr_block = null
    protocol        = "-1"
    rule_no         = 100
    to_port         = 0
  }
}

# "sg-0730fa3094d2251ac"
resource "aws_security_group" "Swarm_Group" {
  description = "Allow Swarm Ports"
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
  ingress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = ""
    from_port        = -1
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "icmp"
    security_groups  = []
    self             = false
    to_port          = -1
    }, {
    cidr_blocks      = ["0.0.0.0/0"]
    description      = ""
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "-1"
    security_groups  = []
    self             = false
    to_port          = 0
    }, {
    cidr_blocks      = ["0.0.0.0/0"]
    description      = ""
    from_port        = 22
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = []
    self             = false
    to_port          = 22
    }, {
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "Cluster Mgmt Communication"
    from_port        = 2377
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = []
    self             = false
    to_port          = 2377
    }, {
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "ESP"
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "50"
    security_groups  = []
    self             = false
    to_port          = 0
    }, {
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "Node Communication"
    from_port        = 7946
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = []
    self             = false
    to_port          = 7946
    }, {
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "Node Communication"
    from_port        = 7946
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "udp"
    security_groups  = []
    self             = false
    to_port          = 7946
    }, {
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "Overlay"
    from_port        = 4789
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "udp"
    security_groups  = []
    self             = false
    to_port          = 4789
  }]
  name                   = "Swarm_Group"
  name_prefix            = null
  region                 = "us-east-1"
  revoke_rules_on_delete = null
  tags                   = {}
  tags_all               = {}
  vpc_id                 = "vpc-0ecfccc63aeae1969"
}


resource "aws_subnet" "public_1b" {
  availability_zone = "us-east-1b"
  cidr_block        = "10.0.1.16/28"
  vpc_id            = "vpc-0fc1f416a99367802"
  
  tags = {
    Name = "Peer123-subnet-public2-us-east-1b"
  }
}


resource "aws_subnet" "public_1a" {
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.1.0/28"
  vpc_id            = "vpc-0fc1f416a99367802"
  
  tags = {
    Name = "Peer123-subnet-public1-us-east-1a"
  }
}


resource "aws_subnet" "public_1c" {
  availability_zone = "us-east-1c"
  cidr_block        = "10.0.1.32/28"
  vpc_id            = "vpc-0fc1f416a99367802"
  
  tags = {
    Name = "Peer123-subnet-public3-us-east-1c"
  }
}

# "eipalloc-021c8ec29904b440a"
resource "aws_eip" "org1_eip" {
  address                   = null
  associate_with_private_ip = null
  customer_owned_ipv4_pool  = null
  domain                    = "vpc"
  instance                  = "i-086fa90ecdb430d79"
  ipam_pool_id              = null
  network_border_group      = "us-east-1"
  network_interface         = "eni-08cf2068af3f44b02"
  public_ipv4_pool          = "amazon"
  region                    = "us-east-1"
  tags = {
    Name = "BBVS_Peer123-eip-us-east-1a"
  }
  tags_all = {
    Name = "BBVS_Peer123-eip-us-east-1a"
  }
}


resource "aws_vpc" "peer123_vpc" {
  cidr_block           = "10.0.1.0/24"
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name = "Peer123-vpc"
  }
}


resource "aws_instance" "org1" {
  ami                    = "ami-084568db4383264d4"
  instance_type          = "c7a.xlarge"
  key_name               = "Swarm_key"
  private_ip             = "10.0.1.12"
  subnet_id              = "subnet-09c877aeb82eed5c0"
  vpc_security_group_ids = ["sg-0ec35adf53f858148"]
  
  tags = {
    Name = "Org1"
  }
  
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
}


resource "aws_instance" "org2" {
  ami                    = "ami-084568db4383264d4"
  instance_type          = "c7a.xlarge"
  key_name               = "Swarm_key"
  private_ip             = "10.0.1.28"
  subnet_id              = "subnet-080f6702562499c23"
  vpc_security_group_ids = ["sg-0ec35adf53f858148"]
  
  tags = {
    Name = "Org2"
  }
  
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
}


resource "aws_instance" "org3" {
  ami                    = "ami-084568db4383264d4"
  instance_type          = "c7a.xlarge"
  key_name               = "Swarm_key"
  private_ip             = "10.0.1.42"
  subnet_id              = "subnet-05f4a1227e3f212f8"
  vpc_security_group_ids = ["sg-0ec35adf53f858148"]
  
  tags = {
    Name = "Org3"
  }
  
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
}

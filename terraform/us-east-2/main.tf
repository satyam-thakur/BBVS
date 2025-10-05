# import {
#   to = aws_vpc.vpc_456
#   id = "vpc-07b0b52d2ba27ab4f"
# }

# import {
#   to = aws_subnet.public_1a
#   id = "subnet-022a3b8fa1325bd10"
# }

# import {
#   to = aws_subnet.public_1b
#   id = "subnet-02441e65f47115dfe"
# }

# import {
#   to = aws_subnet.public_1c
#   id = "subnet-057c9eeaf4e255a49"
# }

# import {
#   to = aws_instance.org4
#   id = "i-0fd8511e7497c5f03"
# }

# import {
#   to = aws_instance.org5
#   id = "i-037555be6470ac587"
# }

# import {
#   to = aws_instance.org6
#   id = "i-009f3c34e68ac3ed1"
# }

# # --- Networking ---
# import {
#   to = aws_security_group.swarm_group
#   id = "sg-0d26a17d1ce9f67f7"
# }

# import {
#   to = aws_route_table.VPC456-rt-VPC789_VPC123
#   id = "rtb-0a6c2f694603a893c"
# }

# import {
#   to = aws_internet_gateway.peer456_igw
#   id = "igw-024a6a3420f3442c7"
# }

# import {
#   to = aws_vpc_peering_connection.peering_with_vpc123
#   id = "pcx-068c3c652492096ac"
# }

# import {
#   to = aws_vpc_peering_connection.peering_with_vpc789
#   id = "pcx-0aafb24de9cc9b8eb"
# }

# import {
#   to = aws_vpc_peering_connection_accepter.peering_with_vpc123
#   id = "pcx-068c3c652492096ac"
# }

# import {
#   to = aws_vpc_peering_connection_accepter.peering_with_vpc789
#   id = "pcx-aafb24de9cc9b8eb"
# }

# import {
#   to = aws_default_network_acl.default_nacl
#   id = "acl-0b75636dec78c6094"
# }

# "igw-024a6a3420f3442c7"
resource "aws_internet_gateway" "peer456_igw" {
  region = "us-east-2"
  tags = {
    Name = "Peer456-igw"
  }
  tags_all = {
    Name = "Peer456-igw"
  }
  vpc_id = aws_vpc.vpc_456.id
}

# "pcx-068c3c652492096ac"
resource "aws_vpc_peering_connection" "peering_with_vpc123" {
  auto_accept   = null
  peer_owner_id = "880110983955"
  peer_region   = "us-east-1"
  peer_vpc_id   = "vpc-0fc1f416a99367802"
  region        = "us-east-2"
  tags = {
    Name = "VPC456-VPC123"
  }
  tags_all = {
    Name = "VPC456-VPC123"
  }
  vpc_id = aws_vpc.vpc_456.id
  accepter {
    allow_remote_vpc_dns_resolution = false
  }
  requester {
    allow_remote_vpc_dns_resolution = false
  }
}

# "pcx-0aafb24de9cc9b8eb"
resource "aws_vpc_peering_connection" "peering_with_vpc789" {
  auto_accept   = null
  peer_owner_id = "880110983955"
  peer_region   = "us-west-2"
  peer_vpc_id   = "vpc-0b3629292bff4ffc6"
  region        = "us-east-2"
  tags = {
    Name = "VPC456-VPC789"
  }
  tags_all = {
    Name = "VPC456-VPC789"
  }
  vpc_id = aws_vpc.vpc_456.id
  accepter {
    allow_remote_vpc_dns_resolution = false
  }
  requester {
    allow_remote_vpc_dns_resolution = false
  }
}

# "pcx-068c3c652492096ac"
resource "aws_vpc_peering_connection_accepter" "peering_vpc123" {
  auto_accept = null
  region      = "us-east-2"
  tags = {
    Name = "VPC123-VPC456"
  }
  tags_all = {
    Name = "VPC123-VPC456"
  }
  vpc_peering_connection_id = aws_vpc_peering_connection.peering_with_vpc123.id
  accepter {
    allow_remote_vpc_dns_resolution = false
  }
  requester {
    allow_remote_vpc_dns_resolution = false
  }
}

# "pcx-0aafb24de9cc9b8eb"
resource "aws_vpc_peering_connection_accepter" "peering_vpc789" {
  auto_accept = null
  region      = "us-east-2"
  tags = {
    Name = "VPC456-VPC789"
  }
  tags_all = {
    Name = "VPC456-VPC789"
  }
  vpc_peering_connection_id = aws_vpc_peering_connection.peering_with_vpc789.id
  accepter {
    allow_remote_vpc_dns_resolution = false
  }
  requester {
    allow_remote_vpc_dns_resolution = false
  }
}

resource "aws_route_table" "VPC456-rt-VPC789_VPC123" {
  propagating_vgws = []
  region           = "us-east-2"
  route = [{
    carrier_gateway_id         = null
    cidr_block                 = "0.0.0.0/0"
    core_network_arn           = null
    destination_prefix_list_id = null
    egress_only_gateway_id     = null
    gateway_id                 = aws_internet_gateway.peer456_igw.id
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
    vpc_peering_connection_id  = aws_vpc_peering_connection.peering_with_vpc123.id
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
    vpc_peering_connection_id  = aws_vpc_peering_connection.peering_with_vpc789.id
  }]
  tags = {
    Name = "VPC456-rt-VPC789&VPC123"
  }
  tags_all = {
    Name = "VPC456-rt-VPC789&VPC123"
  }
  vpc_id = aws_vpc.vpc_456.id
}

# "acl-0b75636dec78c6094"
resource "aws_default_network_acl" "default_nacl" {
  default_network_acl_id = aws_vpc.vpc_456.default_network_acl_id
  region                 = "us-east-2"
  subnet_ids             = [aws_subnet.public_1a.id, aws_subnet.public_1b.id, aws_subnet.public_1c.id]
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


# "sg-0d26a17d1ce9f67f7"
resource "aws_security_group" "swarm_group" {
  description = "allow all traffic"
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
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "-1"
    security_groups  = []
    self             = false
    to_port          = 0
  }]
  name                   = "BBVS"
  name_prefix            = null
  region                 = "us-east-2"
  revoke_rules_on_delete = null
  tags                   = {}
  tags_all               = {}
  vpc_id                 = aws_vpc.vpc_456.id
}


resource "aws_subnet" "public_1b" {
  availability_zone = "us-east-2b"
  cidr_block        = "10.0.2.16/28"
  vpc_id            = aws_vpc.vpc_456.id
  
  tags = {
    Name = "Peer456-vpc-subnet-public2-us-east-2b"
  }
}


resource "aws_subnet" "public_1c" {
  availability_zone = "us-east-2c"
  cidr_block        = "10.0.2.32/28"
  vpc_id            = aws_vpc.vpc_456.id
  
  tags = {
    Name = "Peer456-vpc-subnet-public3-us-east-2c"
  }
}


resource "aws_subnet" "public_1a" {
  availability_zone = "us-east-2a"
  cidr_block        = "10.0.2.0/28"
  vpc_id            = aws_vpc.vpc_456.id
  
  tags = {
    Name = "Peer456-vpc-subnet-public1-us-east-2a"
  }
}


resource "aws_vpc" "vpc_456" {
  cidr_block           = "10.0.2.0/24"
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name = "Peer456-vpc-vpc"
  }
}


resource "aws_instance" "org5" {
  ami                    = "ami-04f167a56786e4b09"
  instance_type          = "c7a.xlarge"
  key_name               = "BBVS_Ohio"
  private_ip             = "10.0.2.30"
  subnet_id              = aws_subnet.public_1b.id
  vpc_security_group_ids = [aws_security_group.swarm_group.id]
  
  tags = {
    Name = "Org5"
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


resource "aws_instance" "org6" {
  ami                    = "ami-04f167a56786e4b09"
  instance_type          = "c7a.xlarge"
  key_name               = "BBVS_Ohio"
  private_ip             = "10.0.2.37"
  subnet_id              = aws_subnet.public_1c.id
  vpc_security_group_ids = [aws_security_group.swarm_group.id]
  
  tags = {
    Name = "Org6"
  }
  
  cpu_options {
    core_count       = 4
    threads_per_core = 1
  }
  
  root_block_device {
    delete_on_termination = true
    encrypted             = false
    iops                  = 3000
    kms_key_id            = null
    tags                  = {}
    tags_all              = {}
    throughput            = 125
    volume_size           = 30
    volume_type           = "gp3"
  }
}


resource "aws_instance" "org4" {
  ami                    = "ami-04f167a56786e4b09"
  instance_type          = "c7a.xlarge"
  key_name               = "BBVS_Ohio"
  private_ip             = "10.0.2.6"
  subnet_id              = aws_subnet.public_1a.id
  vpc_security_group_ids = [aws_security_group.swarm_group.id]
  
  tags = {
    Name = "Org4"
  }
  
  cpu_options {
    core_count       = 4
    threads_per_core = 1
  }
  
  root_block_device {
    delete_on_termination = true
    encrypted             = false
    iops                  = 3000
    kms_key_id            = null
    tags                  = {}
    tags_all              = {}
    throughput            = 125
    volume_size           = 40
    volume_type           = "gp3"
  }
}

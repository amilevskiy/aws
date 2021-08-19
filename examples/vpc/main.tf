################
module "const" {
  ##############
  source = "github.com/amilevskiy/const?ref=v0.1.10"
}

##################
module "central" {
  ################
  source = "github.com/amilevskiy/aws//vpc?ref=v0.0.8"
  enable = var.enable

  env = var.env

  vpc = {
    cidr_block           = "10.255.128.0/18"
    enable_dns_hostnames = true
  }

  dhcp_options     = {}
  internet_gateway = {}
  nat_gateway      = {}

  subnets = {
    availability_zones = keys(local.availability_zones)

    k8s  = { hosts = 1024 }
    misc = { hosts = 512 }
    lb   = { hosts = 16 }
    #lb = { cidr_blocks = [
    #  "10.255.255.0/28",
    #  "10.255.255.16/28",
    #  "10.255.255.32/28",
    #  "10.255.255.48/28",
    #  "10.255.255.64/28",
    #  "10.255.255.80/28",
    #  "10.255.255.96/28",
    #  "10.255.255.112/28",
    #] }
    public  = { hosts = 32 }
    secured = { hosts = 16 }
    #secured = { cidr_blocks = [
    #  "10.255.255.128/28",
    #  "10.255.255.144/28",
    #  "10.255.255.160/28",
    #  "10.255.255.176/28",
    #  "10.255.255.192/28",
    #  "10.255.255.208/28",
    #  "10.255.255.224/28",
    #  "10.255.255.240/28",
    #] }
  }
}

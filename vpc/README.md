<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_const"></a> [const](#module\_const) | github.com/amilevskiy/const | v0.1.11 |

## Resources

| Name | Type |
|------|------|
| [aws_default_network_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_network_acl) | resource |
| [aws_default_route_table.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table) | resource |
| [aws_default_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_default_vpc_dhcp_options.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_vpc_dhcp_options) | resource |
| [aws_ec2_tag.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_tag) | resource |
| [aws_ec2_transit_gateway_route.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_vpc_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_vpc_attachment) | resource |
| [aws_eip.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_network_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_network_acl_rule.egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_route.default_for_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.default_for_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.transit_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.vpce](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.vpce](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_subnet.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_vpc_dhcp_options.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_dhcp_options) | resource |
| [aws_vpc_dhcp_options_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_dhcp_options_association) | resource |
| [aws_vpc_endpoint.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint_route_table_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_route_table_association) | resource |
| [aws_vpc_endpoint_subnet_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_subnet_association) | resource |
| [random_shuffle.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/shuffle) | resource |
| [aws_region.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_awscli_args"></a> [awscli\_args](#input\_awscli\_args) | The AWS CLI arguments [e.g. --profile DEVOPS] | `string` | `"no"` | no |
| <a name="input_bool2string"></a> [bool2string](#input\_bool2string) | The map for conversion from bool value to string representation | `map(string)` | <pre>{<br>  "false": "disable",<br>  "true": "enable"<br>}</pre> | no |
| <a name="input_dhcp_options"></a> [dhcp\_options](#input\_dhcp\_options) | The object which describes "aws\_vpc\_dhcp\_options" resource | <pre>object({<br>    name = optional(string)<br><br>    domain_name          = optional(string)<br>    domain_name_servers  = optional(list(string))<br>    ntp_servers          = optional(list(string))<br>    netbios_name_servers = optional(list(string))<br>    netbios_node_type    = optional(number)<br>  })</pre> | `null` | no |
| <a name="input_enable"></a> [enable](#input\_enable) | Destroy all module resources if false | `bool` | `false` | no |
| <a name="input_enable_security_group_rule_embedding"></a> [enable\_security\_group\_rule\_embedding](#input\_enable\_security\_group\_rule\_embedding) | If true then rules will be embedded into "aws\_security\_group" resource | `bool` | `false` | no |
| <a name="input_env"></a> [env](#input\_env) | The name of target environment | `string` | `""` | no |
| <a name="input_hosts"></a> [hosts](#input\_hosts) | The number of hosts in each subnet | `map(number)` | <pre>{<br>  "k8s": 1024,<br>  "lb": 16,<br>  "misc": 512,<br>  "public": 32,<br>  "secured": 16<br>}</pre> | no |
| <a name="input_internet_gateway"></a> [internet\_gateway](#input\_internet\_gateway) | The object which describes "aws\_internet\_gateway" resource | <pre>object({<br>    name = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_label"></a> [label](#input\_label) | The labels for created resources | `map(string)` | <pre>{<br>  "default": "default",<br>  "k8s": "k8s",<br>  "lb": "lb",<br>  "misc": "misc",<br>  "public": "public",<br>  "secured": "secured"<br>}</pre> | no |
| <a name="input_manage_default_vpc_dhcp_options"></a> [manage\_default\_vpc\_dhcp\_options](#input\_manage\_default\_vpc\_dhcp\_options) | The flag to tag default\_vpc\_dhcp\_options for current region | `bool` | `false` | no |
| <a name="input_max_ipv4_prefix"></a> [max\_ipv4\_prefix](#input\_max\_ipv4\_prefix) | /32 for CIDR | `number` | `32` | no |
| <a name="input_name"></a> [name](#input\_name) | The component of tag-name | `string` | `""` | no |
| <a name="input_nat_gateway"></a> [nat\_gateway](#input\_nat\_gateway) | The object which describes "aws\_nat\_gateway" resource | <pre>object({<br>    name_prefix = optional(string)<br><br>    allocation_id     = optional(string)<br>    connectivity_type = optional(string) # private and public. Defaults to public.<br><br>    network_border_group = optional(string)<br><br>    subnet_index = optional(number)<br><br>    timeouts = optional(object({<br>      read   = optional(string)<br>      update = optional(string)<br>      delete = optional(string)<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | The list of security group objects | <pre>map(object({<br>    description            = optional(string)<br>    revoke_rules_on_delete = optional(bool)<br><br>    ingress = optional(list(string))<br>    egress  = optional(list(string))<br>  }))</pre> | `null` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | The object which describes "aws\_subnet" resources | <pre>object({<br>    name_prefix = optional(string)<br><br>    availability_zones    = optional(list(string))<br>    availability_zone_ids = optional(list(string))<br><br>    map_public_ip_on_launch         = optional(bool) # Default: false<br>    assign_ipv6_address_on_creation = optional(bool) # Default: false<br><br>    # intentionally omit support of the following due to lack of testing?<br>    map_customer_owned_ip_on_launch = optional(bool) # Default: false<br>    outpost_arn                     = optional(string)<br><br>    propagating_vgws = optional(list(string))<br><br>    public = optional(object({<br>      name_prefix = optional(string)<br><br>      hosts = optional(number)<br><br>      cidr_blocks             = optional(list(string))<br>      map_public_ip_on_launch = optional(bool) # Default: false<br><br>      assign_ipv6_address_on_creation = optional(bool)         # Default: false<br>      ipv6_cidr_blocks                = optional(list(string)) # /64<br><br>      map_customer_owned_ip_on_launch = optional(bool) # Default: false<br>      customer_owned_ipv4_pool        = optional(list(string))<br>      outpost_arn                     = optional(string)<br><br>      propagating_vgws = optional(list(string))<br><br>      tags = optional(map(string))<br>    }))<br><br>    lb = optional(object({<br>      name_prefix = optional(string)<br><br>      hosts = optional(number)<br><br>      cidr_blocks             = optional(list(string))<br>      map_public_ip_on_launch = optional(bool) # Default: false<br><br>      assign_ipv6_address_on_creation = optional(bool)         # Default: false<br>      ipv6_cidr_blocks                = optional(list(string)) # /64<br><br>      map_customer_owned_ip_on_launch = optional(bool) # Default: false<br>      customer_owned_ipv4_pool        = optional(list(string))<br>      outpost_arn                     = optional(string)<br><br>      propagating_vgws = optional(list(string))<br><br>      tags = optional(map(string))<br>    }))<br><br>    k8s = optional(object({<br>      name_prefix = optional(string)<br><br>      hosts = optional(number)<br><br>      cidr_blocks             = optional(list(string))<br>      map_public_ip_on_launch = optional(bool) # Default: false<br><br>      assign_ipv6_address_on_creation = optional(bool)         # Default: false<br>      ipv6_cidr_blocks                = optional(list(string)) # /64<br><br>      map_customer_owned_ip_on_launch = optional(bool) # Default: false<br>      customer_owned_ipv4_pool        = optional(list(string))<br>      outpost_arn                     = optional(string)<br><br>      propagating_vgws = optional(list(string))<br><br>      tags = optional(map(string))<br>    }))<br><br>    misc = optional(object({<br>      name_prefix = optional(string)<br><br>      hosts = optional(number)<br><br>      cidr_blocks             = optional(list(string))<br>      map_public_ip_on_launch = optional(bool) # Default: false<br><br>      assign_ipv6_address_on_creation = optional(bool)         # Default: false<br>      ipv6_cidr_blocks                = optional(list(string)) # /64<br><br>      map_customer_owned_ip_on_launch = optional(bool) # Default: false<br>      customer_owned_ipv4_pool        = optional(list(string))<br>      outpost_arn                     = optional(string)<br><br>      propagating_vgws = optional(list(string))<br><br>      tags = optional(map(string))<br>    }))<br><br>    secured = optional(object({<br>      name_prefix = optional(string)<br><br>      hosts = optional(number)<br><br>      cidr_blocks             = optional(list(string))<br>      map_public_ip_on_launch = optional(bool) # Default: false<br><br>      assign_ipv6_address_on_creation = optional(bool)         # Default: false<br>      ipv6_cidr_blocks                = optional(list(string)) # /64<br><br>      map_customer_owned_ip_on_launch = optional(bool) # Default: false<br>      customer_owned_ipv4_pool        = optional(list(string))<br>      outpost_arn                     = optional(string)<br><br>      propagating_vgws = optional(list(string))<br><br>      tags = optional(map(string))<br><br>      # nice to do: network_acl_cidr_blocks = optional(list(string))<br>      network_acl_cidr_block = optional(string)<br><br>      transit_gateway_vpc_attachments = optional(list(object({<br>        name = optional(string)<br><br>        id = string<br>        # appliance_mode_support = optional(string) # Default: disable<br>        # dns_support            = optional(string) # Default: enable<br>        # ipv6_support           = optional(string) # Default: disable<br><br>        # transit_gateway_default_route_table_association = optional(bool) # Default: true<br>        # transit_gateway_default_route_table_propagation = optional(bool) # Default: true<br><br>        enable_appliance_mode_support          = optional(bool) # Default: disable<br>        enable_dns_support                     = optional(bool) # Default: enable<br>        enable_ipv6_support                    = optional(bool) # Default: disable<br>        enable_default_route_table_association = optional(bool) # Default: true<br>        enable_default_route_table_propagation = optional(bool) # Default: true<br><br>        vpc_routes = optional(list(string))<br><br>        association_default_route_table_id = optional(string)<br>        transit_gateway_static_routes      = optional(list(string))<br>      })))<br>    }))<br><br>    timeouts = optional(object({<br>      create = optional(string)<br>      delete = optional(string)<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_subnets_order"></a> [subnets\_order](#input\_subnets\_order) | The order of subnets | `list(string)` | <pre>[<br>  "k8s",<br>  "misc",<br>  "public",<br>  "lb",<br>  "secured"<br>]</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags which should be assigned to all module resources | `map(string)` | `{}` | no |
| <a name="input_vpc"></a> [vpc](#input\_vpc) | The object which describes "aws\_vpc" resource | <pre>object({<br>    name = optional(string)<br><br>    cidr_block                       = string<br>    instance_tenancy                 = optional(string) # default, dedicated, host<br>    enable_dns_support               = optional(bool)   # Defaults true<br>    enable_dns_hostnames             = optional(bool)   # Defaults false<br>    enable_classiclink               = optional(bool)   # Defaults false<br>    enable_classiclink_dns_support   = optional(bool)<br>    assign_generated_ipv6_cidr_block = optional(bool) # Defaults false<br>  })</pre> | `null` | no |
| <a name="input_vpc_endpoint"></a> [vpc\_endpoint](#input\_vpc\_endpoint) | The object which describes "aws\_vpc\_endpoint" resources | <pre>object({<br>    name_prefix = optional(string)<br><br>    region                       = optional(string)<br>    enable_route_table_embedding = optional(bool)<br>    enable_subnet_embedding      = optional(bool)<br><br>    services = optional(map(object({<br>      name = optional(string)<br><br>      region              = optional(string)<br>      auto_accept         = optional(bool)<br>      policy              = optional(string)<br>      private_dns_enabled = optional(bool)<br>      vpc_endpoint_type   = optional(string)      # Gateway, GatewayLoadBalancer, Interface<br>      security_group_ids  = optional(set(string)) # Interface (required)<br>    })))<br><br>    timeouts = optional(object({<br>      create = optional(string)<br>      update = optional(string)<br>      delete = optional(string)<br>    }))<br>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_availability_zone_ids"></a> [availability\_zone\_ids](#output\_availability\_zone\_ids) | The list of used availability zone ids |
| <a name="output_availability_zones"></a> [availability\_zones](#output\_availability\_zones) | The list of used availability zones |
| <a name="output_enable"></a> [enable](#output\_enable) | var.enable passthrough |
| <a name="output_env"></a> [env](#output\_env) | var.env passthrough |
| <a name="output_name"></a> [name](#output\_name) | var.name passthrough |
| <a name="output_nat_gateway"></a> [nat\_gateway](#output\_nat\_gateway) | The "aws\_nat\_gateway" object |
| <a name="output_network_acls"></a> [network\_acls](#output\_network\_acls) | The map of "aws\_route\_table" objects |
| <a name="output_route_tables"></a> [route\_tables](#output\_route\_tables) | The map of "aws\_route\_table" objects |
| <a name="output_security_groups"></a> [security\_groups](#output\_security\_groups) | The map of "aws\_security\_group" objects |
| <a name="output_subnets"></a> [subnets](#output\_subnets) | The map of "aws\_subnet" objects |
| <a name="output_transit_gateway_vpc_attachment"></a> [transit\_gateway\_vpc\_attachment](#output\_transit\_gateway\_vpc\_attachment) | The map of "aws\_ec2\_transit\_gateway\_vpc\_attachment" objects |
| <a name="output_vpc"></a> [vpc](#output\_vpc) | The "aws\_vpc" object |
| <a name="output_vpc_endpoint"></a> [vpc\_endpoint](#output\_vpc\_endpoint) | The map of "aws\_vpc\_endpoint" objects |
| <a name="output_vpc_endpoint_security_groups"></a> [vpc\_endpoint\_security\_groups](#output\_vpc\_endpoint\_security\_groups) | The map of "aws\_security\_group" objects that applied to appropriate "aws\_vpc\_endpoint" objects |
<!-- END_TF_DOCS -->
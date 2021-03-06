<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_const"></a> [const](#module\_const) | github.com/amilevskiy/const | v0.1.11 |

## Resources

| Name | Type |
|------|------|
| [aws_eip.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_network_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_network_acl_rule.egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_route.default_for_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.default_for_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_subnet.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc_dhcp_options.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_dhcp_options) | resource |
| [aws_vpc_dhcp_options_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_dhcp_options_association) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_awscli_args"></a> [awscli\_args](#input\_awscli\_args) | (Optional) The AWS CLI arguments [e.g. --profile DEVOPS] | `string` | `"no"` | no |
| <a name="input_dhcp_options"></a> [dhcp\_options](#input\_dhcp\_options) | n/a | <pre>object({<br>    name = optional(string)<br><br>    domain_name          = optional(string)<br>    domain_name_servers  = optional(list(string))<br>    ntp_servers          = optional(list(string))<br>    netbios_name_servers = optional(list(string))<br>    netbios_node_type    = optional(number)<br>  })</pre> | `null` | no |
| <a name="input_enable"></a> [enable](#input\_enable) | (Optional) Destroy all module resources if false | `bool` | `false` | no |
| <a name="input_env"></a> [env](#input\_env) | (Optional) The name of target environment | `string` | `""` | no |
| <a name="input_hosts"></a> [hosts](#input\_hosts) | n/a | `map(number)` | <pre>{<br>  "k8s": 1024,<br>  "lb": 16,<br>  "misc": 512,<br>  "public": 32,<br>  "secured": 16<br>}</pre> | no |
| <a name="input_internet_gateway"></a> [internet\_gateway](#input\_internet\_gateway) | n/a | <pre>object({<br>    name = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_label"></a> [label](#input\_label) | The labels for created resources | `map(string)` | <pre>{<br>  "default": "default",<br>  "k8s": "k8s",<br>  "lb": "lb",<br>  "misc": "misc",<br>  "public": "public",<br>  "secured": "secured"<br>}</pre> | no |
| <a name="input_manage_default_vpc_dhcp_options"></a> [manage\_default\_vpc\_dhcp\_options](#input\_manage\_default\_vpc\_dhcp\_options) | The flag to tag default\_vpc\_dhcp\_options for current region | `bool` | `false` | no |
| <a name="input_max_ipv4_prefix"></a> [max\_ipv4\_prefix](#input\_max\_ipv4\_prefix) | n/a | `number` | `32` | no |
| <a name="input_name"></a> [name](#input\_name) | (Optional) The component of tag-name | `string` | `""` | no |
| <a name="input_nat_gateway"></a> [nat\_gateway](#input\_nat\_gateway) | n/a | <pre>object({<br>    name_prefix = optional(string)<br><br>    allocation_id     = optional(string)<br>    connectivity_type = optional(string) # private and public. Defaults to public.<br><br>    network_border_group = optional(string)<br><br>    subnet_index = optional(number)<br><br>    timeouts = optional(object({<br>      read   = optional(string)<br>      update = optional(string)<br>      delete = optional(string)<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | n/a | <pre>object({<br>    name_prefix = optional(string)<br><br>    availability_zones    = optional(list(string))<br>    availability_zone_ids = optional(list(string))<br><br>    map_public_ip_on_launch         = optional(bool) # Default: false<br>    assign_ipv6_address_on_creation = optional(bool) # Default: false<br><br>    # intentionally omit support of the following due to lack of testing?<br>    map_customer_owned_ip_on_launch = optional(bool) # Default: false<br>    outpost_arn                     = optional(string)<br><br>    propagating_vgws = optional(list(string))<br><br>    public = optional(object({<br>      name_prefix = optional(string)<br><br>      hosts = optional(number)<br><br>      cidr_blocks             = optional(list(string))<br>      map_public_ip_on_launch = optional(bool) # Default: false<br><br>      assign_ipv6_address_on_creation = optional(bool)         # Default: false<br>      ipv6_cidr_blocks                = optional(list(string)) # /64<br><br>      map_customer_owned_ip_on_launch = optional(bool) # Default: false<br>      customer_owned_ipv4_pool        = optional(list(string))<br>      outpost_arn                     = optional(string)<br><br>      propagating_vgws = optional(list(string))<br><br>      routes = optional(map(list(string)))<br>    }))<br><br>    lb = optional(object({<br>      name_prefix = optional(string)<br><br>      hosts = optional(number)<br><br>      cidr_blocks             = optional(list(string))<br>      map_public_ip_on_launch = optional(bool) # Default: false<br><br>      assign_ipv6_address_on_creation = optional(bool)         # Default: false<br>      ipv6_cidr_blocks                = optional(list(string)) # /64<br><br>      map_customer_owned_ip_on_launch = optional(bool) # Default: false<br>      customer_owned_ipv4_pool        = optional(list(string))<br>      outpost_arn                     = optional(string)<br><br>      propagating_vgws = optional(list(string))<br><br>      routes = optional(map(list(string)))<br>    }))<br><br>    k8s = optional(object({<br>      name_prefix = optional(string)<br><br>      hosts = optional(number)<br><br>      cidr_blocks             = optional(list(string))<br>      map_public_ip_on_launch = optional(bool) # Default: false<br><br>      assign_ipv6_address_on_creation = optional(bool)         # Default: false<br>      ipv6_cidr_blocks                = optional(list(string)) # /64<br><br>      map_customer_owned_ip_on_launch = optional(bool) # Default: false<br>      customer_owned_ipv4_pool        = optional(list(string))<br>      outpost_arn                     = optional(string)<br><br>      propagating_vgws = optional(list(string))<br><br>      routes = optional(map(list(string)))<br>    }))<br><br>    misc = optional(object({<br>      name_prefix = optional(string)<br><br>      hosts = optional(number)<br><br>      cidr_blocks             = optional(list(string))<br>      map_public_ip_on_launch = optional(bool) # Default: false<br><br>      assign_ipv6_address_on_creation = optional(bool)         # Default: false<br>      ipv6_cidr_blocks                = optional(list(string)) # /64<br><br>      map_customer_owned_ip_on_launch = optional(bool) # Default: false<br>      customer_owned_ipv4_pool        = optional(list(string))<br>      outpost_arn                     = optional(string)<br><br>      propagating_vgws = optional(list(string))<br><br>      routes = optional(map(list(string)))<br>    }))<br><br>    secured = optional(object({<br>      name_prefix = optional(string)<br><br>      hosts = optional(number)<br><br>      cidr_blocks             = optional(list(string))<br>      map_public_ip_on_launch = optional(bool) # Default: false<br><br>      assign_ipv6_address_on_creation = optional(bool)         # Default: false<br>      ipv6_cidr_blocks                = optional(list(string)) # /64<br><br>      map_customer_owned_ip_on_launch = optional(bool) # Default: false<br>      customer_owned_ipv4_pool        = optional(list(string))<br>      outpost_arn                     = optional(string)<br><br>      propagating_vgws = optional(list(string))<br><br>      # nice to do: network_acl_cidr_blocks = optional(list(string))<br>      network_acl_cidr_block = optional(string)<br><br>      routes = optional(map(list(string)))<br>    }))<br><br>    timeouts = optional(object({<br>      create = optional(string)<br>      delete = optional(string)<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_subnets_order"></a> [subnets\_order](#input\_subnets\_order) | n/a | `list(string)` | <pre>[<br>  "k8s",<br>  "misc",<br>  "public",<br>  "lb",<br>  "secured"<br>]</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A mapping of tags which should be assigned to all module resources | `map(string)` | `{}` | no |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | n/a | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_availability_zone_ids"></a> [availability\_zone\_ids](#output\_availability\_zone\_ids) | ############################### |
| <a name="output_availability_zones"></a> [availability\_zones](#output\_availability\_zones) | ############################ |
| <a name="output_enable"></a> [enable](#output\_enable) | ################ |
| <a name="output_env"></a> [env](#output\_env) | ############# |
| <a name="output_name"></a> [name](#output\_name) | ############## |
| <a name="output_network_acls"></a> [network\_acls](#output\_network\_acls) | ###################### |
| <a name="output_route_tables"></a> [route\_tables](#output\_route\_tables) | ###################### |
| <a name="output_subnets"></a> [subnets](#output\_subnets) | ################# |
<!-- END_TF_DOCS -->
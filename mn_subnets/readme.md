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
| [aws_network_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_network_acl_rule.egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_route.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_subnet.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc_endpoint_route_table_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_route_table_association) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | n/a | `string` | `null` | no |
| <a name="input_availability_zone_id"></a> [availability\_zone\_id](#input\_availability\_zone\_id) | n/a | `string` | `null` | no |
| <a name="input_enable"></a> [enable](#input\_enable) | (Optional) Destroy all module resources if false | `bool` | `false` | no |
| <a name="input_enable_network_acl_rule_embedding"></a> [enable\_network\_acl\_rule\_embedding](#input\_enable\_network\_acl\_rule\_embedding) | n/a | `bool` | `false` | no |
| <a name="input_enable_security_group_rule_embedding"></a> [enable\_security\_group\_rule\_embedding](#input\_enable\_security\_group\_rule\_embedding) | n/a | `bool` | `false` | no |
| <a name="input_map_public_ip_on_launch"></a> [map\_public\_ip\_on\_launch](#input\_map\_public\_ip\_on\_launch) | n/a | `bool` | `null` | no |
| <a name="input_network_acl_rule_start"></a> [network\_acl\_rule\_start](#input\_network\_acl\_rule\_start) | n/a | `number` | `1000` | no |
| <a name="input_network_acl_rule_step"></a> [network\_acl\_rule\_step](#input\_network\_acl\_rule\_step) | n/a | `number` | `10` | no |
| <a name="input_route_table"></a> [route\_table](#input\_route\_table) | n/a | <pre>object({<br>    propagating_vgws = optional(set(string))<br>    routes           = optional(set(string))<br>  })</pre> | `null` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | n/a | <pre>map(object({<br>    description = optional(string)<br><br>    ingress = optional(list(string))<br>    egress  = optional(list(string))<br>  }))</pre> | `null` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | для timeouts нет места :( | <pre>map(object({<br>    availability_zone    = optional(string)<br>    availability_zone_id = optional(string)<br><br>    cidr_block = optional(string)<br><br>    map_public_ip_on_launch = optional(bool) # Default: false<br><br>    network_acl_inbound_rules  = optional(list(string))<br>    network_acl_outbound_rules = optional(list(string))<br>  }))</pre> | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A mapping of tags which should be assigned to all module resources | `map(string)` | `{}` | no |
| <a name="input_tf_stack"></a> [tf\_stack](#input\_tf\_stack) | n/a | <pre>object({<br>    client  = string<br>    account = string<br>    region  = string<br>    env     = string<br>    serial  = number<br>  })</pre> | `null` | no |
| <a name="input_vpc_endpoint_type_gateway_ids"></a> [vpc\_endpoint\_type\_gateway\_ids](#input\_vpc\_endpoint\_type\_gateway\_ids) | n/a | `map(string)` | `null` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_enable"></a> [enable](#output\_enable) | ################ |
| <a name="output_network_acls"></a> [network\_acls](#output\_network\_acls) | ###################### |
| <a name="output_route_table"></a> [route\_table](#output\_route\_table) | ##################### |
| <a name="output_security_groups"></a> [security\_groups](#output\_security\_groups) | ######################### |
| <a name="output_subnets"></a> [subnets](#output\_subnets) | ################# |
<!-- END_TF_DOCS -->
<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_aws.peer"></a> [aws.peer](#provider\_aws.peer) | n/a |
| <a name="provider_template"></a> [template](#provider\_template) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_const"></a> [const](#module\_const) | github.com/amilevskiy/const | v0.1.11 |

## Resources

| Name | Type |
|------|------|
| [aws_ec2_transit_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway) | resource |
| [aws_ec2_transit_gateway_peering_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_peering_attachment) | resource |
| [aws_ec2_transit_gateway_peering_attachment_accepter.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_peering_attachment_accepter) | resource |
| [aws_ec2_transit_gateway_route.peer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ram_principal_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_principal_association) | resource |
| [aws_ram_resource_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_association) | resource |
| [aws_ram_resource_share.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_share) | resource |
| [template_file.this](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bool2string"></a> [bool2string](#input\_bool2string) | n/a | `map(string)` | <pre>{<br>  "false": "disable",<br>  "true": "enable"<br>}</pre> | no |
| <a name="input_enable"></a> [enable](#input\_enable) | (Optional) Destroy all module resources if false | `bool` | `false` | no |
| <a name="input_env"></a> [env](#input\_env) | (Optional) The name of target environment | `string` | `""` | no |
| <a name="input_name"></a> [name](#input\_name) | (Optional) The component of tag-name | `string` | `""` | no |
| <a name="input_resource_share"></a> [resource\_share](#input\_resource\_share) | n/a | <pre>object({<br>    name = optional(string)<br><br>    allow_external_principals = optional(bool)<br>    follower_principals       = optional(map(string))<br><br>    depends_on_list = list(string)<br>  })</pre> | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A mapping of tags which should be assigned to all module resources | `map(string)` | `{}` | no |
| <a name="input_transit_gateway"></a> [transit\_gateway](#input\_transit\_gateway) | n/a | <pre>object({<br>    name = optional(string)<br><br>    amazon_side_asn = optional(number)<br>    description     = optional(string)<br><br>    enable_auto_accept_shared_attachments  = optional(bool)<br>    enable_default_route_table_association = optional(bool)<br>    enable_default_route_table_propagation = optional(bool)<br>    enable_dns_support                     = optional(bool)<br>    enable_vpn_ecmp_support                = optional(bool)<br><br>    static_routes = optional(map(bool))<br>  })</pre> | `null` | no |
| <a name="input_transit_gateway_peering"></a> [transit\_gateway\_peering](#input\_transit\_gateway\_peering) | n/a | <pre>object({<br>    name = optional(string)<br><br>    peer_account_id                     = optional(string)<br>    peer_region                         = string<br>    peer_transit_gateway_id             = string<br>    peer_transit_gateway_route_table_id = optional(string)<br><br>    static_routes = optional(map(bool))<br>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_enable"></a> [enable](#output\_enable) | https://www.terraform.io/docs/configuration/outputs ################ |
| <a name="output_env"></a> [env](#output\_env) | ############# |
| <a name="output_name"></a> [name](#output\_name) | ############## |
| <a name="output_principal_association"></a> [principal\_association](#output\_principal\_association) | ############################### |
| <a name="output_resource_association"></a> [resource\_association](#output\_resource\_association) | ############################## |
| <a name="output_resource_share"></a> [resource\_share](#output\_resource\_share) | ######################## |
| <a name="output_resource_share_accepter_template"></a> [resource\_share\_accepter\_template](#output\_resource\_share\_accepter\_template) | ########################################## |
| <a name="output_transit_gateway"></a> [transit\_gateway](#output\_transit\_gateway) | ######################### |
<!-- END_TF_DOCS -->
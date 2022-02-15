<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws.follower"></a> [aws.follower](#provider\_aws.follower) | n/a |
| <a name="provider_aws.leader"></a> [aws.leader](#provider\_aws.leader) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_const"></a> [const](#module\_const) | github.com/amilevskiy/const | v0.1.11 |

## Resources

| Name | Type |
|------|------|
| [aws_ec2_transit_gateway_route.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ram_principal_association.leader](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_principal_association) | resource |
| [aws_ram_resource_association.leader](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_association) | resource |
| [aws_ram_resource_share.leader](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_share) | resource |
| [aws_ram_resource_share_accepter.follower](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_share_accepter) | resource |
| [aws_caller_identity.follower](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_ec2_transit_gateway.leader](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ec2_transit_gateway) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enable"></a> [enable](#input\_enable) | (Optional) Destroy all module resources if false | `bool` | `false` | no |
| <a name="input_env"></a> [env](#input\_env) | (Optional) The name of target environment | `string` | `""` | no |
| <a name="input_follower_principal"></a> [follower\_principal](#input\_follower\_principal) | n/a | `string` | `null` | no |
| <a name="input_leader_allow_external_principals"></a> [leader\_allow\_external\_principals](#input\_leader\_allow\_external\_principals) | n/a | `bool` | `true` | no |
| <a name="input_leader_resource_arn"></a> [leader\_resource\_arn](#input\_leader\_resource\_arn) | n/a | `string` | `null` | no |
| <a name="input_leader_resource_share_name"></a> [leader\_resource\_share\_name](#input\_leader\_resource\_share\_name) | n/a | `string` | `""` | no |
| <a name="input_leader_resource_share_tag_name"></a> [leader\_resource\_share\_tag\_name](#input\_leader\_resource\_share\_tag\_name) | n/a | `string` | `""` | no |
| <a name="input_leader_tgw_id"></a> [leader\_tgw\_id](#input\_leader\_tgw\_id) | n/a | `string` | `"tgw-06773499e1535c4e9"` | no |
| <a name="input_name"></a> [name](#input\_name) | (Optional) The component of tag-name | `string` | `""` | no |
| <a name="input_routes"></a> [routes](#input\_routes) | n/a | `map(list(string))` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A mapping of tags which should be assigned to all module resources | `map(string)` | `{}` | no |
| <a name="input_transit_gateway_route_table_id"></a> [transit\_gateway\_route\_table\_id](#input\_transit\_gateway\_route\_table\_id) | n/a | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_enable"></a> [enable](#output\_enable) | ################ |
| <a name="output_env"></a> [env](#output\_env) | ############# |
| <a name="output_follower_resource_share_accepter"></a> [follower\_resource\_share\_accepter](#output\_follower\_resource\_share\_accepter) | ########################################## |
| <a name="output_leader_principal_association"></a> [leader\_principal\_association](#output\_leader\_principal\_association) | ###################################### |
| <a name="output_leader_resource_association"></a> [leader\_resource\_association](#output\_leader\_resource\_association) | ##################################### |
| <a name="output_leader_resource_share"></a> [leader\_resource\_share](#output\_leader\_resource\_share) | ############################### |
| <a name="output_name"></a> [name](#output\_name) | ############## |
| <a name="output_transit_gateway"></a> [transit\_gateway](#output\_transit\_gateway) | ######################### |
<!-- END_TF_DOCS -->
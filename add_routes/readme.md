<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_route.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_tables.theese](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route_tables) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cidr_blocks"></a> [cidr\_blocks](#input\_cidr\_blocks) | n/a | `list(string)` | `[]` | no |
| <a name="input_enable"></a> [enable](#input\_enable) | (Optional) Destroy all module resources if false | `bool` | `false` | no |
| <a name="input_transit_gateway_id"></a> [transit\_gateway\_id](#input\_transit\_gateway\_id) | n/a | `string` | `null` | no |
| <a name="input_vpc_ids"></a> [vpc\_ids](#input\_vpc\_ids) | n/a | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_enable"></a> [enable](#output\_enable) | ################ |
| <a name="output_routes"></a> [routes](#output\_routes) | ################ |
<!-- END_TF_DOCS -->
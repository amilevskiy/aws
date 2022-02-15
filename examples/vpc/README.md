<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_central"></a> [central](#module\_central) | github.com/amilevskiy/aws//vpc | v0.0.13 |
| <a name="module_const"></a> [const](#module\_const) | github.com/amilevskiy/const | v0.1.11 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_profile"></a> [aws\_profile](#input\_aws\_profile) | The profile name to access in AWS (optional). | `string` | `""` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region. Default - Frankfurt (eu-central-1). | `string` | `"eu-central-1"` | no |
| <a name="input_enable"></a> [enable](#input\_enable) | Destroy all module resources if false (optional). | `bool` | `false` | no |
| <a name="input_env"></a> [env](#input\_env) | The prefix for all environments [e.g. IPUMB, CORE, etc.] (required). | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_availability_zone_ids"></a> [availability\_zone\_ids](#output\_availability\_zone\_ids) | ############################### |
| <a name="output_availability_zones"></a> [availability\_zones](#output\_availability\_zones) | ############################ |
| <a name="output_subnets"></a> [subnets](#output\_subnets) | ################# |
| <a name="output_vpc"></a> [vpc](#output\_vpc) | ############# |
<!-- END_TF_DOCS -->
<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_const"></a> [const](#module\_const) | github.com/amilevskiy/const | v0.1.11 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_min_ipv4_prefix"></a> [aws\_min\_ipv4\_prefix](#input\_aws\_min\_ipv4\_prefix) | n/a | `number` | `28` | no |
| <a name="input_awscli_args"></a> [awscli\_args](#input\_awscli\_args) | (Optional) The AWS CLI arguments [e.g. --profile DEVOPS] | `string` | `"no"` | no |
| <a name="input_enable"></a> [enable](#input\_enable) | (Optional) Destroy all module resources if false | `bool` | `false` | no |
| <a name="input_env"></a> [env](#input\_env) | (Optional) The name of target environment | `string` | `""` | no |
| <a name="input_hosts"></a> [hosts](#input\_hosts) | n/a | `map(number)` | <pre>{<br>  "k8s": 1024,<br>  "lb": 16,<br>  "misc": 512,<br>  "public": 32,<br>  "secured": 16<br>}</pre> | no |
| <a name="input_label"></a> [label](#input\_label) | The labels for created resources | `map(string)` | <pre>{<br>  "default": "default",<br>  "k8s": "k8s",<br>  "lb": "lb",<br>  "misc": "misc",<br>  "public": "public",<br>  "secured": "secured"<br>}</pre> | no |
| <a name="input_max_ipv4_prefix"></a> [max\_ipv4\_prefix](#input\_max\_ipv4\_prefix) | n/a | `number` | `32` | no |
| <a name="input_name"></a> [name](#input\_name) | (Optional) The component of tag-name | `string` | `""` | no |
| <a name="input_prefix_length"></a> [prefix\_length](#input\_prefix\_length) | n/a | `number` | n/a | yes |
| <a name="input_subnet_cidr_blocks"></a> [subnet\_cidr\_blocks](#input\_subnet\_cidr\_blocks) | n/a | `list(string)` | n/a | yes |
| <a name="input_subnets_order"></a> [subnets\_order](#input\_subnets\_order) | n/a | `list(string)` | <pre>[<br>  "k8s",<br>  "misc",<br>  "public",<br>  "lb",<br>  "secured"<br>]</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A mapping of tags which should be assigned to all module resources | `map(string)` | `{}` | no |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cidr"></a> [cidr](#output\_cidr) | ############## |
| <a name="output_enable"></a> [enable](#output\_enable) | ################ |
| <a name="output_env"></a> [env](#output\_env) | ############# |
| <a name="output_free_cidrs"></a> [free\_cidrs](#output\_free\_cidrs) | #################### |
| <a name="output_result"></a> [result](#output\_result) | ################ |
| <a name="output_subnet_cidr_blocks"></a> [subnet\_cidr\_blocks](#output\_subnet\_cidr\_blocks) | ############################ |
| <a name="output_subnet_cidrs"></a> [subnet\_cidrs](#output\_subnet\_cidrs) | #################### |
| <a name="output_vpc_cidr_block"></a> [vpc\_cidr\_block](#output\_vpc\_cidr\_block) | ######################## |
| <a name="output_vpc_cidrs"></a> [vpc\_cidrs](#output\_vpc\_cidrs) | ################### |
<!-- END_TF_DOCS -->
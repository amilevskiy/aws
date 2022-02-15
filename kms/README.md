<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_aws.replica"></a> [aws.replica](#provider\_aws.replica) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_const"></a> [const](#module\_const) | github.com/amilevskiy/const | v0.1.11 |

## Resources

| Name | Type |
|------|------|
| [aws_kms_alias.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_alias.replica](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_replica_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_replica_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bypass_policy_lockout_safety_check"></a> [bypass\_policy\_lockout\_safety\_check](#input\_bypass\_policy\_lockout\_safety\_check) | n/a | `bool` | `null` | no |
| <a name="input_customer_master_key_spec"></a> [customer\_master\_key\_spec](#input\_customer\_master\_key\_spec) | n/a | `string` | `null` | no |
| <a name="input_deletion_window_in_days"></a> [deletion\_window\_in\_days](#input\_deletion\_window\_in\_days) | n/a | `number` | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | n/a | `string` | `null` | no |
| <a name="input_enable"></a> [enable](#input\_enable) | Destroy all module resources if false (optional). | `bool` | `false` | no |
| <a name="input_enable_key_rotation"></a> [enable\_key\_rotation](#input\_enable\_key\_rotation) | n/a | `bool` | `null` | no |
| <a name="input_key_usage"></a> [key\_usage](#input\_key\_usage) | n/a | `string` | `null` | no |
| <a name="input_multi_region"></a> [multi\_region](#input\_multi\_region) | n/a | `bool` | `null` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | n/a | `string` | `""` | no |
| <a name="input_policy"></a> [policy](#input\_policy) | n/a | `string` | `null` | no |
| <a name="input_replica_policy"></a> [replica\_policy](#input\_replica\_policy) | n/a | `string` | `null` | no |
| <a name="input_replica_word"></a> [replica\_word](#input\_replica\_word) | n/a | `string` | `"replica"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A mapping of tags which should be assigned to all module resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_enable"></a> [enable](#output\_enable) | ################ |
| <a name="output_kms_alias"></a> [kms\_alias](#output\_kms\_alias) | ################### |
| <a name="output_kms_key"></a> [kms\_key](#output\_kms\_key) | ################# |
| <a name="output_kms_replica_alias"></a> [kms\_replica\_alias](#output\_kms\_replica\_alias) | ########################### |
| <a name="output_kms_replica_key"></a> [kms\_replica\_key](#output\_kms\_replica\_key) | ######################### |
<!-- END_TF_DOCS -->
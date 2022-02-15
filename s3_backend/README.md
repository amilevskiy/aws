<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |
| <a name="provider_template"></a> [template](#provider\_template) | n/a |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_const"></a> [const](#module\_const) | github.com/amilevskiy/const | v0.1.11 |

## Resources

| Name | Type |
|------|------|
| [null_resource.backend](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [template_file.this](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [terraform_remote_state.this](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backend_account_id"></a> [backend\_account\_id](#input\_backend\_account\_id) | The account\_id where stored in S3 bootstrap state (optional). | `string` | `"226896994788"` | no |
| <a name="input_backend_filename"></a> [backend\_filename](#input\_backend\_filename) | The name of local file that will plan storing configuration (optional). | `string` | `""` | no |
| <a name="input_bucket"></a> [bucket](#input\_bucket) | S3 bucket where stored bootstrap state (optional). | `string` | `""` | no |
| <a name="input_default_bucket_suffix"></a> [default\_bucket\_suffix](#input\_default\_bucket\_suffix) | n/a | `string` | `"networking"` | no |
| <a name="input_default_directory_prefix"></a> [default\_directory\_prefix](#input\_default\_directory\_prefix) | n/a | `string` | `"010"` | no |
| <a name="input_enable"></a> [enable](#input\_enable) | Flag to enable module (optional). | `bool` | `true` | no |
| <a name="input_key"></a> [key](#input\_key) | S3 path where stored bootstrap state (optional). | `string` | `""` | no |
| <a name="input_key_suffix"></a> [key\_suffix](#input\_key\_suffix) | S3 path to substitute in backend template (optional). | `string` | `""` | no |
| <a name="input_profile"></a> [profile](#input\_profile) | The AWS cli profile name to access to S3 bootstrap state (optional). | `string` | `""` | no |
| <a name="input_region"></a> [region](#input\_region) | The region where stored in S3 bootstrap state (optional). | `string` | `""` | no |
| <a name="input_role_arn"></a> [role\_arn](#input\_role\_arn) | The IAM role to access to S3 bootstrap state (optional). | `string` | `""` | no |
| <a name="input_skip_credentials_validation"></a> [skip\_credentials\_validation](#input\_skip\_credentials\_validation) | https://www.terraform.io/docs/language/settings/backends/s3.html#skip_credentials_validation | `bool` | `true` | no |
| <a name="input_skip_metadata_api_check"></a> [skip\_metadata\_api\_check](#input\_skip\_metadata\_api\_check) | https://www.terraform.io/docs/language/settings/backends/s3.html#skip_metadata_api_check | `bool` | `true` | no |
| <a name="input_skip_region_validation"></a> [skip\_region\_validation](#input\_skip\_region\_validation) | https://www.terraform.io/docs/language/settings/backends/s3.html#skip_region_validation | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_config"></a> [config](#output\_config) | ################ |
| <a name="output_enable"></a> [enable](#output\_enable) | https://www.terraform.io/docs/configuration/outputs ################ |
| <a name="output_key_suffix"></a> [key\_suffix](#output\_key\_suffix) | #################### |
| <a name="output_local_file"></a> [local\_file](#output\_local\_file) | #################### |
<!-- END_TF_DOCS -->
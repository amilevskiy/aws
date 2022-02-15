<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_aws.main"></a> [aws.main](#provider\_aws.main) | n/a |
| <a name="provider_aws.replica"></a> [aws.replica](#provider\_aws.replica) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_const"></a> [const](#module\_const) | github.com/amilevskiy/const | v0.1.11 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.replica](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.replica](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.replica](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_s3_bucket.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.main_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.replica](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.replica_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_policy.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_policy.main_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_policy.replica](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_policy.replica_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_public_access_block.main_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_public_access_block.replica](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_public_access_block.replica_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.main_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.replica](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.replica_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3_replica](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_region.replica](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | n/a | `string` | `""` | no |
| <a name="input_default_s3_bucket_suffix"></a> [default\_s3\_bucket\_suffix](#input\_default\_s3\_bucket\_suffix) | n/a | `string` | `""` | no |
| <a name="input_enable"></a> [enable](#input\_enable) | Destroy all module resources if false (optional). | `bool` | `false` | no |
| <a name="input_kms_main_key_arn"></a> [kms\_main\_key\_arn](#input\_kms\_main\_key\_arn) | n/a | `string` | `null` | no |
| <a name="input_kms_replica_key_arn"></a> [kms\_replica\_key\_arn](#input\_kms\_replica\_key\_arn) | n/a | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | `""` | no |
| <a name="input_name_suffix"></a> [name\_suffix](#input\_name\_suffix) | n/a | `map(string)` | <pre>{<br>  "main": "",<br>  "main-log": "log",<br>  "replica": "replica",<br>  "replica-log": "replica-log"<br>}</pre> | no |
| <a name="input_replica_role_permissions_boundary"></a> [replica\_role\_permissions\_boundary](#input\_replica\_role\_permissions\_boundary) | n/a | `string` | `null` | no |
| <a name="input_s3_bucket_allowed_services"></a> [s3\_bucket\_allowed\_services](#input\_s3\_bucket\_allowed\_services) | n/a | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A mapping of tags which should be assigned to all module resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_enable"></a> [enable](#output\_enable) | ################ |
| <a name="output_replication_policy"></a> [replication\_policy](#output\_replication\_policy) | ############################ |
| <a name="output_replication_role"></a> [replication\_role](#output\_replication\_role) | ########################## |
| <a name="output_s3_bucket_main"></a> [s3\_bucket\_main](#output\_s3\_bucket\_main) | ######################## |
| <a name="output_s3_bucket_main_log"></a> [s3\_bucket\_main\_log](#output\_s3\_bucket\_main\_log) | ############################ |
| <a name="output_s3_bucket_replica"></a> [s3\_bucket\_replica](#output\_s3\_bucket\_replica) | ########################### |
| <a name="output_s3_bucket_replica_iam_policy"></a> [s3\_bucket\_replica\_iam\_policy](#output\_s3\_bucket\_replica\_iam\_policy) | ###################################### |
| <a name="output_s3_bucket_replica_log"></a> [s3\_bucket\_replica\_log](#output\_s3\_bucket\_replica\_log) | ############################### |
<!-- END_TF_DOCS -->
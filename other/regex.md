# Useful Regex

These are written for VSCode but should work elsewhere with minor tweaking.

#### Convert Terraform variables.tf to terraform.tfvars

|Field      |	Regex |
|-----------|--------|
|Find       |	`variable\s"(.*)"\s.*(.|\n)+?(?=(\nvariable|($(?![\r\n]))))` |
|Replace	|   `$1 =` | 


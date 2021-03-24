# Useful Regex

These are written for VSCode but should work elsewhere with minor tweaking.

#### Convert Terraform variables.tf to terraform.tfvars

|Field      |	Regex |
|-----------|--------|
|Find       |	`variable\s"(.*)"\s.*(.|\n)+?(?=(\nvariable|($(?![\r\n]))))` |
|Replace	|   `$1 =` | 

#### Convert Terraform variables.tf for use in markdown tables |<name>|<description>| 

|Field      |	Regex |
|-----------|--------|
|Find       |	`variable\s"(.*)"\s.*(.|\n)+?description\s=\s"(.*)"(.|\n)+?(?=(\nvariable|($(?![\r\n]))))` |
|Replace	|   `|$1|$3|` | 
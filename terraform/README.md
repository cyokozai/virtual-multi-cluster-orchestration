# Terraform

## Run Terraform commands

- First init: Run `terraform init` with `--backend-config` option.  

    ```shell
    terraform init -backend-config=".tfbackend"
    ```

- n times init: Run `terraform init` with `-backend-config` and `-reconfigure` options.  

    ```shell
    terraform init -reconfigure -backend-config=".tfbackend"
    ```

- Provisioning: Run `terraform plan/apply` with `-var-file` option. 

    ```shell
    terraform plan -var-file=".tfvars"
    ```

    ```shell
    terraform apply -var-file=".tfvars"
    ```

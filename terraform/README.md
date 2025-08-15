# Terraform

## Run Terraform commands

- First init: Run `terraform init` with `--backend-config` option.  

    ```shell
    terraform init -backend-config="<cloud provider>/.tfbackend"
    ```

- n times init: Run `terraform init` with `--backend-config` and `-reconfigure` options.  

    ```shell
    terraform init -reconfigure -backend-config="<cloud provider>/.tfbackend"
    ```

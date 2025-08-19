# Terraform GKE

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
    - Plan  

        ```shell
        terraform plan -var-file="terraform.tfvars"
        ```

    - Apply

        ```shell
        terraform apply -var-file="terraform.tfvars"
        ```

## Install Karmada control plane

- Get Credentials    

    ```shell
    gcloud container clusters get-credentials "$(gcloud container clusters list --format="value(name)" --region="$LOCATION" | head -n 1)" \
      --region="asia-northeast1-a" \
      --project "$(gcloud config get-value project)"
    ```

- Run init command

    ```shell
    kubectl karmada init --karmada-data $HOME/.karmada/data --karmada-pki $HOME/.karmada/pki 
    ```

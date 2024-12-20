#!/bin/bash

# https://github.com/hashicorp/terraform-provider-google/issues/14191 - it is better to keep creation of worload identity pool and OIDC provider outside of terraform scripts
# as they cannot be recreated with the same name, because of soft deletion - can be undeleted for 30 days

# Set variables
PROJECT_ID="petclinic-444616"
POOL_ID="github-actions"
PROVIDER_ID="github-provider"
SERVICE_ACCOUNT_EMAIL="github-actions-petclinic@petclinic-444616.iam.gserviceaccount.com"

gcloud iam workload-identity-pools create github-actions --location="global" --description="Github actions" --display-name="Identity pool for github-actions" --project="petclinic-444616"

gcloud iam workload-identity-pools providers create-oidc github-provider --location="global" --workload-identity-pool="github-actions" --display-name="Github Actions Provider" --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.aud=assertion.aud,attribute.repository=assertion.repository" --attribute-condition="assertion.repository_owner_id == \"192263822\" && attribute.repository == \"Jakub-A-DO/spring-petclinic-devops\" && assertion.ref == \"refs/heads/main\" && assertion.ref_type ==\"branch\" && assertion.actor == \"Jakub-A-DO\"" --issuer-uri="https://token.actions.githubusercontent.com"

gcloud iam workload-identity-pools providers create-oidc github-provider-terraform-main --location="global" --workload-identity-pool="github-actions" --display-name="Github Actions Provider for Terraform" --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.aud=assertion.aud,attribute.repository=assertion.repository" --attribute-condition="assertion.repository_owner_id == \"192263822\" && attribute.repository == \"Jakub-A-DO/petclinic-provisioning-classic\" && assertion.ref == \"refs/heads/main\" && assertion.ref_type ==\"branch\" && assertion.actor == \"Jakub-A-DO\"" --issuer-uri="https://token.actions.githubusercontent.com"

gcloud iam workload-identity-pools providers create-oidc github-provider-terraform-plan --location="global" --workload-identity-pool="github-actions" --display-name="Github Actions Terraform plan" --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.aud=assertion.aud,attribute.repository=assertion.repository" --attribute-condition="assertion.repository_owner_id == \"192263822\" && attribute.repository == \"Jakub-A-DO/petclinic-provisioning-classic\" && assertion.event_name == \"pull_request\"" --issuer-uri="https://token.actions.githubusercontent.com"

POOL_NAME=$(gcloud iam workload-identity-pools describe $POOL_ID \                                    
    --project=$PROJECT_ID \
    --location="global" \
    --format="value(name)")

gcloud iam service-accounts add-iam-policy-binding $SERVICE_ACCOUNT_EMAIL \
    --project="$PROJECT_ID" \
    --role="roles/iam.workloadIdentityUser" \
    --member="principalSet://iam.googleapis.com/${POOL_NAME}/attribute.repository/Jakub-A-DO/spring-petclinic-devops"

echo "Workload Identity Federation setup complete."

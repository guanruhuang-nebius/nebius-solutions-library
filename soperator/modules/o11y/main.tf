resource "terraform_data" "o11y_static_key_secret" {
  triggers_replace = {
    region                           = var.region
    o11y_resources_name              = local.o11y_resources_name
    k8s_cluster_context              = var.k8s_cluster_context
    o11y_iam_tenant_id               = var.o11y_iam_tenant_id
    o11y_secret_name                 = var.o11y_secret_name
    o11y_secret_logs_namespace       = var.o11y_secret_logs_namespace
    o11y_secret_monitoring_namespace = var.o11y_secret_monitoring_namespace
    o11y_profile                     = var.o11y_profile
  }

  provisioner "local-exec" {
    when        = create
    working_dir = path.root
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
set -e

NEBIUS_IAM_TOKEN_BKP=$NEBIUS_IAM_TOKEN
unset NEBIUS_IAM_TOKEN

# Ensuring that profile exists
if ! nebius profile list | grep -Fxq ${self.triggers_replace.o11y_profile}; then
  CURRENT_PROFILE=$(nebius profile current)
  nebius profile create --endpoint api.eu.nebius.cloud --federation-endpoint auth.eu.nebius.com --parent-id ${self.triggers_replace.o11y_iam_tenant_id} ${self.triggers_replace.o11y_profile}
  nebius profile activate $CURRENT_PROFILE
fi
export NEBIUS_IAM_TOKEN=(nebius --profile ${self.triggers_replace.o11y_profile} iam get-access-token)

# Creating new project for cluster logs
echo "Creating new project for cluster logs..."
nebius iam project create --parent-id ${self.triggers_replace.o11y_iam_tenant_id} --name ${self.triggers_replace.o11y_resources_name} || true
PROJECT_ID=$(nebius iam project get-by-name --parent-id ${self.triggers_replace.o11y_iam_tenant_id} --name ${self.triggers_replace.o11y_resources_name} | yq .metadata.id)
echo "Project for logs $PROJECT_ID"

# Saving project id
echo $PROJECT_ID > ${path.root}/o11y_project_id.txt

# Creating group, service account, group-membership and access-permit.
echo "Creating service account..."
nebius iam service-account create --name "${self.triggers_replace.o11y_resources_name}" --parent-id $PROJECT_ID || true
SA=$(nebius iam service-account get-by-name --name "${self.triggers_replace.o11y_resources_name}" --parent-id $PROJECT_ID | yq .metadata.id)
echo "Service account for logs: $SA"

echo "Creating group..."
nebius iam group create --name "${self.triggers_replace.o11y_resources_name}" --parent-id ${self.triggers_replace.o11y_iam_tenant_id} || true
GROUP=$(nebius iam group get-by-name --name "${self.triggers_replace.o11y_resources_name}" --parent-id ${self.triggers_replace.o11y_iam_tenant_id} | yq .metadata.id)

echo "Adding service account to the iam group $GROUP..."
nebius iam group-membership create --member-id $SA --parent-id $GROUP || true
echo "Service account was successfully added to the iam group."

echo "Creating access-permit..."
nebius iam access-permit create --parent-id $GROUP --role logging.logs.writer --resource-id $PROJECT_ID

# Issuing static key and creating k8s secret
echo "Deleting previous static key if exists..."
STATIC_KEY=$(nebius iam static-key get-by-name --parent-id $PROJECT_ID --name ${self.triggers_replace.o11y_resources_name} | yq .metadata.id || true)
if [ ! -z "$STATIC_KEY" ]; then
  echo "Deleting $STATIC_KEY..."
  nebius iam static-key delete --id $STATIC_KEY
fi

echo "Issuing new static key..."
TOKEN=$(nebius iam static-key issue --parent-id $PROJECT_ID \
  --account-service-account-id "$SA" \
  --service observability \
  --name ${self.triggers_replace.o11y_resources_name} | yq .token)

export NEBIUS_IAM_TOKEN=$NEBIUS_IAM_TOKEN_BKP

echo "Applying namespace..."
cat <<EOF | kubectl --context "${self.triggers_replace.k8s_cluster_context}" apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: ${self.triggers_replace.o11y_secret_logs_namespace}
EOF
cat <<EOF | kubectl --context "${self.triggers_replace.k8s_cluster_context}" apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: ${self.triggers_replace.o11y_secret_monitoring_namespace}
EOF

echo "Creating secret..."
if kubectl --context ${self.triggers_replace.k8s_cluster_context} -n logs-system get secret ${self.triggers_replace.o11y_secret_name} >/dev/null 2>&1; then
  echo "Secret exists, deleting..."
  kubectl --context ${self.triggers_replace.k8s_cluster_context} -n logs-system delete secret ${self.triggers_replace.o11y_secret_name}
fi

kubectl --context ${self.triggers_replace.k8s_cluster_context} create secret generic ${self.triggers_replace.o11y_secret_name} \
  -n ${self.triggers_replace.o11y_secret_logs_namespace} \
  --from-literal=accessToken="$TOKEN"
EOT
  }

  provisioner "local-exec" {
    when        = destroy
    working_dir = path.root
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
set -e

unset NEBIUS_IAM_TOKEN
export NEBIUS_IAM_TOKEN=(nebius --profile ${self.triggers_replace.o11y_profile} iam get-access-token)

PROJECT_ID=$(cat ${path.root}/o11y_project_id.txt)

echo "Deleting service account..."
SA=$(nebius iam service-account get-by-name --name "${self.triggers_replace.o11y_resources_name}" --parent-id $PROJECT_ID | yq .metadata.id)
if [ -z $SA ]; then
  nebius iam service-account delete --id $SA
fi

GROUP=$(nebius iam group get-by-name --name "${self.triggers_replace.o11y_resources_name}" --parent-id ${self.triggers_replace.o11y_iam_tenant_id} | yq .metadata.id)
if [ -z $GROUP ]; then
  nebius iam group delete --id $GROUP
fi

EOT
  }
}

data "local_file" "o11y_project_id" {
  filename    = "${path.root}/o11y_project_id.txt"
  depends_on  = [terraform_data.o11y_static_key_secret]
}

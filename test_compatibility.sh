#!/bin/bash

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <postgresql_version> <prisma_version>"
  exit 1
fi

pg_version=$1
prisma_version=$2


# For each combination of the two versions
echo "Testing combination postgresql:$pg_version prisma:$prisma_version"

clusters=$(kind get clusters)
if [[ $clusters == *"prisma"* ]]; then
  echo "Cluster already exists. Moving on..."
else 
  kind create cluster --name prisma
fi

result_dir="./results/$pg_version/$prisma_version"
mkdir -p "$result_dir"

# Update newTag in ./kustomize/kustomization.yaml
sed -i '' "s/newTag: .*/newTag: \"$pg_version\"/" ./kustomize/kustomization.yaml

# Check that there's no trash from a previous test
kubectl delete -k ./kustomize
while kubectl get pvc postgres-storage; do
  sleep 5
done

# Install in cluster
kubectl apply -k ./kustomize

# Check if postgresql is ready to accept connections
echo "Waiting for postgresql to be ready"
while ! kubectl exec deployments/postgresql -- bash -c "pg_isready -U johndoe -d mydb"; do
  sleep 5
done

# Start port-forward in the background
kubectl port-forward svc/postgresql 5432:5432 &
# Save the port-forward PID to kill it later
PORT_FORWARD_PID=$!

rm -rf ./prisma

npx -y prisma@$prisma_version init

cat models.txt >> ./prisma/schema.prisma

# Run `npx prisma@<prisma_version> migrate dev --name init > ./results/<postgresql_version>/<prisma_version>/migrate_dev_init`
DEBUG="*" npx prisma@$prisma_version migrate dev --name init > "$result_dir/migrate_dev_init"

# Check that the tables are created
echo "Checking that the tables are created"
kubectl exec deployments/postgresql -- bash -c "psql -U johndoe -d mydb -t -A -c '\dt'" > "$result_dir/tables"

table_check_output=$(cat "$result_dir/tables")
if [[ $table_check_output == *"User"* ]] && [[ $table_check_output == *"Post"* ]]; then
  echo "Tables are created"
  echo $table_check_output > "$result_dir/tables"
  echo success > "$result_dir/result"
else
  echo "Tables are not created"
  echo $table_check_output > "$result_dir/tables"
  echo "failure" > "$result_dir/result"
fi

# Run `kubectl logs deployment/postgresql > ./results/<postgresql_version>/<prisma_version>/postgresql_logs`
kubectl logs deployment/postgresql > "$result_dir/postgresql_logs"

# Stop the port-forward
trap "kill $PORT_FORWARD_PID" EXIT

# Remove all resources from the cluster
kubectl delete -k ./kustomize

# Wait for the PVC to be deleted
echo "Waiting for PVC to be deleted"
while kubectl get pvc postgres-storage; do
  sleep 5
done
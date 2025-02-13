# Define the path to the kustomization overlay
kustomize_overlay_path = './kustomize'

# Use the kustomize function to apply the kustomization overlay
k8s_yaml(kustomize(kustomize_overlay_path))

# Get a port to postgresql
k8s_resource(workload='postgresql', port_forwards=5432)

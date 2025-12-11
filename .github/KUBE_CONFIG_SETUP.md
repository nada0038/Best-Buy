# Kubernetes Configuration Setup for GitHub Actions

This document explains how to set up the `KUBE_CONFIG` secret in GitHub Actions for deploying to Azure Kubernetes Service (AKS).

## Prerequisites

1. An Azure Kubernetes Service (AKS) cluster
2. Azure CLI installed locally
3. `kubectl` configured to access your AKS cluster

## Step 1: Get Your Kubernetes Config

### Option A: Using Azure CLI (Recommended)

```bash
# Login to Azure
az login

# Get credentials for your AKS cluster
az aks get-credentials --resource-group <your-resource-group> --name <your-aks-cluster-name>

# Export the kubeconfig
kubectl config view --flatten > kubeconfig.txt
```

### Option B: Direct from kubectl

If you already have kubectl configured:

```bash
# Export current kubeconfig
kubectl config view --flatten > kubeconfig.txt
```

### Option C: From AKS Portal

1. Go to Azure Portal → Your AKS Cluster
2. Click "Connect" in the overview
3. Copy the `az aks get-credentials` command
4. Run it locally to get the config

## Step 2: Encode the Config to Base64

```bash
# On Linux/Mac
base64 -i kubeconfig.txt -o kubeconfig.b64

# On Windows PowerShell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("kubeconfig.txt")) | Out-File -Encoding ASCII kubeconfig.b64

# Or using certutil (Windows)
certutil -encode kubeconfig.txt kubeconfig.b64
```

## Step 3: Add Secret to GitHub

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Name: `KUBE_CONFIG`
5. Value: Paste the base64-encoded content from `kubeconfig.b64`
6. Click **Add secret**

## Step 4: Verify the Setup

The workflow will automatically:
- Decode the `KUBE_CONFIG` secret
- Write it to a temporary file
- Set `KUBECONFIG` environment variable
- Use it to connect to your AKS cluster

## Security Best Practices

1. **Never commit kubeconfig files** to your repository
2. **Use GitHub Secrets** to store sensitive configuration
3. **Rotate credentials** periodically
4. **Use service accounts** with minimal required permissions
5. **Enable RBAC** in your Kubernetes cluster

## Troubleshooting

### Issue: "Unable to connect to the server"

**Solution:**
- Verify your AKS cluster is running
- Check that the kubeconfig is valid and not expired
- Ensure the base64 encoding was done correctly

### Issue: "Forbidden" errors

**Solution:**
- Check RBAC permissions for the service account
- Verify the kubeconfig has the correct permissions
- Ensure the namespace exists: `kubectl create namespace bestbuy`

### Issue: Base64 encoding problems

**Solution:**
- Make sure there are no line breaks in the base64 string
- Verify the encoding includes the entire file content
- Try re-encoding the kubeconfig file

## Alternative: Using Azure Service Principal

For more secure access, you can use Azure Service Principal instead:

```yaml
- name: Azure Login
  uses: azure/login@v1
  with:
    creds: ${{ secrets.AZURE_CREDENTIALS }}

- name: Set up kubectl
  uses: azure/setup-kubectl@v3

- name: Get AKS credentials
  run: |
    az aks get-credentials --resource-group ${{ secrets.AZURE_RG }} --name ${{ secrets.AKS_CLUSTER_NAME }}
```

This approach doesn't require storing the kubeconfig file.

## Workflow Files

This repository includes two workflow files:

1. **`.github/workflows/deploy-to-kubernetes.yml`** - Manual deployment workflow
   - Can be triggered manually
   - Allows selecting specific services to deploy
   - Uses `KUBE_CONFIG` secret

2. **`.github/workflows/ci-cd-with-k8s-deploy.yml`** - Full CI/CD pipeline
   - Builds Docker images
   - Pushes to Docker Hub
   - Deploys to Kubernetes
   - Uses `KUBE_CONFIG` secret

Both workflows require the `KUBE_CONFIG` secret to be set up as described above.


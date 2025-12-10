# Azure Kubernetes Service (AKS) Setup Instructions

This guide will walk you through creating an AKS cluster on Azure for deploying the Best Buy microservices application.

## Prerequisites

1. **Azure Account**: You need an active Azure subscription (Student subscription works)
2. **Azure CLI**: Install the Azure CLI from [here](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
3. **kubectl**: Install kubectl from [here](https://kubernetes.io/docs/tasks/tools/)

## Step 1: Login to Azure

```bash
az login
```

This will open a browser window for you to authenticate. After successful login, verify your subscription:

```bash
az account show
```

If you have multiple subscriptions, set the active one:

```bash
az account list --output table
az account set --subscription "<subscription-id>"
```

## Step 2: Create a Resource Group

Create a resource group to organize your AKS cluster and related resources:

```bash
az group create --name bestbuy-rg --location eastus
```

*Note: You can change the location to one closer to you. Common locations: `eastus`, `westus2`, `westeurope`, `southeastasia`*

## Step 3: Create AKS Cluster

Create the AKS cluster with the following command:

```bash
az aks create \
  --resource-group bestbuy-rg \
  --name bestbuy-aks \
  --node-count 2 \
  --node-vm-size Standard_B2s \
  --enable-managed-identity \
  --generate-ssh-keys
```

**Parameters explained:**
- `--resource-group`: The resource group created in Step 2
- `--name`: Name of your AKS cluster
- `--node-count`: Number of nodes in the node pool (2 is minimum for high availability)
- `--node-vm-size`: VM size for nodes (Standard_B2s is good for student subscriptions - 2 vCPUs, 4GB RAM)
- `--enable-managed-identity`: Uses managed identity for authentication (recommended)
- `--generate-ssh-keys`: Generates SSH keys if not present

**Note**: This process takes approximately 10-15 minutes.

### Alternative: Using Azure Portal

If you prefer using the Azure Portal:

1. Go to [Azure Portal](https://portal.azure.com)
2. Click "Create a resource"
3. Search for "Kubernetes Service"
4. Click "Create"
5. Fill in the details:
   - **Resource group**: Create new or select existing
   - **Cluster name**: `bestbuy-aks`
   - **Region**: Choose a region close to you
   - **Kubernetes version**: Use the default (latest stable)
   - **Node size**: Standard_B2s
   - **Node count**: 2
6. Click "Review + create", then "Create"

## Step 4: Install kubectl (if not already installed)

If kubectl is not installed, install it:

**Windows (using Chocolatey):**
```powershell
choco install kubernetes-cli
```

**macOS:**
```bash
brew install kubectl
```

**Linux:**
```bash
az aks install-cli
```

## Step 5: Connect to Your Cluster

Get credentials for your AKS cluster:

```bash
az aks get-credentials --resource-group bestbuy-rg --name bestbuy-aks
```

Verify the connection:

```bash
kubectl get nodes
```

You should see 2 nodes in "Ready" state.

## Step 6: Verify Cluster Access

Test that you can access your cluster:

```bash
kubectl cluster-info
kubectl get namespaces
```

## Step 7: Install Required Tools (Optional but Recommended)

### Install Helm (Package Manager for Kubernetes)

**Windows:**
```powershell
choco install kubernetes-helm
```

**macOS:**
```bash
brew install helm
```

**Linux:**
```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

## Step 8: Configure kubectl for GitHub Actions (For CI/CD)

If you want to enable automatic deployment from GitHub Actions, you'll need to get the kubeconfig:

```bash
# Get kubeconfig and encode it
az aks get-credentials --resource-group bestbuy-rg --name bestbuy-aks --admin
kubectl config view --minify --raw | base64
```

Save this base64-encoded string as a GitHub secret named `KUBE_CONFIG_DATA` in your repository settings.

## Cost Optimization Tips

1. **Use Spot Instances**: For development, you can use spot instances to save costs
   ```bash
   az aks nodepool add \
     --resource-group bestbuy-rg \
     --cluster-name bestbuy-aks \
     --name spotpool \
     --node-count 1 \
     --node-vm-size Standard_B2s \
     --priority Spot \
     --eviction-policy Delete \
     --spot-max-price -1
   ```

2. **Scale Down When Not in Use**: Stop or scale down your cluster when not actively working
   ```bash
   # Scale down to 0 nodes (cluster still exists, just no compute)
   az aks scale --resource-group bestbuy-rg --name bestbuy-aks --node-count 0
   
   # Scale back up when needed
   az aks scale --resource-group bestbuy-rg --name bestbuy-aks --node-count 2
   ```

3. **Delete Cluster When Done**: Always delete resources when finished to avoid charges
   ```bash
   az aks delete --resource-group bestbuy-rg --name bestbuy-aks
   az group delete --name bestbuy-rg --yes --no-wait
   ```

## Troubleshooting

### Issue: "Insufficient quota" error

**Solution**: Your subscription may have limits. Try:
- Using a smaller VM size (Standard_B1s instead of B2s)
- Reducing node count to 1
- Requesting a quota increase in Azure Portal

### Issue: Cluster creation fails

**Solution**: 
- Check Azure Service Health
- Verify you have sufficient permissions
- Try a different region

### Issue: Cannot connect with kubectl

**Solution**:
```bash
# Re-authenticate
az login
az account set --subscription "<subscription-id>"
az aks get-credentials --resource-group bestbuy-rg --name bestbuy-aks --overwrite-existing
```

## Next Steps

After setting up your AKS cluster:

1. Follow the deployment instructions in [README.md](README.md)
2. Deploy the application using the manifests in the `Deployment Files/` directory
3. Set up CI/CD pipelines (see README.md for details)

## Useful Commands

```bash
# View cluster details
az aks show --resource-group bestbuy-rg --name bestbuy-aks

# Upgrade cluster
az aks upgrade --resource-group bestbuy-rg --name bestbuy-aks --kubernetes-version <version>

# View cluster logs
az aks get-credentials --resource-group bestbuy-rg --name bestbuy-aks
kubectl get events --sort-by='.lastTimestamp' -n bestbuy

# Delete cluster (when done)
az aks delete --resource-group bestbuy-rg --name bestbuy-aks --yes
```

## Additional Resources

- [AKS Documentation](https://docs.microsoft.com/en-us/azure/aks/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Azure CLI Reference](https://docs.microsoft.com/en-us/cli/azure/aks)


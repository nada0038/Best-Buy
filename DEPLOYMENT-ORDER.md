# Deployment Order - Step by Step

Here's the correct order to follow for your Best Buy project:

## ✅ Step 1: Build and Push Docker Images (Do This First)

**Why first?** The Kubernetes deployment needs the Docker images to exist on Docker Hub.

1. **Login to Docker Hub:**
   ```powershell
   docker login
   ```

2. **Build and push all images:**
   ```powershell
   .\build-all-images.ps1
   ```

3. **Verify images exist:**
   - Check: https://hub.docker.com/u/nada0038
   - Or test: `docker pull nada0038/store-front-bestbuy:latest`

**Time needed:** 15-30 minutes (depending on your internet speed)

---

## ✅ Step 2: Create AKS Cluster (Kubernetes)

**Why second?** You need a Kubernetes cluster to deploy to. AKS is Azure's managed Kubernetes service.

1. **Install Azure CLI** (if not installed):
   ```powershell
   winget install -e --id Microsoft.AzureCLI
   ```

2. **Login to Azure:**
   ```powershell
   az login
   ```

3. **Create Resource Group:**
   ```powershell
   az group create --name bestbuy-rg --location eastus
   ```

4. **Create AKS Cluster:**
   ```powershell
   az aks create --resource-group bestbuy-rg --name bestbuy-aks --node-count 2 --node-vm-size Standard_B2s --enable-managed-identity --generate-ssh-keys
   ```

5. **Connect kubectl to your cluster:**
   ```powershell
   az aks get-credentials --resource-group bestbuy-rg --name bestbuy-aks
   ```

6. **Verify connection:**
   ```powershell
   kubectl get nodes
   ```

**Time needed:** 10-15 minutes (cluster creation)

---

## ✅ Step 3: Deploy to Kubernetes

**Why last?** You need both Docker images AND the Kubernetes cluster ready.

1. **Navigate to Deployment Files:**
   ```powershell
   cd "Deployment Files"
   ```

2. **Deploy in order:**
   ```powershell
   # Create namespace and secrets first
   kubectl apply -f 01-namespace.yaml
   kubectl apply -f 05-secrets.yaml
   kubectl apply -f 04-configmaps.yaml
   
   # Deploy infrastructure (MongoDB, RabbitMQ)
   kubectl apply -f 02-mongodb-statefulset.yaml
   kubectl apply -f 03-rabbitmq-deployment.yaml
   
   # Wait for infrastructure to be ready
   kubectl wait --for=condition=ready pod -l app=mongodb -n bestbuy --timeout=300s
   kubectl wait --for=condition=ready pod -l app=rabbitmq -n bestbuy --timeout=300s
   
   # Deploy microservices
   kubectl apply -f 06-product-service.yaml
   kubectl apply -f 07-order-service.yaml
   kubectl apply -f 08-makeline-service.yaml
   kubectl apply -f 09-store-front.yaml
   kubectl apply -f 10-store-admin.yaml
   ```

3. **Check status:**
   ```powershell
   kubectl get pods -n bestbuy
   kubectl get services -n bestbuy
   ```

**Time needed:** 5-10 minutes (deployment)

---

## Summary: Order of Operations

```
1. Build Docker Images → Push to Docker Hub
   ↓
2. Create AKS Cluster (Kubernetes)
   ↓
3. Deploy to Kubernetes
   ↓
4. Test & Demo
```

## Important Notes

- **You DON'T need to install Kubernetes locally** - AKS provides the Kubernetes cluster in the cloud
- **Docker images must exist BEFORE deployment** - otherwise you'll get 404 errors
- **You can do Step 1 and Step 2 in parallel** if you want, but Step 3 needs both to be complete

## Quick Checklist

- [ ] Docker images built and pushed to Docker Hub
- [ ] Azure CLI installed and logged in
- [ ] AKS cluster created
- [ ] kubectl connected to cluster
- [ ] All Kubernetes manifests deployed
- [ ] Services accessible via LoadBalancer IPs

## Troubleshooting

### "ImagePullBackOff" error
→ Docker images don't exist yet. Go back to Step 1.

### "kubectl: command not found"
→ Install kubectl or use: `az aks install-cli`

### "Resource group not found"
→ Make sure you created the resource group in Step 2.

### "Cluster not found"
→ Make sure the AKS cluster was created successfully in Step 2.


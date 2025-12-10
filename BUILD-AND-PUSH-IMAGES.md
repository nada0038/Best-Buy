# Building and Pushing Docker Images

The Docker images need to be built and pushed to Docker Hub before they can be used in Kubernetes. You have two options:

## Option 1: Use CI/CD (Recommended - Automatic)

The GitHub Actions workflows will automatically build and push images when you push code to the `main` branch. To set this up:

### Step 1: Add GitHub Secrets

For each repository (store-front-bestbuy, store-admin-bestbuy, order-service-bestbuy, product-service-bestbuy, makeline-service-bestbuy):

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add these secrets:
   - **Name**: `DOCKERHUB_USERNAME`
   - **Value**: `nada0038`
   
   - **Name**: `DOCKERHUB_TOKEN`
   - **Value**: (Your Docker Hub access token - see below)

### Step 2: Get Docker Hub Access Token

1. Go to [Docker Hub](https://hub.docker.com/)
2. Sign in with your account (nada0038)
3. Click on your profile → **Account Settings**
4. Go to **Security** → **New Access Token**
5. Create a token with **Read & Write** permissions
6. Copy the token (you'll only see it once!)

### Step 3: Push Code to Trigger CI/CD

Once secrets are added, push your code to the `main` branch:

```bash
cd store-front-bestbuy
git add .
git commit -m "Initial commit"
git push origin main
```

Repeat for each service. The CI/CD pipeline will automatically build and push the images.

## Option 2: Build and Push Manually

If you want to build and push images manually, follow these steps:

### Prerequisites

1. Docker installed and running
2. Logged into Docker Hub:
   ```bash
   docker login
   # Enter your Docker Hub username (nada0038) and password
   ```

### Build and Push Each Service

#### 1. Store-Front

```bash
cd store-front-bestbuy
docker build -t nada0038/store-front-bestbuy:latest .
docker push nada0038/store-front-bestbuy:latest
```

#### 2. Store-Admin

```bash
cd store-admin-bestbuy
docker build -t nada0038/store-admin-bestbuy:latest .
docker push nada0038/store-admin-bestbuy:latest
```

#### 3. Order-Service

```bash
cd order-service-bestbuy
docker build -t nada0038/order-service-bestbuy:latest .
docker push nada0038/order-service-bestbuy:latest
```

#### 4. Product-Service

```bash
cd product-service-bestbuy
docker build -t nada0038/product-service-bestbuy:latest .
docker push nada0038/product-service-bestbuy:latest
```

#### 5. Makeline-Service

```bash
cd makeline-service-bestbuy
docker build -t nada0038/makeline-service-bestbuy:latest .
docker push nada0038/makeline-service-bestbuy:latest
```

### Verify Images

After pushing, verify the images exist:

```bash
# Check on Docker Hub website
# Or use Docker CLI
docker pull nada0038/store-front-bestbuy:latest
docker pull nada0038/store-admin-bestbuy:latest
docker pull nada0038/order-service-bestbuy:latest
docker pull nada0038/product-service-bestbuy:latest
docker pull nada0038/makeline-service-bestbuy:latest
```

## Troubleshooting

### Error: "denied: requested access to the resource is denied"

**Solution**: Make sure you're logged into Docker Hub:
```bash
docker login
```

### Error: "repository does not exist"

**Solution**: Docker Hub will automatically create the repository when you push the first image. Just make sure the image name matches your Docker Hub username.

### Error: "unauthorized: authentication required"

**Solution**: 
1. Check your Docker Hub credentials
2. If using access token, make sure it has Read & Write permissions
3. Try logging out and logging back in:
   ```bash
   docker logout
   docker login
   ```

## Quick Build Script (Windows PowerShell)

Create a file `build-all-images.ps1` in the root directory:

```powershell
# Build and Push All Images
$services = @("store-front-bestbuy", "store-admin-bestbuy", "order-service-bestbuy", "product-service-bestbuy", "makeline-service-bestbuy")

foreach ($service in $services) {
    Write-Host "Building $service..." -ForegroundColor Green
    Set-Location $service
    docker build -t "nada0038/$($service):latest" .
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Pushing $service..." -ForegroundColor Yellow
        docker push "nada0038/$($service):latest"
        if ($LASTEXITCODE -eq 0) {
            Write-Host "$service pushed successfully!" -ForegroundColor Green
        } else {
            Write-Host "$service push failed!" -ForegroundColor Red
        }
    } else {
        Write-Host "$service build failed!" -ForegroundColor Red
    }
    Set-Location ..
    Write-Host ""
}
```

Run it with:
```powershell
.\build-all-images.ps1
```

## Quick Build Script (Linux/Mac Bash)

Create a file `build-all-images.sh` in the root directory:

```bash
#!/bin/bash

services=("store-front-bestbuy" "store-admin-bestbuy" "order-service-bestbuy" "product-service-bestbuy" "makeline-service-bestbuy")

for service in "${services[@]}"; do
    echo "Building $service..."
    cd "$service"
    docker build -t "nada0038/$service:latest" .
    if [ $? -eq 0 ]; then
        echo "Pushing $service..."
        docker push "nada0038/$service:latest"
        if [ $? -eq 0 ]; then
            echo "$service pushed successfully!"
        else
            echo "$service push failed!"
        fi
    else
        echo "$service build failed!"
    fi
    cd ..
    echo ""
done
```

Make it executable and run:
```bash
chmod +x build-all-images.sh
./build-all-images.sh
```

## Next Steps

After building and pushing all images:

1. Verify images exist on Docker Hub: https://hub.docker.com/u/nada0038
2. Deploy to Kubernetes using the manifests in `Deployment Files/`
3. The images should now be accessible and won't show 404 errors


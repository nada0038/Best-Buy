# Update Kubernetes Deployments with New Docker Images
# This script restarts the deployments to pull the latest images

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Updating Kubernetes Deployments" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Update the three services that changed
$deployments = @(
    "product-service",
    "store-front", 
    "store-admin"
)

foreach ($deployment in $deployments) {
    Write-Host "Updating $deployment..." -ForegroundColor Yellow
    
    # Force Kubernetes to pull the latest image
    kubectl rollout restart deployment/$deployment -n bestbuy
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "$deployment restart initiated!" -ForegroundColor Green
        
        # Wait for rollout to complete
        Write-Host "Waiting for $deployment to be ready..." -ForegroundColor Yellow
        kubectl rollout status deployment/$deployment -n bestbuy --timeout=300s
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "$deployment updated successfully!" -ForegroundColor Green
        } else {
            Write-Host "$deployment update timed out or failed!" -ForegroundColor Red
        }
    } else {
        Write-Host "$deployment restart failed!" -ForegroundColor Red
    }
    
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Checking deployment status..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
kubectl get pods -n bestbuy
kubectl get services -n bestbuy


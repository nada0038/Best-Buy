# Build and Push All Docker Images for Best Buy Project
# Make sure you're logged into Docker Hub: docker login

$services = @("store-front-bestbuy", "store-admin-bestbuy", "order-service-bestbuy", "product-service-bestbuy", "makeline-service-bestbuy")
$dockerHubUser = "nada0038"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Building and Pushing Docker Images" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

foreach ($service in $services) {
    Write-Host "Processing $service..." -ForegroundColor Green
    Write-Host "----------------------------------------" -ForegroundColor Gray
    
    if (Test-Path $service) {
        Set-Location $service
        
        # Build image
        Write-Host "Building image: $dockerHubUser/$service:latest" -ForegroundColor Yellow
        docker build -t "$dockerHubUser/$service`:latest" .
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Build successful!" -ForegroundColor Green
            
            # Push image
            Write-Host "Pushing to Docker Hub..." -ForegroundColor Yellow
            docker push "$dockerHubUser/$service`:latest"
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "$service pushed successfully!" -ForegroundColor Green
            } else {
                Write-Host "$service push failed! Check Docker Hub credentials." -ForegroundColor Red
            }
        } else {
            Write-Host "$service build failed! Check Dockerfile and source code." -ForegroundColor Red
        }
        
        Set-Location ..
    } else {
        Write-Host "$service directory not found!" -ForegroundColor Red
    }
    
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Done! Verify images at:" -ForegroundColor Cyan
Write-Host "https://hub.docker.com/u/$dockerHubUser" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan


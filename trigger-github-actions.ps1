# Trigger GitHub Actions by committing and pushing changes

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Triggering GitHub Actions" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "This script will commit and push changes to trigger GitHub Actions workflows." -ForegroundColor Yellow
Write-Host ""

# Services to update
$services = @(
    @{name="order-service-bestbuy"; files=@("plugins/messagequeue.js", "routes/root.js", ".github/workflows/ci_cd.yaml")},
    @{name="store-front-bestbuy"; files=@("nginx.conf", ".github/workflows/ci_cd.yaml")},
    @{name="store-admin-bestbuy"; files=@(".github/workflows/ci_cd.yaml")},
    @{name="makeline-service-bestbuy"; files=@(".github/workflows/ci_cd.yaml")},
    @{name="product-service-bestbuy"; files=@("src/data.rs", ".github/workflows/ci_cd.yaml")}
)

foreach ($service in $services) {
    $servicePath = $service.name
    $files = $service.files
    
    Write-Host "Processing $servicePath..." -ForegroundColor Yellow
    
    if (Test-Path $servicePath) {
        Set-Location $servicePath
        
        # Check if there are changes
        $status = git status --porcelain
        if ($status) {
            Write-Host "  Found changes, committing..." -ForegroundColor Gray
            
            # Add all changes
            git add .
            
            # Commit
            $commitMessage = "Update workflow secrets and fixes"
            if ($servicePath -eq "order-service-bestbuy") {
                $commitMessage = "Fix order service: RabbitMQ connection, error handling, and workflow secrets"
            } elseif ($servicePath -eq "store-front-bestbuy") {
                $commitMessage = "Fix nginx proxy and update workflow secrets"
            } elseif ($servicePath -eq "product-service-bestbuy") {
                $commitMessage = "Update product images and workflow secrets"
            }
            
            git commit -m $commitMessage
            
            # Push to trigger GitHub Actions
            Write-Host "  Pushing to trigger GitHub Actions..." -ForegroundColor Gray
            git push origin main
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  [OK] $servicePath pushed successfully!" -ForegroundColor Green
                Write-Host "  Check GitHub Actions: https://github.com/nada0038/$servicePath/actions" -ForegroundColor Cyan
            } else {
                Write-Host "  [FAIL] Push failed for $servicePath" -ForegroundColor Red
            }
        } else {
            Write-Host "  No changes to commit" -ForegroundColor Gray
        }
        
        Set-Location ..
        Write-Host ""
    } else {
        Write-Host "  [ERROR] Directory not found: $servicePath" -ForegroundColor Red
    }
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Done!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Check your GitHub Actions:" -ForegroundColor Yellow
Write-Host "  https://github.com/nada0038/order-service-bestbuy/actions" -ForegroundColor White
Write-Host "  https://github.com/nada0038/store-front-bestbuy/actions" -ForegroundColor White
Write-Host "  https://github.com/nada0038/store-admin-bestbuy/actions" -ForegroundColor White
Write-Host "  https://github.com/nada0038/makeline-service-bestbuy/actions" -ForegroundColor White
Write-Host "  https://github.com/nada0038/product-service-bestbuy/actions" -ForegroundColor White
Write-Host ""


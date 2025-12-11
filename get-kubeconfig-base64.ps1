# Get Kubeconfig and encode to base64 for GitHub Actions
# This script gets your AKS cluster kubeconfig and encodes it for use as a GitHub secret

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Get Kubeconfig for GitHub Actions" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Get AKS credentials
Write-Host "Getting AKS cluster credentials..." -ForegroundColor Yellow
az aks get-credentials --resource-group bestbuy-rg --name bestbuy-aks --admin --overwrite-existing

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to get AKS credentials!" -ForegroundColor Red
    Write-Host "Make sure you're logged into Azure: az login" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "Getting kubeconfig and encoding to base64..." -ForegroundColor Yellow
Write-Host ""

# Get kubeconfig and encode to base64 using PowerShell
$kubeconfig = kubectl config view --minify --raw
$bytes = [System.Text.Encoding]::UTF8.GetBytes($kubeconfig)
$base64 = [Convert]::ToBase64String($bytes)

Write-Host "========================================" -ForegroundColor Green
Write-Host "Copy this base64 string:" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host $base64 -ForegroundColor White
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "1. Copy the base64 string above" -ForegroundColor White
Write-Host "2. Go to GitHub → Your Repository → Settings" -ForegroundColor White
Write-Host "3. Go to Secrets and variables → Actions" -ForegroundColor White
Write-Host "4. Click 'New repository secret'" -ForegroundColor White
Write-Host "5. Name: KUBE_CONFIG_DATA" -ForegroundColor White
Write-Host "6. Value: Paste the base64 string" -ForegroundColor White
Write-Host "7. Click 'Add secret'" -ForegroundColor White
Write-Host ""
Write-Host "Note: This is only needed if you want GitHub Actions to automatically deploy to Kubernetes." -ForegroundColor Gray
Write-Host "If you deploy manually, you don't need this secret." -ForegroundColor Gray
Write-Host ""


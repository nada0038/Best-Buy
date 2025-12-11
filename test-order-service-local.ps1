# Test Order Service Locally
# This script helps you test the order service

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Order Service Testing Options" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Option 1: Port-Forward to Kubernetes Service" -ForegroundColor Yellow
Write-Host "  Run: kubectl port-forward -n bestbuy service/order-service 3000:3000" -ForegroundColor White
Write-Host "  Then test with: http://localhost:3000/health" -ForegroundColor Gray
Write-Host ""

Write-Host "Option 2: Test Through Store Front (External IP)" -ForegroundColor Yellow
Write-Host "  URL: http://52.240.209.87/order" -ForegroundColor White
Write-Host "  This is what the browser uses" -ForegroundColor Gray
Write-Host ""

Write-Host "Option 3: Run Order Service Locally with Docker Compose" -ForegroundColor Yellow
Write-Host "  cd order-service-bestbuy" -ForegroundColor White
Write-Host "  docker-compose up" -ForegroundColor White
Write-Host "  (Make sure RabbitMQ is running)" -ForegroundColor Gray
Write-Host ""

Write-Host "Option 4: Test from Inside Kubernetes Pod" -ForegroundColor Yellow
Write-Host "  kubectl exec -n bestbuy deployment/store-front -- wget -qO- http://order-service:3000/health" -ForegroundColor White
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Quick Test - Port Forward" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$choice = Read-Host "Do you want to set up port-forward now? (y/n)"
if ($choice -eq 'y' -or $choice -eq 'Y') {
    Write-Host "Setting up port-forward..." -ForegroundColor Yellow
    Write-Host "Press Ctrl+C to stop port-forwarding" -ForegroundColor Gray
    Write-Host ""
    kubectl port-forward -n bestbuy service/order-service 3000:3000
}


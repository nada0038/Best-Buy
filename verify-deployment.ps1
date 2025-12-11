# Verify Best Buy Deployment
# This script helps verify that everything is working correctly

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Best Buy Deployment Verification" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$storeFrontIP = "52.240.209.87"
$storeAdminIP = "130.131.29.143"

Write-Host "Service URLs:" -ForegroundColor Yellow
Write-Host "  Store Front (Customer): http://$storeFrontIP" -ForegroundColor Green
Write-Host "  Store Admin: http://$storeAdminIP" -ForegroundColor Green
Write-Host ""

Write-Host "Checking pod status..." -ForegroundColor Yellow
kubectl get pods -n bestbuy

Write-Host ""
Write-Host "Checking services..." -ForegroundColor Yellow
kubectl get services -n bestbuy

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Product Images Verification Checklist" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Open Store Front: http://$storeFrontIP" -ForegroundColor Yellow
Write-Host "   ✓ Check product list shows actual product images (not placeholders)" -ForegroundColor White
Write-Host "   ✓ Verify these products have images:" -ForegroundColor White
Write-Host "     - Samsung 65\" 4K UHD Smart TV" -ForegroundColor Gray
Write-Host "     - Apple iPhone 15 Pro 256GB" -ForegroundColor Gray
Write-Host "     - Sony WH-1000XM5 Wireless Headphones" -ForegroundColor Gray
Write-Host "     - MacBook Pro 14\" M3 Chip" -ForegroundColor Gray
Write-Host "     - Nintendo Switch OLED Console" -ForegroundColor Gray
Write-Host "     - Canon EOS R6 Mark II Camera" -ForegroundColor Gray
Write-Host "     - Dyson V15 Detect Cordless Vacuum" -ForegroundColor Gray
Write-Host "     - AirPods Pro (2nd Generation)" -ForegroundColor Gray
Write-Host "     - LG 27\" UltraGear Gaming Monitor" -ForegroundColor Gray
Write-Host "     - Xbox Series X Console" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Open Store Admin: http://$storeAdminIP" -ForegroundColor Yellow
Write-Host "   ✓ Check product list shows actual product images" -ForegroundColor White
Write-Host "   ✓ Verify you can view product details with images" -ForegroundColor White
Write-Host ""
Write-Host "3. Test Product Detail Pages:" -ForegroundColor Yellow
Write-Host "   ✓ Click on any product to see its detail page" -ForegroundColor White
Write-Host "   ✓ Verify the product image displays correctly" -ForegroundColor White
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "If images are missing or showing placeholders:" -ForegroundColor Yellow
Write-Host "1. Check pod logs: kubectl logs <pod-name> -n bestbuy" -ForegroundColor White
Write-Host "2. Verify images exist in Docker: docker images | findstr bestbuy" -ForegroundColor White
Write-Host "3. Restart deployments: kubectl rollout restart deployment/<name> -n bestbuy" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Cyan


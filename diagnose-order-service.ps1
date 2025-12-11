# Comprehensive Order Service Diagnosis

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Order Service Diagnosis" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "1. Pod Status:" -ForegroundColor Yellow
kubectl get pods -n bestbuy -l app=order-service

Write-Host ""
Write-Host "2. Getting Latest Pod Name..." -ForegroundColor Yellow
$pods = kubectl get pods -n bestbuy -l app=order-service -o jsonpath='{.items[*].metadata.name}'
if ($pods) {
    $podName = $pods.Split(' ')[0]
    Write-Host "Using pod: $podName" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "3. Pod Logs (Last 50 lines):" -ForegroundColor Yellow
    kubectl logs $podName -n bestbuy --tail=50
    
    Write-Host ""
    Write-Host "4. Pod Events and Status:" -ForegroundColor Yellow
    kubectl describe pod $podName -n bestbuy | Select-String -Pattern "State|Reason|Message|Error|Warning|Failed|Exit" -Context 1
    
    Write-Host ""
    Write-Host "5. Environment Variables:" -ForegroundColor Yellow
    kubectl exec $podName -n bestbuy -- env | Select-String -Pattern "ORDER_QUEUE|APP_VERSION"
    
} else {
    Write-Host "No order service pods found!" -ForegroundColor Red
}

Write-Host ""
Write-Host "6. RabbitMQ Status:" -ForegroundColor Yellow
kubectl get pods -n bestbuy -l app=rabbitmq

Write-Host ""
Write-Host "7. RabbitMQ Service:" -ForegroundColor Yellow
kubectl get service rabbitmq -n bestbuy

Write-Host ""
Write-Host "8. Order Service Deployment:" -ForegroundColor Yellow
kubectl get deployment order-service -n bestbuy

Write-Host ""
Write-Host "9. ConfigMaps:" -ForegroundColor Yellow
kubectl get configmap order-service-config -n bestbuy -o yaml
kubectl get configmap rabbitmq-config -n bestbuy -o yaml

Write-Host ""
Write-Host "10. Secrets:" -ForegroundColor Yellow
kubectl get secret rabbitmq-secret -n bestbuy

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Common Issues to Check:" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "1. Missing environment variables" -ForegroundColor White
Write-Host "2. RabbitMQ not accessible (hostname/port)" -ForegroundColor White
Write-Host "3. Wrong credentials for RabbitMQ" -ForegroundColor White
Write-Host "4. Application code errors" -ForegroundColor White
Write-Host "5. Missing dependencies in Docker image" -ForegroundColor White
Write-Host ""


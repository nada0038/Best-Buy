# Test RabbitMQ Connection from Order Service

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Testing RabbitMQ Connection" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "1. Finding Order Service Pods..." -ForegroundColor Yellow
$pods = kubectl get pods -n bestbuy -l app=order-service -o jsonpath='{.items[*].metadata.name}'
if ($pods) {
    $podName = $pods.Split(' ')[0]
    Write-Host "Found pod: $podName" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "2. Testing connection to rabbitmq:5672..." -ForegroundColor Yellow
    kubectl exec $podName -n bestbuy -- sh -c "nc -zv rabbitmq 5672 2>&1"
    
    Write-Host ""
    Write-Host "3. Checking if RabbitMQ service exists..." -ForegroundColor Yellow
    kubectl get service rabbitmq -n bestbuy
    
    Write-Host ""
    Write-Host "4. Testing DNS resolution..." -ForegroundColor Yellow
    kubectl exec $podName -n bestbuy -- nslookup rabbitmq
    
    Write-Host ""
    Write-Host "5. Checking order service logs for RabbitMQ errors..." -ForegroundColor Yellow
    kubectl logs $podName -n bestbuy --tail=30 | Select-String -Pattern "rabbit|error|fail|connect" -CaseSensitive:$false
    
} else {
    Write-Host "No order service pods found!" -ForegroundColor Red
    Write-Host "Checking all pods in namespace..." -ForegroundColor Yellow
    kubectl get pods -n bestbuy
}

Write-Host ""


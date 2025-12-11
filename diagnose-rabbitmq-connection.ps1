# Diagnose RabbitMQ Connection Issues

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "RabbitMQ Connection Diagnostics" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "1. Checking RabbitMQ Pod Status..." -ForegroundColor Yellow
kubectl get pods -n bestbuy -l app=rabbitmq

Write-Host ""
Write-Host "2. Checking RabbitMQ Service..." -ForegroundColor Yellow
kubectl get service rabbitmq -n bestbuy

Write-Host ""
Write-Host "3. Checking Order Service Pods..." -ForegroundColor Yellow
kubectl get pods -n bestbuy -l app=order-service

Write-Host ""
Write-Host "4. Checking Order Service Logs for RabbitMQ Errors..." -ForegroundColor Yellow
$orderPods = kubectl get pods -n bestbuy -l app=order-service -o jsonpath='{.items[*].metadata.name}'
if ($orderPods) {
    $podName = $orderPods.Split(' ')[0]
    Write-Host "Pod: $podName" -ForegroundColor Gray
    kubectl logs $podName -n bestbuy --tail=50 | Select-String -Pattern "rabbit|error|fail|connect" -CaseSensitive:$false
} else {
    Write-Host "No order service pods found!" -ForegroundColor Red
}

Write-Host ""
Write-Host "5. Testing RabbitMQ Connection from Order Service Pod..." -ForegroundColor Yellow
if ($orderPods) {
    $podName = $orderPods.Split(' ')[0]
    Write-Host "Testing connection to rabbitmq:5672 from pod: $podName" -ForegroundColor Gray
    kubectl exec $podName -n bestbuy -- nc -zv rabbitmq 5672 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Connection test failed! RabbitMQ might not be accessible." -ForegroundColor Red
    } else {
        Write-Host "Connection successful!" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "6. Checking ConfigMaps and Secrets..." -ForegroundColor Yellow
Write-Host "RabbitMQ Config:" -ForegroundColor Gray
kubectl get configmap rabbitmq-config -n bestbuy -o yaml | Select-String -Pattern "username|hostname|port"
Write-Host ""
Write-Host "Order Service Config:" -ForegroundColor Gray
kubectl get configmap order-service-config -n bestbuy -o yaml | Select-String -Pattern "ORDER_QUEUE"
Write-Host ""
Write-Host "RabbitMQ Secret exists:" -ForegroundColor Gray
kubectl get secret rabbitmq-secret -n bestbuy

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Common Issues:" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "1. RabbitMQ pod not ready - wait for it: kubectl wait --for=condition=ready pod -l app=rabbitmq -n bestbuy" -ForegroundColor White
Write-Host "2. Order service can't resolve 'rabbitmq' hostname - check DNS/service discovery" -ForegroundColor White
Write-Host "3. Credentials mismatch - verify rabbitmq-config and rabbitmq-secret match" -ForegroundColor White
Write-Host "4. Network policy blocking connection - check if pods are in same namespace" -ForegroundColor White
Write-Host ""


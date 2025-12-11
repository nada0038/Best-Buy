# Check Order Service Status and Logs

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Order Service Diagnostics" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "1. Order Service Pods:" -ForegroundColor Yellow
kubectl get pods -n bestbuy -l app=order-service

Write-Host ""
Write-Host "2. Order Service Logs (last 30 lines):" -ForegroundColor Yellow
$pods = kubectl get pods -n bestbuy -l app=order-service -o jsonpath='{.items[*].metadata.name}'
if ($pods) {
    $podName = $pods.Split(' ')[0]
    Write-Host "Pod: $podName" -ForegroundColor Gray
    kubectl logs $podName -n bestbuy --tail=30
} else {
    Write-Host "No pods found!" -ForegroundColor Red
}

Write-Host ""
Write-Host "3. Test Order Service from Store-Front Pod:" -ForegroundColor Yellow
$storeFrontPods = kubectl get pods -n bestbuy -l app=store-front -o jsonpath='{.items[*].metadata.name}'
if ($storeFrontPods) {
    $sfPod = $storeFrontPods.Split(' ')[0]
    Write-Host "Testing from store-front pod: $sfPod" -ForegroundColor Gray
    kubectl exec $sfPod -n bestbuy -- wget -qO- http://order-service:3000/health
} else {
    Write-Host "No store-front pods found!" -ForegroundColor Red
}

Write-Host ""
Write-Host "4. RabbitMQ Status:" -ForegroundColor Yellow
kubectl get pods -n bestbuy -l app=rabbitmq

Write-Host ""
Write-Host "5. Order Service Configuration:" -ForegroundColor Yellow
kubectl get configmap order-service-config -n bestbuy -o yaml

Write-Host ""


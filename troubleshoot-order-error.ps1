# Troubleshoot Order Submission Error
# This script helps diagnose why orders are failing

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Troubleshooting Order Submission Error" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "1. Checking Order Service Pods..." -ForegroundColor Yellow
kubectl get pods -n bestbuy -l app=order-service

Write-Host ""
Write-Host "2. Checking RabbitMQ Pods..." -ForegroundColor Yellow
kubectl get pods -n bestbuy -l app=rabbitmq

Write-Host ""
Write-Host "3. Checking Order Service Logs (last 20 lines)..." -ForegroundColor Yellow
$orderPods = kubectl get pods -n bestbuy -l app=order-service -o jsonpath='{.items[*].metadata.name}'
if ($orderPods) {
    $firstPod = $orderPods.Split(' ')[0]
    Write-Host "Pod: $firstPod" -ForegroundColor Gray
    kubectl logs $firstPod -n bestbuy --tail=20
} else {
    Write-Host "No order service pods found!" -ForegroundColor Red
}

Write-Host ""
Write-Host "4. Checking Order Service Health..." -ForegroundColor Yellow
kubectl exec -n bestbuy deployment/order-service -- wget -qO- http://localhost:3000/health 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Order service health check failed!" -ForegroundColor Red
}

Write-Host ""
Write-Host "5. Checking Services..." -ForegroundColor Yellow
kubectl get services -n bestbuy | findstr "order\|rabbitmq"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Common Issues & Solutions:" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "If order-service pods are not running:" -ForegroundColor White
Write-Host "  kubectl describe pod <pod-name> -n bestbuy" -ForegroundColor Gray
Write-Host ""
Write-Host "If RabbitMQ is not ready:" -ForegroundColor White
Write-Host "  kubectl wait --for=condition=ready pod -l app=rabbitmq -n bestbuy --timeout=300s" -ForegroundColor Gray
Write-Host ""
Write-Host "If order-service can't connect to RabbitMQ:" -ForegroundColor White
Write-Host "  Check ConfigMap: kubectl get configmap order-service-config -n bestbuy -o yaml" -ForegroundColor Gray
Write-Host "  Check Secrets: kubectl get secret rabbitmq-secret -n bestbuy" -ForegroundColor Gray
Write-Host ""
Write-Host "To restart order-service:" -ForegroundColor White
Write-Host "  kubectl rollout restart deployment/order-service -n bestbuy" -ForegroundColor Gray
Write-Host ""


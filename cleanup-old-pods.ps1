# Clean up old order-service ReplicaSets and pods

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Cleaning Up Old Order Service Pods" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "1. Current ReplicaSets:" -ForegroundColor Yellow
kubectl get replicasets -n bestbuy -l app=order-service

Write-Host ""
Write-Host "2. Current Deployment:" -ForegroundColor Yellow
kubectl get deployment order-service -n bestbuy

Write-Host ""
Write-Host "3. Scaling down old ReplicaSets..." -ForegroundColor Yellow
$replicasets = kubectl get replicasets -n bestbuy -l app=order-service -o jsonpath='{.items[*].metadata.name}'
$currentDeployment = kubectl get deployment order-service -n bestbuy -o jsonpath='{.spec.selector.matchLabels.app}'

foreach ($rs in $replicasets.Split(' ')) {
    $rsInfo = kubectl get replicaset $rs -n bestbuy -o jsonpath='{.metadata.ownerReferences[0].name}'
    if ($rsInfo -ne "order-service") {
        Write-Host "Scaling down old ReplicaSet: $rs" -ForegroundColor Gray
        kubectl scale replicaset $rs -n bestbuy --replicas=0
    }
}

Write-Host ""
Write-Host "4. Deleting old ReplicaSets..." -ForegroundColor Yellow
kubectl get replicasets -n bestbuy -l app=order-service -o json | ConvertFrom-Json | ForEach-Object {
    $rs = $_.items | Where-Object { $_.spec.replicas -eq 0 }
    if ($rs) {
        Write-Host "Deleting ReplicaSet: $($rs.metadata.name)" -ForegroundColor Gray
        kubectl delete replicaset $rs.metadata.name -n bestbuy
    }
}

Write-Host ""
Write-Host "5. Final Status:" -ForegroundColor Yellow
kubectl get pods -n bestbuy -l app=order-service
kubectl get replicasets -n bestbuy -l app=order-service

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Done! Old pods should be cleaned up." -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan


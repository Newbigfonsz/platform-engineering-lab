# Platform System Report
**Generated**: Wed Dec  3 02:34:47 AM UTC 2025

## Cluster Status
```
NAME           STATUS   ROLES           AGE   VERSION
k8s-cp01       Ready    control-plane   23h   v1.28.15
k8s-worker01   Ready    <none>          23h   v1.28.15
k8s-worker02   Ready    <none>          23h   v1.28.15
```

## Running Applications
```
NAMESPACE        NAME                                        READY   STATUS    RESTARTS     AGE
demo             nginx-7854ff8877-j9tcv                      1/1     Running   0            22h
demo             nginx-7854ff8877-nskg9                      1/1     Running   0            22h
demo             nginx-7854ff8877-wd87c                      1/1     Running   0            22h
metallb-system   controller-56bb48dcd4-xq6fx                 1/1     Running   0            22h
metallb-system   speaker-8rpdg                               1/1     Running   0            22h
metallb-system   speaker-htjbk                               1/1     Running   0            22h
metallb-system   speaker-qlrs5                               1/1     Running   0            22h
```

## Certificates
```
NAMESPACE   NAME          READY   SECRET        AGE
demo        demo-tls-v3   True    demo-tls-v3   21m
```

## Services
```
NAMESPACE        NAME                                 TYPE           CLUSTER-IP       EXTERNAL-IP     PORT(S)                      AGE
cert-manager     cert-manager                         ClusterIP      10.111.100.159   <none>          9402/TCP                     22h
cert-manager     cert-manager-webhook                 ClusterIP      10.104.12.61     <none>          443/TCP                      22h
demo             nginx                                LoadBalancer   10.99.109.133    10.10.0.220   80:31581/TCP                 22h
ingress-nginx    ingress-nginx-controller             LoadBalancer   10.110.90.84     10.10.0.220   80:32630/TCP,443:31126/TCP   22h
ingress-nginx    ingress-nginx-controller-admission   ClusterIP      10.96.235.100    <none>          443/TCP                      22h
metallb-system   metallb-webhook-service              ClusterIP      10.110.144.90    <none>          443/TCP                      22h
```

## Disk Usage
```
k8s-worker01 | CHANGED | rc=0 >>
/dev/sda1        94G  3.5G   90G   4% /
docker-host | CHANGED | rc=0 >>
/dev/sda1        94G  2.4G   92G   3% /
k8s-cp01 | CHANGED | rc=0 >>
/dev/sda1        63G  3.7G   59G   6% /
k8s-worker02 | CHANGED | rc=0 >>
/dev/sda1        94G  3.3G   91G   4% /
```

## System Health: ✅ ALL SYSTEMS OPERATIONAL

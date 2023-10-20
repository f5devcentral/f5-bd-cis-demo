Make sure the demo-misc has been deleted before creating this demo

9. Blue-green deployment


Unset persistence to show distribution

```
run-clusters.sh oc apply -f policy-default.yaml
```

Note first delete demo-tls-and-nontls:

```
run-clusters.sh ./delete-demo.sh
```

Create demo with route weights (uses only Edge termination)

```
run-clusters.sh ./create-demo.sh
```

Check routes and its distrution

```
run-clusters.sh oc -n mc-onetier-eng-caas-nginx-app1 get route 
```

Mandar tráfico y comprobar distribución

```
ab -n 2000 -c 200 https://nginx-app1.apps.f5-udf.com/
ab -n 2000 -c 200 https://nginx-app1-alt.apps.f5-udf.com/
ab -n 2000 -c 200 https://nginx-app1.apps.f5-udf.com/test

tmsh -c "cd /mc-onetier ; show ltm pool recursive members raw" | egrep "Ltm::Pool|Total"
```

Change weights

```
run-clusters.sh oc -n mc-onetier-eng-caas-nginx-app1 edit route nginx-app1
```
Reset stats and repet the test

```
tmsh -c "cd /mc-onetier/Shared/ ; reset-stats ltm pool members"
```
Repeat using persistence



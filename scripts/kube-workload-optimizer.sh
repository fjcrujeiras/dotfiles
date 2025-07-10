#!/bin/bash

# list all pods and read namespace and pod name as input
kubectl get pods -A --no-headers|while read ns pod a; do
    # gather cpu and memory real time usage using kubectl top command
    # gather cpu and memory allocations using kubectl get pod with jsonpath selected
    # join the 2 line by line by pod name using paste command
    paste <(kubectl top -n $ns pod $pod --containers --no-headers|sort) <(kubectl get pod -n $ns $pod -o jsonpath='{range .spec.containers[*]}{.name}{"\t"}{.resources.requests.cpu}{"\t"}{.resources.requests.memory}{"\n"}{end}'|sort)
    echo ---
done

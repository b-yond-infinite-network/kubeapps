#!/usr/bin/env bash

set -e -x

docker tag kubeapps/apprepository-controller:${VERSION} ${REGISTRY}/${PROJECT_NAME}/apprepository-controller:latest
docker push ${REGISTRY}/${PROJECT_NAME}/apprepository-controller:latest
docker tag kubeapps/apprepository-controller:${VERSION} ${REGISTRY}/${PROJECT_NAME}/apprepository-controller:${VERSION}
docker push ${REGISTRY}/${PROJECT_NAME}/apprepository-controller:${VERSION}

docker tag kubeapps/dashboard:${VERSION} ${REGISTRY}/${PROJECT_NAME}/dashboard:latest
docker push ${REGISTRY}/${PROJECT_NAME}/dashboard:latest
docker tag kubeapps/dashboard:${VERSION} ${REGISTRY}/${PROJECT_NAME}/dashboard:${VERSION}
docker push ${REGISTRY}/${PROJECT_NAME}/dashboard:${VERSION}

export GATE_POD=$(kubectl get pods -n ${NAMESPACE} -l "component=gate" -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward -n ${NAMESPACE} ${GATE_POD} 8084:8084 >> /dev/null &

sleep 5

curl -X POST http://localhost:8084/webhooks/webhook/deploy-infinity-service -H "Content-Type: application/json" -d '{ "serviceName": "'"${REPO}"'", "parameters": { "version": "'"${VERSION}"'" } }'

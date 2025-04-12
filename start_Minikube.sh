#!/bin/bash
PROFILE="at-profile"
NAMESPACE="at-k8s-f"
DRIVER="docker"
CONTEXT="at-context-f"
ADDONS="metrics-server,storage-provisioner"


if [ -z "$1" ]; then
  echo "Faltó especificar la ruta completa del Sitio Web"
  echo "Ej: /home/usuario/Escritorio/ATK8s/web"
  echo "Uso: $0 <directorio>"
  exit 1
fi

MOUNT="$1"

echo "Iniciando Minikube con perfil $PROFILE"

minikube start -p $PROFILE --driver=$DRIVER --addons=$ADDONS --mount --mount-string=$MOUNT:/mnt/sitio-web

echo "Estableciendo el perfil $PROFILE como Activo"

minikube profile $PROFILE

echo "Minikube Iniciado Y perfil activado!!!"

echo "Creando namespaces: $NAMESPACE"
kubectl create namespace $NAMESPACE

echo "Creando contexto: $CONTEXT"
kubectl config set-context $CONTEXT \
	--cluster=$PROFILE \
	--user=$PROFILE \
	--namespace=$NAMESPACE

echo "Estableciendo Contexto como default"
kubectl config use-context $CONTEXT

echo "Configuración completada. Contexto actual:"
kubectl config current-context

echo "Aplicando archivos de manifiesto..."

echo "Aplicando manifiesto PV ... ... ... ... ..."

kubectl apply -f manifest/volume-pv-mount.yaml

sleep 10

echo "Aplicando manifiesto PVC ... ... ... ... ..."

kubectl apply -f manifest/volume-pvc-mount.yaml

sleep 10

echo "Aplicando manifiesto Deployment ... ... ... ... ..."

kubectl apply -f manifest/deploy-mount.yaml

echo "Esperando a que el Pod esté en estado 'Running'..."

until kubectl get pods -n $NAMESPACE | grep sitio-web | grep -q Running; do
  echo -n "."
  sleep 2
done

echo -e "\n✓ Pod en ejecución"

echo "Aplicando manifiesto Servicio ... ... ... ... ..."

kubectl apply -f manifest/service-mount.yaml

sleep 30s

echo "Levantando el Servicio... ... ..."

minikube service sitio-web-service-mount -p $PROFILE -n $NAMESPACE
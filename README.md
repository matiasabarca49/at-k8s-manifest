# Repositorio con Manifiesto para Kubernetes

En este repositorio se encuentran los archivos de manifiesto necesario para desplegar el sitio web que se encuentra en el repositorio.  
El sitio web se encuentra en el siguiente repositorio-> https://github.com/matiasabarca49/static-website-ATk8s

## Preparacion y puesta en marcha
###### Requisitos para un despliegue exitoso

- **Docker:** El cluster de Minikube se ejecuta en un contenedor.
- **Minikube:** Nos permite ejecutar un cluster de kubernetes.
- **Kubectl:** Nos permite interactuar con el Cluster de Minikube.
- **Terminal Linux con BASH:** En caso de que se quiera ejecutar el script automatizado.

**NOTA:** Antes de ejecutar verifique de que Docker Engine, Service y Desktop se encuentre en Ejecución.

Se dispondrá de lo siguiente:

- No tenga un profile llamado "at-profile"
- No tenga un namespace llamado "at-k8s-f"
- No tenga un context llamado "at-context-f"

En caso contrario **Elimínelos** 

## 1 - Descarga o Clonación de los repositorios

Se debe crear una carpeta(se recomienda en el escritorio) que contenga la clonación de los repositorio.  
Una vez creada la carpeta clone los repositorios.
- **Contendido Web:** En este repositorio se encuentra los archivos del sitio web.
- **Archivos de Manifiesto:** En este repositorio se encuentra los archivos YAML que nos permite el despliegue en minikube.  

**NOTA:** Los repositorio se deben encontrar en la misma carpeta. Donde cada repositorio tenga su propia carpeta

### Estructura de carpetas a respetar

```
📁 Carpeta Principal
├── k8s/
|   ├── manifest
│       ├── deploy-mount.yaml
│       ├── service-mount.yaml
│       ├── volume-pv-mount.yaml
│       └── volume-pvc-mount.yaml
|   └── start_Minikube.sh
├── web/
│   ├── index.html
|   ├── style.css
|   └── assets
```

#### 1.1 - Clone el Repositorio Web 

```
git clone https://github.com/matiasabarca49/static-website-ATk8s
```

Renombrar el directorio clonado con el nombre "web"

#### 1.2 - Clone el Repositorio Kubernetes

```
git clone https://github.com/matiasabarca49/at-k8s-manifest
```
Renombrar el directorio clonado con el nombre "k8s"

## A - Despliegue automatizado

**NOTA:** Es necesario contar con una terminal que admita BASH y revisar que el script tenga permisos de ejecución.

El script "start_Minikube.sh" permite desplegar la aplicación completa.

Para ejecutar el script debe indicar la ruta absoluta del directorio de la página web clonado al ejecutar el script

```
./start_Minikube.sh <RUTA_ABSOLUTA_DEL_DIRECTORIO_WEB>
```
**EJ:** ./start_Minikube.sh /home/linuxUser/Escritorio/ATK8s/web

En caso de que falle el despliegue Automatizado. **Realize el Despliegue manual**.

## B - Despliegue Manual

## 2 - Preparación del cluster con Minikube

#### 2.1 - Creamos un nuevo cluster

Vamos a crear un perfil de minikube nuevo, habilitar addons de métricas y almacenamiento. Por último montar el directorio del sitio web en el cluster que vamos a crear.  
**NOTA:** Debes agregar la ruta absoluta del directorio donde clonaste el sitio web. De lo contrario no funcionará.
```
minikube start -p at-prueba --driver=docker --addons=metrics-server,storage-provisioner --mount --mount-string=<DIRECTORIO_PAGINA_WEB>:/mnt/sitio-web
```
**NOTA:** La creación del cluster puede demorar unos minutos

#### 2.2 - Cambiamos al perfil nuevo

```
minikube profile at-prueba
```

#### 2.3 - Creamos el namespace

```
kubectl create namespace at-k8s
```

#### 2.4 - Creamos el contexto

```
kubectl config set-context at-context --user=at-prueba --cluster=at-prueba --namespace=at-k8s
```

#### 2.4 - Cambiamos al contexto nuevo

```
kubectl config use-context at-context
```
## 3 - Aplicación de los Manifiestos

Nos posicionamos en la carpeta donde descargamos los manifiestos

### Opcion A - Aplicar todos los manifiesto desde un único comando

```
kubectl apply -R -f manifest/
```

### Opcion B - Aplicar los manifiesto de a uno

### B.1 - Aplicar Volúmenes


```
kubectl apply -f manifest/volume-pv-mount.yaml
kubectl apply -f manifest/volume-pvc-mount.yaml
```

### B.2 - Aplicar Deployments

```
kubectl apply -f manifest/deploy-mount.yaml
```
**NOTA:** Verificar que el estado del pod se encuentre en RUNNING. En caso contrario el Service no iniciará

```
kubectl get pods
```

Deberia mostrar:
```
NAME                         READY   STATUS    RESTARTS      AGE
sitio-web-7xxxxxxx5-wxxxx4   1/1     Running   1 (60m ago)   63m
```

### B.3 -  Crear un Service

```
kubectl apply -f manifest/service-mount.yaml
```

## 4 - Exponer el servicio para acceder al sitio web

```
minikube -p at-prueba -n at-k8s service sitio-web-service-mount
```

El acceso se realiza mediante el navegador. 


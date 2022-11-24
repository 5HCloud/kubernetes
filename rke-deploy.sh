#!/bin/bash


groupadd rke-deploy
useradd -m rke-deploy -g 1000 -G docker 

mkdir -p /home/rke-deploy/.ssh
cp -av id_rsa_rke-deploy.pub /home/rke-deploy/.ssh/authorized_keys
chown -R rke-deploy:rke-deploy /home/rke-deploy/.ssh
chmod 700 /home/rke-deploy/.ssh/
chmod 644 /home/rke-deploy/.ssh/authorized_keys
chsh /bin/bash rke-deploy

SUDO_USER="rke-deploy ALL=(ALL) NOPASSWD:ALL"
cat > /etc/sudoers.d/rke-deploy <<< $SUDO_USER
chmod 440 /etc/sudoers.d/rke-deploy

# etcd
ETCD_TCP="2376 2379 2380 8472 9099 10250"

# controlplane
CONTROLPLANE_EXT_TCP="80 443"
#CONTROLPLANE_TCP="2376 6443 9099 10250 10254 30000:32767"
CONTROLPLANE_TCP="6443"
CONTROLPLANE_UDP="8472 30000:32767"

# worker
# 22, managed by default setup
WORKER_EXT_TCP="80 443"
#WORKER_TCP="2376 9099 10250 10254 30000:32767"
WORKER_UDP="8472"


# NODE
WORKER="148.251.21.194 148.251.22.45 148.251.21.149"
CONTROLPLANE="162.55.217.246 162.55.217.254 162.55.217.250"

## 
TCP_EXT_PORTS="80 443 6443"
TCP_PORTS="2376 9099 10250 10254 30000:32767 2379 2380 3260 860"
UDP_PORTS="8472 30000:32767 3260 860"

## 
# ufw allow from 213.155.94.54 to any port 2033 proto tcp


for PORT in ${TCP_PORTS}; do
    for NODE in ${WORKER} ${CONTROLPLANE}; do 
        ufw allow from ${NODE} to any port ${PORT} proto tcp
    done
done

ufw status


for PORT in ${UDP_PORTS}; do
    for NODE in ${WORKER} ${CONTROLPLANE}; do
        ufw allow from ${NODE} to any port ${PORT} proto udp
    done
done

ufw status

for PORT in ${TCP_EXT_PORTS}; do
    for NODE in ${WORKER} ${CONTROLPLANE}; do
        ufw allow ${PORT}
    done
done

ufw status

exit 0


# Cert Manager
# https://cert-manager.io/docs/installation/kubernetes/
# https://rancher.com/docs/rancher/v2.x/en/installation/resources/advanced/helm2/helm-rancher/

kubectl create namespace cert-manager
helm repo add jetstack https://charts.jetstack.io
helm repo update

helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.4.0 
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.4.0/cert-manager.yaml


#Gatekeeper (kubernetes)
#13:30 - 14:15 45

# helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
# kubectl create namespace cattle-system

# https://rancher.com/docs/rancher/v2.x/en/installation/install-rancher-on-k8s/
# 


helm install rancher rancher-stable/rancher --namespace cattle-system --create-namespace --set hostname=rancher.openfellas.com --set ingress.tls.source=letsEncrypt --set letsEncrypt.email="devops@openfellas.com" --set letsEncrypt.environment="production" --set letsEncrypt.ingress.class="nginx" 

DEVOPS <devops@openfellas.com>

# Longhorn
# https://longhorn.io/docs/1.1.2/deploy/install/#installation-requirements
apt-get install open-iscsi

helm repo add longhorn https://charts.longhorn.io
helm repo update

kubectl create namespace longhorn-system
helm install longhorn longhorn/longhorn --namespace longhorn-system


USER=admin; read PASSWORD; echo "${USER}:$(openssl passwd -stdin -apr1 <<< ${PASSWORD})" >> auth
kubectl -n longhorn-system create secret generic basic-auth --from-file=auth
kubectl -n longhorn-system get secret basic-auth -o yaml

kubectl -n longhorn-system apply -f longhorn-ingress.yml

Custom

Longhonr Default Settings: 
node.longhorn.io/create-default-disk=true
Automatic salvage

Disable Schudeluing on Cordoned Node

Custom mkfs: -O ^64bit,^metadata_csum

Automatically Cleanup System generated Snapshots

Guaranteeed Engine Manager CPU
Replica 
8

Storage Class: Retain


Changed: ClusterIP -> rancher-proxy
Source Code

Longhorn is 100% open source software. Project source code is spread across a number of repos:

    Longhorn Engine -- Core controller/replica logic https://github.com/longhorn/longhorn-engine
    Longhorn Instance Manager -- Controller/replica instance lifecycle management https://github.com/longhorn/longhorn-instance-manager
    Longhorn Share Manager -- NFS provisioner that exposes Longhorn volumes as ReadWriteMany volumes. https://github.com/longhorn/longhorn-share-manager
    Longhorn Manager -- Longhorn orchestration, includes CSI driver for Kubernetes https://github.com/longhorn/longhorn-manager
    Longhorn UI -- Dashboard https://github.com/longhorn/longhorn-ui


kubectl label nodes worker01 node.longhorn.io/create-default-disk=true
kubectl label nodes worker02 node.longhorn.io/create-default-disk=true
kubectl label nodes worker03 node.longhorn.io/create-default-disk=true


# Longhorn api
https://rancher.openfellas.com/k8s/clusters/local/api/v1/namespaces/longhorn-system/services/http:longhorn-frontend:80/proxy/v1
https://rancher.openfellas.com/k8s/clusters/local/api/v1/namespaces/longhorn-system/services/http:longhorn-frontend:80/proxy/#/dashboard

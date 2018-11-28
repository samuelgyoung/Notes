#https://myopswork.com/how-to-install-kubernetes-k8-in-rhel-or-centos-in-just-7-steps-2b78331174a5
# MASTER NODE

systemctl stop firewalld
systemctl disable firewalld

cat <<EOF > /etc/yum.repos.d/centos.repo
[centos]

name=CentOS-7

baseurl=http://ftp.heanet.ie/pub/centos/7/os/x86_64/

enabled=1

gpgcheck=1

gpgkey=http://ftp.heanet.ie/pub/centos/7/os/x86_64/RPM-GPG-KEY-CentOS-7

#additional packages that may be useful

[extras]

name=CentOS-$releasever - Extras

baseurl=http://ftp.heanet.ie/pub/centos/7/extras/x86_64/

enabled=1

gpgcheck=0

EOF

# As a standard religious practice run yum update and then install docker

yum -y update
yum -y install docker
systemctl enable docker
systemctl start docker

#Now time to install Kubernetes packages, we need yum repo from google Also disable selinux as docker uses cgroups and other lib which selinux falsely treats as threat.
cat <<EOF > /etc/yum.repos.d/kubernetes.repo

[kubernetes]

name=Kubernetes

baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64

enabled=1

gpgcheck=1

repo_gpgcheck=1

gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg

EOF

setenforce 0

#### CHANGE SE LINUX
vi /etc/selinux/config
     SELINUX=permissive ##Change if it is enforceing

yum -y install kubelet kubeadm kubectl
systemctl start kubelet
systemctl enable kubelet


#Installed K8 and now some hacks and config’s to enable cluster
cat <<EOF >  /etc/sysctl.d/k8s.conf

net.bridge.bridge-nf-call-ip6tables = 1

net.bridge.bridge-nf-call-iptables = 1

EOF

sysctl --system

echo 1 > /proc/sys/net/ipv4/ip_forward

###STOP HERE IF NODE

#CONFIGURE NETWORKING TO THE CLUSTER

#TURN OFF SWAP
swapoff -a

kubeadm init --pod-network-cidr=10.244.0.0/16


#Your Kubernetes master has initialized successfully!

#To start using your cluster, you need to run the following as a regular user:

#  mkdir -p $HOME/.kube
#  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
#  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You can now join any number of machines by running the following on each node
as root:

#  kubeadm join 192.168.1.130:6443 --token 1txwsx.hh4hn0junkntb3bd --discovery-token-ca-cert-hash sha256:7e653a4e456c2499200e69d86df8754d9c3f645572445110a97be7e7a5a30d15


#CREATE A NEW USER, add them with visudo
#username        ALL=(ALL)      ALL
#adduser k8
#passwd k8

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

sudo chown $(id -u):$(id -g) $HOME/.kube/config

#Now we will enable Kubernetes cluster and will use flannel to get the config in yaml. And this should be run only on Master node
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.9.1/Documentation/kube-flannel.yml

#Verify the Cluster with below command, look for a "Ready"
kubectl get nodes

## STOP HERE IF MASTER

### CONTINUE HERE IF NODE
#After finishing 1–4 steps on the nod one last step will be run the notes which you made note during master setup. This step is to run on node to get registered with Master

#COMMANDS
#CHANGE THE LABEL
#kubectl label node k8node01

#GET CLUSTER INFO
kubectl config view

#GET CLUSTER EVENTS
#kubectl get nodes
#kubectl get events
#kubectl get services

#kubectl get pods
#kubectl get pods --namespace=kube-system

#SEE THE ACTUAL DOCKER IMAGES
sudo docker ps

### TO CREATE POD:
#1. CREATE YAML FILE
#2. Run: kubectl create -f nodejs-pod.yaml
#3. Get a descriptio of pod (optional): kubectl describe pods/node-js-pod 
# ^ You can execute on this via the IP from the above command. Example : 



###### GET THE POD INFO:
kubectl get pods
kubectl describe pods/<pod-id>

kubectl get endpoints


### SCALING K8
#kubectl get pods -l name=node-js-scale
#kubectl scale --replicas=3 rc/node-js-scale

### MONITORING
kubectl get pods --namespace=kube-system

#INSTALLING SYS-DIG
curl -s https://s3.amazonaws.com/download.draios.com/stable/install-sysdig | sudo bash

#GET VOLUME INFOMATION
kubectl get pv

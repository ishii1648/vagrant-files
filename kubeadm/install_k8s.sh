#!/bin/bash
# this script should be executed by root

CMDNAME=`basename $0`

# default
NODE_TYPE=master
INTERFACE=eth1
NETWORK_PLUGIN=flannel
USER=vagrant

function usage() {
cat << _EOT_
Usage:
$CMDNAME [-n] [-i] [-p]

Options:
-n    k8s node type (default: master)
-i    listen INTERFACE on kube-api-server (default: eth0)
-p    network plugin (default: flannel)
-u    user (default: ubuntu)
_EOT_
exit 1
}

# set option parameters
while getopts n:i:p:u:h OPT
do
    case $OPT in
        n)  NODE_TYPE=$OPTARG
            ;;
        i)  INTERFACE=$OPTARG
            ;;
        p)  NETWORK_PLUGIN=$OPTARG
            ;;
        u)  USER=$OPTARG
            ;;
        h)  usage
            ;;
    esac
done

# check option parameters
if [ $NODE_TYPE != "master" ] && [ $NODE_TYPE != "worker" ]; then
    echo "[ERR] k8s node type must be master or worker"
    echo ""
    usage
elif [ $NETWORK_PLUGIN != "flannel" ] && [ $NETWORK_PLUGIN != "calico" ]; then
    echo "[ERR] network plugin must be flannel or calico"
    echo ""
    usage
fi


# install dependency modules
myip=`ip a show ${INTERFACE} | grep inet | grep -v inet6 | awk '{print $2}' | cut -f1 -d/`
sudo apt-get update && sudo apt-get install -y apt-transport-https curl docker.io
echo '{ "exec-opts": ["native.cgroupdriver=systemd"] }' > /etc/docker/daemon.json
systemctl start docker
systemctl enable docker
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
apt-add-repository 'deb http://apt.kubernetes.io/ kubernetes-xenial main'
apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl
touch /etc/default/kubelet
echo "KUBELET_EXTRA_ARGS=--node-ip=$myip" > /etc/default/kubelet
systemctl daemon-reload
systemctl restart kubelet

if [[ $NODE_TYPE == "master" ]]; then
    if [[ $NETWORK_PLUGIN == "flannel" ]]; then
        pod_network_cidr=10.244.10.0/16
        manifest_url='https://raw.githubusercontent.com/coreos/flannel/2140ac876ef134e0ed5af15c65e414cf26827915/Documentation/kube-flannel.yml'
    elif [[ $NETWORK_PLUGIN == "calico" ]]; then
        pod_network_cidr=192.168.128.0/16
        manifest_url='https://docs.projectcalico.org/manifests/calico.yaml'
    fi

    # install k8s
    kubeadm init --apiserver-advertise-address=$myip --apiserver-cert-extra-sans=$myip --pod-network-cidr=$pod_network_cidr
    # set kubeconfig
    mkdir /home/${USER}/.kube
    cp /etc/kubernetes/admin.conf /home/${USER}/.kube/config
    chown ${USER}:${USER} /home/${USER}/.kube/config
    export KUBECONFIG=/etc/kubernetes/admin.conf
    # install network plugin
    kubectl apply -f $manifest_url
    # save join command
    kubeadm token create --print-join-command > /etc/kubeadm_join_cmd.sh
    chmod +x /etc/kubeadm_join_cmd.sh
    # disable restrict set pod on master node
    kubectl taint nodes --all node-role.kubernetes.io/master-
fi
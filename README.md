# k8s-ha-cluster

Build a kubernetes ha cluster in 10 minutes in Hetzner Cloud aka hcloud with Terraform, Ansible and MicroK8s.

In microk8s 1.19, high availability is automatically enabled on for clusters with three or more nodes.

Learn more: https://microk8s.io/docs/high-availability

## prepare hcloud

* enter hcloud
* create new project
* enter new project
* in access settings create an API Token

## clone repo

```bash
$ git clone https://github.com/catdev-ou/microk8s-ha-cluster
$ cd microk8s-ha-cluster
$ export HCLOUD_TOKEN=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

## create ssh key

```bash
$ ssh-keygen -f files/microk8s-ha-cluster-ed25519 -C "microk8s-ha-cluster project ssh key" -N "" -t ed25519
```

## setup cluster

```bash
$ cd terraform
$ terraform plan
$ terraform apply
$ cd ../ansible
$ ansible-playbook setup-cluster.yml
```

## install gitea in the cluster

```bash
$ cd ansible
$ cd ansible-playbook setup/99-gitea.yml
$ cd ../terraform
$ echo "`terraform output loadbalancer-ip` www.gitea.local"
$ # add above command output to /etc/hosts
```

Browse to http://www.gitea.local to finish the Gitea installation.

## clean up

```bash
$ cd terraform
$ terraform destroy
```

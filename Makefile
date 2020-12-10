all: terraform ansible output
.PHONY: all terraform ansible ssh-key output clean

terraform:
	cd terraform; \
	terraform init; \
	terraform apply

ansible:
	cd ansible; \
	ansible-playbook setup-cluster.yml

ssh-key:
	ssh-keygen -f files/k8s-internal-ed25519 -C "k8s-internal project ssh key" -N "" -t ed25519

output:
	cd terraform; \
	terraform output

clean:
	cd terraform; \
	terraform destroy

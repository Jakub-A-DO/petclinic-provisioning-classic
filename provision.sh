#!/bin/bash
set -e
DELETE_ALL="${1:-}"

export GOOGLE_APPLICATION_CREDENTIALS=~/Downloads/petclinic-444616-9201bbc2ac1e.json
#cd gcp && terraform destroy -auto-approve && 
echo $DELETE_ALL
if [[ "$DELETE_ALL" == "delete-all" ]]; then
    cd gcp && terraform destroy 
fi
cd gcp && terraform apply -auto-approve
cp inventory-dev.ini ../ansible/

cd ../ansible; ansible-playbook -i inventory-dev.ini playbooks/prepare-petclinic-nodes.yml

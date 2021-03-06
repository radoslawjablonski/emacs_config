#! /bin/bash -xe

sudo apt-get install -y ansible

# NOTE: file name without "" - it is needed to make ~/ work
if [ ! -e ~/.ssh/id_rsa.pub ]; then
    echo "Error! Please generate private/public key pair first!"
    exit 1
fi

# Copying private key, 'tee -a' for appending data
cat ~/.ssh/id_rsa.pub|tee -a ~/.ssh/authorized_keys

ansible-playbook install_emacs_dependencies.yml -i inventory

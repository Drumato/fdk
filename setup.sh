#!/bin/sh
set -xe
ssh-keyscan github.com >> ~/.ssh/known_hosts

git clone https://github.com/pyenv/pyenv.git ~/.pyenv
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bash_profile
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bash_profile
echo 'eval "$(pyenv init --path)"' >> ~/.bash_profile
echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init -)"\nfi' >> ~/.bash_profile
source ~/.bash_profile

pyenv install 3.8.0
pyenv global 3.8.0
pip install pipenv

source /etc/os-release
if [ $ID = "ubuntu" ] && [ $VERSION_ID = "20.04" ]; then
        sudo apt -y install qemu-kvm libvirt-daemon-system libvirt-dev python3-dev
fi

if [ $ID = "centos" ]; then
        sudo yum -y install libvirt libvirt-devel
fi

git clone https://github.com/slankdev/fdk.git
cd fdk
pipenv sync
cd playbooks

if [ $ID = "ubuntu" ] && [ $VERSION_ID = "20.04" ]; then
        pipenv run ansible-playbook -i inventories/direct.yaml -l machines main.yaml
fi

if [ $ID = "centos" ]; then
        pipenv run ansible-playbook -i inventories/vm.yaml main.yaml
fi


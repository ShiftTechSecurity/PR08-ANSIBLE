#!/bin/bash
# Installation de Ansible, sshpass, sudo, man, tree, et net-tools depuis root
apt update -y && apt upgrade -y
apt install sudo man tree net-tools curl git -y

# Installation de Ansible, et la dépendance sshpass
apt install ansible sshpass python3 python3-mysqldb python3-pymysql -y

# Installation du plugin ansible "community.mysql" pour MariaDB
ansible-galaxy collection install community.mysql

# Création utilisateur local ansible et ajout aux utilisateurs "NO PASSWORD" de sudo
sudo useradd -m -s /bin/bash ansible
passwd ansible
echo 'ansible ALL=(ALL) NOPASSWD: ALL' | tee -a /etc/sudoers

# Initialisation du répertoire /etc/ansible
mkdir -p /etc/ansible/{playbooks,roles,group_vars,host_vars,clients}
cd /etc/ansible
ansible-config init --disabled > ansible.cfg
touch /hosts

# Désactivation de la vérification de signature dans le fichier ansible.cfg
sed -i 's/host_key_checking=True/host_key_checking=False/' ansible.cfg

# Configuration du répertoire des playbooks dans le fichier ansible.cfg
sed -i 's/:\/etc\/ansible\/roles/:\/etc\/ansible\/roles:\/etc\/ansible\/playbooks/' ansible.cfg

# Configuration de l'interpréteur Python dans le fichier ansible.cfg
sed -i 's/interpreter_python=auto/interpreter_python=\/usr\/bin\/python3/' ansible.cfg

# Configuration du fichier "/etc/hosts" pour la résolution de nom de serveur "SRV-GLPI"
echo -e "192.168.1.201 SRV-GLPI\n" | tee -a /etc/hosts

# Configuration du fichier "/etc/hosts" pour la résolution de nom du site web "client1.glpi-server.lan"
echo -e "192.168.1.201 client1.glpi-server.lan\n192.168.1.201 www.client1.glpi-server.lan\n" | tee -a /etc/hosts

# Défintion du group d'hôtes "glpiserver" et "webserver" et ajout de l'hôte SRV-GLPI (192.168.1.201)
echo -e "[webserver]\nSRV-GLPI" | tee -a /etc/ansible/hosts
echo -e "[glpiserver]\nSRV-GLPI" | tee -a /etc/ansible/hosts

# Création des répertoires de rôles
ansible-galaxy init /etc/ansible/roles/create-user-ssh
ansible-galaxy init /etc/ansible/roles/update-server
ansible-galaxy init /etc/ansible/roles/install-tools
ansible-galaxy init /etc/ansible/roles/install-lamp
ansible-galaxy init /etc/ansible/roles/secure-web-server
ansible-galaxy init /etc/ansible/roles/install-glpi
ansible-galaxy init /etc/ansible/roles/activate-glpi-web

# Création des playbooks
touch ./playbooks/{prepare-web-server.yml,install-glpi.yml,update-glpi.yml}

# Création et configuration d'un fichier client "client1.yml"
touch /etc/ansible/clients/client1.yml
echo -e "client_name: "entreprise1"\nclient_username: "client1"\nclient_password: "client1"\nclient_url: "client1.glpi-server.lan"\n" | tee -a /etc/ansible/clients/client1.yml

# Clonage du repository Github
mkdir /etc/ansible/github
cd /etc/ansible/github
git clone https://github.com/ShiftTechSecurity/PR08-ANSIBLE.git
cp -r /etc/ansible/github/PR08-ANSIBLE/* /etc/ansible
rm -r /etc/ansible/github

# Changement d'utilisateur
su ansible

# Execute the create-ansible-user playbook
ansible-playbook -e @/etc/ansible/clients/client1.yml prepare-web-server.yml -bkK

# Execute the deploy-glpi playbook
ansible-playbook -e @/etc/ansible/clients/client1.yml install-glpi.yml -bkK
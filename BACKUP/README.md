# Serveur de backups

## Informations générales

- IP Publique
```
188.165.231.196
```

- Port SSH
``` SHELL
Port 2013
```

## Configuration

- Changement du Hostname

``` SHELL
sudo hostnamectl set-hostname backup
```

``` SHELL
vim /etc/hosts
```

``` SHELL
sudo reboot now
```

- Ajout des utilisateurs
``` SHELL
adduser mxm
```

## SSH

- Création du fichier contenant les clés autorisées
``` SHELL
mkdir /home/user/.ssh/
vim /home/user/.ssh/authorized_keys
```

- Modification du port
``` SHELL
vim /etc/ssh/sshd_config
Port 2013
```

## Utilitaires de base

Installation des utilisataires systèmes
``` SHELL
apt -y install iptables-persistent neofetch net-tools vim
```
- `apt-transport-https` : utilisation d'apt sur https
- `ccze` : outil de colorisation des logs
- `curl` 
- `iptables-persistent` : version sauvegardable du firewall
- `net-tools` : utilitaires réseau
- `neofetch` : affiche les informations système en mode semi graphique
- `vim` : éditeur de texte en ligne de commandes

## Sécurisation
- Installation de crowdsec
- Installation du MFA
- Fichier IPTABLES-Persistent

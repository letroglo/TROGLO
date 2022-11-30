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
adduser bbrun
adduser jarnaud
```

## SSH

- Création du fichier contenant les clés autorisées
``` SHELL
mkdir /home/user/.ssh/
vim /home/user/.ssh/authorized_keys
```

- Modification du port SSH
``` SHELL
vim /etc/ssh/sshd_config
Port 2013
```

``` SHELL
sudo systemctl restart sshd
```

- Création d'une clé SSH pour root
``` SHELL
sudo su - 
```

``` SHELL
ssh-keygen -t rsa -b 4096 -C "root@backup"
```

- Copie de cette clé dans le repertoire `/root/.ssh/authorized_keys` des autres machines.

- Connexion aux serveurs depuis le serveur de backups.
``` SHELL
ssh root@portail-pp.le-troglo.fr -p 2046
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

## Rsnapshot

### Installation

``` SHELL
apt -y install rsnapshot
```

### Configuration

`/etc/rsnapshot.conf`

``` SHELL
retain    hourly    4
retain    daily     7
retain    weekly    4
retain    monthly   3

snapshot_root    /backup

cmd_ssh          /usr/bin/ssh

ssh_args         -p 2046
```

## Crontab
0 */6 * * * root /usr/bin/rsnapshot hourly

## Sécurisation

### Installation de `crowdsec`

``` SHELL
curl -s https://packagecloud.io/install/repositories/crowdsec/crowdsec/script.deb.sh | sudo bash
```

``` SHELL
apt -y install crowdsec
```

``` SHELL
systemctl status crowdsec
```

- Édition du fichier de configuration `/etc/crowdsec/config.yaml` pour ajouter `use_wal: true` à la ligne 29.

- Voir les décisions prises 
``` SHELL
cscli decisions list
```

- Installation du bouncer basique
``` SHELL
apt install crowdsec-firewall-bouncer-iptables
```

- Installation de crowdsec
- Installation du MFA
- Fichier IPTABLES-Persistent

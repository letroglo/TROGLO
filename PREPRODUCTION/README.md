# Configuration Y-U-NO-HOST

## Changement port ssh

- Édition du fichier de configuration SSH pour changer le port

```bash
set security.ssh.port -v 2046
```

- Vérification de l'ouverture du port
```bash
sudo yunohost firewall list
```

- Pour se connecter au serveur en SSH
```bash
ssh username@151.80.27.19 -p 2046
```

- Ajout des utilisateurs `mxm`, `bbrun` , `jarnaud` depuis l'interface graphique

- Ajout des utilisateurs au groupe sudo 
```bash
sudo usermod -aG sudo mxm
sudo usermod -aG sudo bbrun
sudo usermod -aG sudo jarnaud
```

- Changer domaine principale
```bash
yunohost domain main-domain -n portail-pp.le-troglo.fr

## Crontab
```SHELL
0 */4 * * * /home/troglo/scripts/backup_create.sh
```

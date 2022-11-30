#!/bin/bash

AUTOMATIC_BACKUP_FOLDER=/home/yunohost.backup/archives/automatic_backup

# Vérification si le dossier existe
if [[ ! -d $AUTOMATIC_BACKUP_FOLDER ]]
then
    mkdir $AUTOMATIC_BACKUP_FOLDER
fi

# Supression des anciennes sauvegardes
sudo rm -r ${AUTOMATIC_BACKUP_FOLDER}/*

# Sauvegarde
sudo yunohost backup create -o $AUTOMATIC_BACKUP_FOLDER

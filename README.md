## Forensic et autres fichiers en bash

Analyse les fichiers .pcap pour les protocoles décrit dans leur nom de fichier.
Pour utiliser : il faut changer le chemin du dossier contenant tous les fichiers .pcap dans la variable "répertoire", dans mon cas, je l'ai ajusté pour mon environnement.

## déchiffrement

Déchiffre tous les fichiers chiffrés en .pachy avec un fichier contenant la paire clef/iv séparés par ":" une clé et une iv par ligne. 
Les fichiers doivent être disposés dans des sous-dossiers chacuns contenant un des fichiers. 

Pour l'utiliser:
python [fichier.py] [chemin vers le fichier contenant les clef et iv] [chemin vers le dossier contenant les fichiers à déchiffrés] [chemin vers le dossier où vont les fichiers déchiffrés]

Le fichier contenant la paire clef et iv doivent être formaté ainsi : [clef]:[iv]

## Hash

Permet de calculer le hash des fichiers qui nous ont été utiles durant notre enquête 

(1696868126_netlog.zip , 1696889994_netlog.zip, 1696890361_netlog.zip, debian-rsyslog.img, jv_windows_memory.mem, rsyslog_server_memory.lime, win11-2-debauchateau.img, win11-giselle.img, win11-laela.img)

Pour analyser un fichier en md5 ou sha512, il faut changer le chemin du fichier dans la variable "file_path"

#start.sh et start.service, chicxulub.ps1, setup.sh, crypto_app.exe, dilophosaurus.ko 

Ce sont des fichiers trouvés durant notre enquête.

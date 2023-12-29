#!/bin/bash

# Répertoire contenant les fichiers pcap
repertoire="/home/lucas/archive/archives"

# Fichier de sortie pour les résultats UDP
fichier_sortie_udp="resultats_udp.txt"

# Supprimer le fichier de sortie s'il existe déjà
rm -f "$fichier_sortie_udp"

# Utiliser un tableau pour stocker les lignes uniques
declare -A lignes_uniques

# Compteur pour le nombre de fichiers analysés
compteur_fichiers=0

# Parcourir récursivement les fichiers pcap dans le répertoire
find "$repertoire" -type f -name "*.pcap" | while read fichier_pcap; do
    ((compteur_fichiers++))
    echo "Analyse du fichier $compteur_fichiers : $fichier_pcap"

    # Capturer les paquets UDP
    tshark -r "$fichier_pcap" -Y "udp" -T fields -e ip.src -e ip.dst -e udp.srcport -e udp.dstport -V | while IFS=$'\t' read -r ip_src ip_dst udp_src_port udp_dst_port; do
        ligne="$ip_src $ip_dst UDP $udp_src_port $udp_dst_port"

        # Vérifier si la ligne est déjà dans le tableau
        if [[ -z "${lignes_uniques[$ligne]}" ]]; then
            # Si la ligne n'est pas encore enregistrée, l'ajouter au fichier de sortie
            echo "$ligne" >> "$fichier_sortie_udp"

            # Marquer la ligne comme déjà enregistrée dans le tableau
            lignes_uniques["$ligne"]=1
        fi
    done
done

echo "L'analyse UDP est terminée. Les résultats uniques ont été enregistrés dans $fichier_sortie_udp."
echo "Nombre total de fichiers analysés : $compteur_fichiers"

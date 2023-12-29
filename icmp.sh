#!/bin/bash

# Répertoire contenant les fichiers pcap
repertoire="/home/lucas/archive/archives"

# Fichier de sortie pour les résultats ICMP
fichier_sortie_icmp="resultats_icmp.txt"

# Supprimer le fichier de sortie s'il existe déjà
rm -f "$fichier_sortie_icmp"

# Utiliser un tableau pour stocker les lignes uniques
declare -A lignes_uniques

# Compteur pour le nombre de fichiers analysés
compteur_fichiers=0

# Parcourir récursivement les fichiers pcap dans le répertoire
find "$repertoire" -type f -name "*.pcap" | while read fichier_pcap; do
    ((compteur_fichiers++))
    echo "Analyse du fichier $compteur_fichiers : $fichier_pcap"

    # Capturer les paquets ICMP
    tshark -r "$fichier_pcap" -Y "icmp" -T fields -e ip.src -e ip.dst -e icmp.type -e icmp.code -V | while IFS=$'\t' read -r ip_src ip_dst icmp_type icmp_code; do
        ligne="$ip_src $ip_dst ICMP $icmp_type $icmp_code"

        # Vérifier si la ligne est déjà dans le tableau
        if [[ -z "${lignes_uniques[$ligne]}" ]]; then
            # Si la ligne n'est pas encore enregistrée, l'ajouter au fichier de sortie
            echo "$ligne" >> "$fichier_sortie_icmp"

            # Marquer la ligne comme déjà enregistrée dans le tableau
            lignes_uniques["$ligne"]=1
        fi
    done
done

echo "L'analyse ICMP est terminée. Les résultats uniques ont été enregistrés dans $fichier_sortie_icmp."
echo "Nombre total de fichiers analysés : $compteur_fichiers"

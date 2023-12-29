#!/bin/bash

# Répertoire contenant les fichiers pcap
repertoire="/home/lucas/archive/archives"

# Fichier de sortie pour les résultats HTTPS
fichier_sortie_https="resultats_https.txt"

# Supprimer le fichier de sortie s'il existe déjà
rm -f "$fichier_sortie_https"

# Utiliser un tableau pour stocker les lignes uniques
declare -A lignes_uniques

# Compteur pour le nombre de fichiers analysés
compteur_fichiers=0

# Parcourir récursivement les fichiers pcap dans le répertoire
find "$repertoire" -type f -name "*.pcap" | while read fichier_pcap; do
    ((compteur_fichiers++))
    echo "Analyse du fichier $compteur_fichiers : $fichier_pcap"

    # Capturer les paquets HTTPS
    tshark -r "$fichier_pcap" -Y "tcp.port == 443" -T fields -e ip.src -e ip.dst -e tcp.srcport -e tcp.dstport -e http.host -e http.request.uri -e http.response.code -V | while IFS=$'\t' read -r ip_src ip_dst tcp_src_port tcp_dst_port http_host http_uri http_response_code; do
        ligne="$ip_src $ip_dst $tcp_src_port $tcp_dst_port $http_host $http_uri $http_response_code"

        # Vérifier si la ligne est déjà dans le tableau
        if [[ -z "${lignes_uniques[$ligne]}" ]]; then
            # Si la ligne n'est pas encore enregistrée, l'ajouter au fichier de sortie
            echo "$ligne" >> "$fichier_sortie_https"

            # Marquer la ligne comme déjà enregistrée dans le tableau
            lignes_uniques["$ligne"]=1
        fi
    done
done

echo "L'analyse HTTPS est terminée. Les résultats uniques ont été enregistrés dans $fichier_sortie_https."
echo "Nombre total de fichiers analysés : $compteur_fichiers"

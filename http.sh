#!/bin/bash

# Répertoire contenant les fichiers pcap
repertoire="/home/lucas/archive/archives"

# Fichier de sortie pour les résultats
fichier_sortie="resultats4.txt"

# Supprimer le fichier de sortie s'il existe déjà
rm -f "$fichier_sortie"

# Utiliser un tableau pour stocker les lignes uniques
declare -A lignes_uniques

# Compteur pour le nombre de fichiers analysés
compteur_fichiers=0

# Parcourir récursivement les fichiers pcap dans le répertoire
find "$repertoire" -type f -name "*.pcap" | while read fichier_pcap; do
    ((compteur_fichiers++))
    echo "Analyse du fichier $compteur_fichiers : $fichier_pcap"
    
    # Capturer les requêtes GET HTTP (port 80) avec tshark
    tshark -r "$fichier_pcap" -Y "tcp.port == 80 and http.request.method == GET" -T fields -e ip.src -e ip.dst -e tcp.srcport -e tcp.dstport -e http.request.uri -e http.response.code -E separator=' ' -E header=y -E occurrence=f -E quote=d -E aggregator=' ' -E quote=d -V | while IFS=$' ' read -r ip_src ip_dst tcp_src_port tcp_dst_port http_request_uri http_response_code; do
        ligne="$ip_src $ip_dst $tcp_src_port $tcp_dst_port $http_request_uri $http_response_code $fichier_pcap"
        
        # Vérifier si la ligne est déjà dans le tableau
        if [[ -z "${lignes_uniques[$ligne]}" ]]; then
            # Si la ligne n'est pas encore enregistrée, l'ajouter au fichier de sortie
            echo "$ligne" >> "$fichier_sortie"
            
            # Marquer la ligne comme déjà enregistrée dans le tableau
            lignes_uniques["$ligne"]=1
        fi
    done
done

echo "L'analyse est terminée. Les résultats uniques ont été enregistrés dans $fichier_sortie."
echo "Nombre total de fichiers analysés : $compteur_fichiers"

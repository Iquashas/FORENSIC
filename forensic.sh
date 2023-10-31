#!/bin/bash

repertoire="/home/lucas/archives/archives"

fichier_sortie="resultats.txt"

rm -f "$fichier_sortie"

declare -A lignes_uniques

compteur_fichiers=0

find "$repertoire" -type f -name "*.pcap" | while read fichier_pcap; do
    ((compteur_fichiers++))
    echo "Analyse du fichier $compteur_fichiers : $fichier_pcap"
    
    tshark -r "$fichier_pcap" -Y "tcp.port == 80 and http.request.method == GET and not (http.request.uri contains filestreamingservice or http.request.uri contains msdownload or http.request.uri contains ubuntu or http.request.uri contains dists)" -T fields -e ip.src -e ip.dst -e tcp.srcport -e tcp.dstport -e http.request.uri -e http.response.code -V | while IFS=$'\t' read -r ip_src ip_dst tcp_src_port tcp_dst_port http_request_uri http_response_code; do
        ligne="$ip_src $ip_dst $tcp_src_port $tcp_dst_port $http_request_uri $http_response_code"
        
        if [[ -z "${lignes_uniques[$ligne]}" ]]; then
            echo "$ligne" >> "$fichier_sortie"
            
            lignes_uniques["$ligne"]=1
        fi
    done
done

echo "L'analyse est terminée. Les résultats uniques ont été enregistrés dans $fichier_sortie."
echo "Nombre total de fichiers analysés : $compteur_fichiers"

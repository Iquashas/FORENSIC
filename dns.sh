#!/bin/bash

# Répertoire contenant les fichiers pcap
repertoire="/home/lucas/archives/archives"

# Fichier de sortie pour les résultats
fichier_sortie_query="resultats_dns_query.txt"
fichier_sortie_response="resultats_dns_response.txt"
fichier_sortie_update="resultats_dns_update.txt"
fichier_sortie_transfer="resultats_zone_transfer.txt"
fichier_sortie_errors="resultats_dns_errors.txt"

# Supprimer les fichiers de sortie s'ils existent déjà
rm -f "$fichier_sortie_query"
rm -f "$fichier_sortie_response"
rm -f "$fichier_sortie_update"
rm -f "$fichier_sortie_transfer"
rm -f "$fichier_sortie_errors"

# Utiliser un tableau pour stocker les lignes uniques pour chaque type
declare -A lignes_uniques_query
declare -A lignes_uniques_response
declare -A lignes_uniques_update
declare -A lignes_uniques_transfer
declare -A lignes_uniques_errors

# Compteurs pour le nombre de fichiers analysés
compteur_fichiers=0

# Parcourir récursivement les fichiers pcap dans le répertoire
find "$repertoire" -type f -name "*.pcap" | while read fichier_pcap; do
    ((compteur_fichiers++))
    echo "Analyse du fichier $compteur_fichiers : $fichier_pcap"
    
    # Capturer les paquets DNS Query avec tshark
    tshark -r "$fichier_pcap" -Y "dns.qry.type == 1" -T fields -e ip.src -e ip.dst -e dns.qry.name -e dns.qry.type -V | while IFS=$'\t' read -r ip_src ip_dst dns_name dns_type; do
        ligne="$ip_src $ip_dst $dns_name $dns_type"
        if [[ -z "${lignes_uniques_query[$ligne]}" ]]; then
            echo "$ligne" >> "$fichier_sortie_query"
            lignes_uniques_query["$ligne"]=1
        fi
    done
    
    # Capturer les paquets DNS Response avec tshark
    tshark -r "$fichier_pcap" -Y "dns.resp.type" -T fields -e ip.src -e ip.dst -e dns.qry.name -e dns.resp.type -V | while IFS=$'\t' read -r ip_src ip_dst dns_name dns_type; do
        ligne="$ip_src $ip_dst $dns_name $dns_type"
        if [[ -z "${lignes_uniques_response[$ligne]}" ]]; then
            echo "$ligne" >> "$fichier_sortie_response"
            lignes_uniques_response["$ligne"]=1
        fi
    done
    
    # Capturer les paquets DNS Update avec tshark
    tshark -r "$fichier_pcap" -Y "dns.flags.opcode == 5" -T fields -e ip.src -e ip.dst -e dns.qry.name -e dns.flags.opcode -V | while IFS=$'\t' read -r ip_src ip_dst dns_name dns_opcode; do
        ligne="$ip_src $ip_dst $dns_name $dns_opcode"
        if [[ -z "${lignes_uniques_update[$ligne]}" ]]; then
            echo "$ligne" >> "$fichier_sortie_update"
            lignes_uniques_update["$ligne"]=1
        fi
    done
    
    # Capturer les paquets Zone Transfer avec tshark
    tshark -r "$fichier_pcap" -Y "dns.qry.type == 252" -T fields -e ip.src -e ip.dst -e dns.qry.name -e dns.qry.type -V | while IFS=$'\t' read -r ip_src ip_dst dns_name dns_type; do
        ligne="$ip_src $ip_dst $dns_name $dns_type"
        if [[ -z "${lignes_uniques_transfer[$ligne]}" ]]; then
            echo "$ligne" >> "$fichier_sortie_transfer"
            lignes_uniques_transfer["$ligne"]=1
        fi
    done
    
    # Capturer les erreurs DNS avec tshark
    tshark -r "$fichier_pcap" -Y "dns.flags.rcode != 0" -T fields -e ip.src -e ip.dst -e dns.flags.rcode -V | while IFS=$'\t' read -r ip_src ip_dst dns_rcode; do
        ligne="$ip_src $ip_dst $dns_rcode"
        if [[ -z "${lignes_uniques_errors[$ligne]}" ]]; then
            echo "$ligne" >> "$fichier_sortie_errors"
            lignes_uniques_errors["$ligne"]=1
        fi
    done
done

echo "L'analyse est terminée. Les résultats uniques ont été enregistrés dans les fichiers correspondants."
echo "Nombre total de fichiers analysés : $compteur_fichiers"

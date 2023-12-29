#!/bin/bash

# Répertoire contenant les fichiers pcap
repertoire="/home/lucas/archive/archives"

# Fichier de sortie pour les résultats UDP de 51.38.185.89
fichier_sortie_udp="resultats_udp_51.38.185.89.txt"

# Supprimer le fichier de sortie s'il existe déjà
rm -f "$fichier_sortie_udp"

# Utiliser un tableau pour stocker les lignes uniques
declare -A lignes_uniques_udp

# Compteur pour le nombre de fichiers analysés
compteur_fichiers=0

# Adresse IP à filtrer
adresse_ip_filtre="51.38.185.89"

# Fonction pour convertir les données hexadécimales en texte
hex_to_text() {
    echo "$1" | hexdump -e '1/1 "%02x" "\n"' -c | sed 's/\(..\)/\\x\1/g'
}

# Parcourir récursivement les fichiers pcap dans le répertoire
find "$repertoire" -type f -name "*.pcap" | while read fichier_pcap; do
    ((compteur_fichiers++))
    echo "Analyse du fichier $compteur_fichiers : $fichier_pcap"

    # Capturer les paquets UDP de l'adresse IP spécifiée avec tshark
    tshark -r "$fichier_pcap" -Y "udp && ip.dst == $adresse_ip_filtre" -T fields -e ip.src -e ip.dst -e udp.srcport -e udp.dstport -e data.data -V | while IFS=$'\t' read -r ip_src ip_dst udp_src_port udp_dst_port data_content; do
        ligne="$ip_src $ip_dst $udp_src_port $udp_dst_port $data_content"
        if [[ -z "${lignes_uniques_udp["$ligne"]}" ]]; then
            echo "$ligne" >> "$fichier_sortie_udp"
            lignes_uniques_udp["$ligne"]=1
            # Convertir les données hexadécimales en texte et les ajouter à la ligne
            texte_en_clair=$(hex_to_text "$data_content")
            echo "Contenu en clair : $texte_en_clair" >> "$fichier_sortie_udp"
        fi
    done
done

echo "L'analyse est terminée. Les résultats uniques ont été enregistrés dans le fichier de réponse UDP de 51.38.185.89."
echo "Nombre total de fichiers analysés : $compteur_fichiers"

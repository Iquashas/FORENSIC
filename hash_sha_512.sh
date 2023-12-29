#!/bin/bash

file_path="./debian-rsyslog.img"
hash=$(sha512sum "$file_path" | awk '{print $1}')

echo "SHA-512 du fichier $file_path : $hash"

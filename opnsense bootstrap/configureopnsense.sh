#!/bin/sh

fetch https://raw.githubusercontent.com/bahkuyt/opnsense/main/opnsense%20bootstrap/config.xml
fetch https://raw.githubusercontent.com/bahkuyt/opnsense/main/opnsense%20bootstrap/get_nic_gw.py
gwip=$(python get_nic_gw.py "10.1.200.0/24")
sed -i "" "s/yyy.yyy.yyy.yyy/$gwip/" config.xml
sed -i "" "s_zzz.zzz.zzz.zzz_1.1.1.1/32_" config.xml
cp config.xml /usr/local/etc/config.xml

env IGNORE_OSVERSION=yes
pkg bootstrap -f; pkg update -f
env ASSUME_ALWAYS_YES=YES pkg install ca_root_nss && pkg install -y bash


fetch https://raw.githubusercontent.com/opnsense/update/master/src/bootstrap/opnsense-bootstrap.sh.in
sed -i "" 's/#PermitRootLogin no/PermitRootLogin yes/' /etc/ssh/sshd_config

sed -i "" "s/reboot/shutdown -r +1/g" opnsense-bootstrap.sh.in
sh ./opnsense-bootstrap.sh.in -y -r "23.1"


fetch https://github.com/Azure/WALinuxAgent/archive/refs/tags/v2.8.0.11.tar.gz
tar -xvzf v2.8.0.11.tar.gz
cd WALinuxAgent-2.8.0.11/
python3 setup.py install --register-service --lnx-distro=freebsd --force
cd ..


ln -s /usr/local/bin/python3.9 /usr/local/bin/python
sed -i "" 's/ResourceDisk.EnableSwap=y/ResourceDisk.EnableSwap=n/' /etc/waagent.conf
fetch https://raw.githubusercontent.com/dmauser/opnazure/master/scripts/actions_waagent.conf
cp actions_waagent.conf /usr/local/opnsense/service/conf/actions.d


pkg install -y bash


cat > /usr/local/etc/rc.syshook.d/start/22-remoteroute <<EOL
#!/bin/sh
route delete 168.63.129.16
EOL
chmod +x /usr/local/etc/rc.syshook.d/start/22-remoteroute




echo static_arp_pairs=\"azvip\" >>  /etc/rc.conf
echo static_arp_azvip=\"168.63.129.16 12:34:56:78:9a:bc\" >> /etc/rc.conf

service static_arp start

echo service static_arp start >> /usr/local/etc/rc.syshook.d/start/20-freebsd


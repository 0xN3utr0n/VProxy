#!/bin/sh

GREEN='\033[0;32m'
NC='\033[0m'

function CheckOpenVpn {
    ps -ef | grep -v grep | grep "openvpn" &> /dev/null
    if [ $? -eq 1 ]; then 
        echo "Openvpn failed: quitting"
        exit 1
    fi
}

local=$(ifconfig | grep inet | head -n1 | cut -d' ' -f10)

echo -e "\nLocal IP: ${GREEN}$local${NC}"

openvpn --user user --persist-tun --config /root/vpn/$(ls /root/vpn/ | grep $VPN_NAME) --daemon vpn

inet=" "
while [ "$inet" != "tun0:" ]
do
    CheckOpenVpn
    inet=$(ifconfig | grep tun0 | head -n1 | awk ' "\t" {print $1}')
    sleep 2
done

echo -e "VPN IP:   ${GREEN}$(ifconfig | grep inet | tail -n1 | cut -d' ' -f10)${NC}"

/etc/init.d/ssh start 1> /dev/null &
sleep 3
su user -c "ssh -f -q -o 'StrictHostKeyChecking no' -N -D 0.0.0.0:$PROXY_PORT 127.0.0.1"  

echo -e "\nAllowed IP's: ${GREEN}[$IP_ADDRESSES]${NC}"

SCAN=':' read -ra IP_LIST <<< $IP_ADDRESSES
for addr in "${IP_LIST[@]}"; do
    iptables -A INPUT -s $addr -p tcp --dport $PROXY_PORT -j ACCEPT
done

iptables -A INPUT -p tcp --dport $PROXY_PORT -j DROP

if [ $TOR == "T" ]; then
    iptables -t nat -I PREROUTING -p tcp -d $local --dport $PROXY_PORT -j DNAT --to-destination 127.0.0.1:9050
    su user -c "tor 1> /dev/null &"
    sleep 4
    echo -e "\n${GREEN}TOR ON"
fi

echo -e "\n${GREEN}OK\n"

while true
do 
    CheckOpenVpn
	sleep 10
done


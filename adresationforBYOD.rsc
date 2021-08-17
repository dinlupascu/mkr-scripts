/ip firewall mangle add chain=prerouting src-address=10.135.20.0/24 connection-mark=no-mark action=mark-connection new-connection-mark=ISP1



:global ipraddr 10.135.10.10/24

/ip arp add address= mac-address= interface=BYOD-VLAN
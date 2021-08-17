#marking traffic


ISP1
/ip firewall mangle
add action=mark-connection chain=prerouting comment=ISP1 connection-state=new in-interface=ether1 new-connection-mark=from-ISP1 passthrough=yes
add action=mark-routing chain=prerouting connection-mark=from-ISP1 new-routing-mark=to-ISP1 passthrough=yes
add action=mark-routing chain=output connection-mark=from-ISP1 new-routing-mark=to-ISP1 passthrough=yes
add action=mark-routing chain=output new-routing-mark=to-ISP1 passthrough=yes src-address=188.200.x.x


BYOD-ISP1
/ip firewall mangle
add action=mark-connection chain=prerouting comment=BYOD-ISP1 connection-state=new in-interface=STARNET new-connection-mark=from-BYOD-ISP1 passthrough=yes
add action=mark-routing chain=prerouting connection-mark=from-BYOD-ISP1 new-routing-mark=to-BYOD-ISP1 passthrough=yes
add action=mark-routing chain=output connection-mark=from-BYOD-ISP1 new-routing-mark=to-BYOD-ISP1 passthrough=yes
add action=mark-routing chain=output new-routing-mark=to-BYOD-ISP1 passthrough=yes src-address=188.244.x.x


#routes 

/ip route
add distance=1 gateway=188.244.x.x routing-mark=ISP1
add distance=1 gateway=188.244.x.x routing-mark=BYOD-ISP1
add comment=WAN1 distance=1 gateway=188.244.x.x

#create route rules for marked trafic

/ip route rule
add src-address=188.244.x.x/32 table=ISP1
add src-address=188.244.x.x/32 table=BYOD-ISP1
add dst-address=10.0.0.0/8 table=main
add dst-address=192.168.0.0/16 table=main
add dst-address=172.16.0.0/12 table=main
add routing-mark=to-ISP1 table=ISP1
add routing-mark=to-BYOD-ISP1 table=BYOD-ISP1

#nat
/ip firewall nat
add action=masquerade chain=srcnat out-interface=ether1
add action=masquerade chain=srcnat out-interface=ether2

###### check this routing rule and mangle 


/ip firewall mangle add chain=prerouting src-address=10.135.20.0/24 action=mark-routing new-routing-mark=ISP1-BYOD
/ip route add distance=1 gateway=188.244.20.56 dst-address=188.244.x.x/23 routing-mark=ISP1-BYOD




#experimental need to check how goes traffic to external IP
:local RSGWDistance [/ip route get [find comment="WAN2"] distance];
:if ( $RSGWDistance = 1 ) do={ :put [/ip firewall nat set [find comment="BYOD"] chain=srcnat src-address=10.135.20.0/24 action=src-nat to-addresses=93.115.143.154 out-interface=STARNET]};
:if ( $RSGWDistance = 2 ) do={ :put [/ip firewall nat set [find comment="BYOD"] chain=srcnat src-address=10.135.20.0/24 action=src-nat to-addresses=188.244.20.57 out-interface=MTC]};
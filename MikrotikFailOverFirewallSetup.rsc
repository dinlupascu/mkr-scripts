#marking traffic


ISP1
/ip firewall mangle
add action=mark-connection chain=prerouting comment=ISP1 connection-state=new in-interface=ether1 new-connection-mark=from-ISP1 passthrough=yes
add action=mark-routing chain=prerouting connection-mark=from-ISP1 new-routing-mark=to-ISP1 passthrough=yes
add action=mark-routing chain=output connection-mark=from-ISP1 new-routing-mark=to-ISP1 passthrough=yes
add action=mark-routing chain=output new-routing-mark=to-ISP1 passthrough=yes src-address=188.244.x.x




ISP2
/ip firewall mangle
add action=mark-connection chain=prerouting comment=ISP2 in-interface=ether2 new-connection-mark=from-ISP2 passthrough=yes
add action=mark-routing chain=prerouting connection-mark=from-ISP2 new-routing-mark=to-ISP2 passthrough=yes
add action=mark-routing chain=output connection-mark=from-ISP2 new-routing-mark=to-ISP2 passthrough=yes
add action=mark-routing chain=output new-routing-mark=to-ISP2 passthrough=yes src-address=93.115.x.x

#routes 

/ip route
add distance=1 gateway=188.244.20.1 routing-mark=ISP1
add distance=1 gateway=93.115.143.153 routing-mark=ISP2
add comment=WAN1 distance=1 gateway=188.244.20.1
add comment=WAN2 distance=2 gateway=93.115.143.153

#create route rules for marked trafic

/ip route rule
add src-address=188.244.x.x/32 table=ISP1
add src-address=93.115.x.x/32 table=ISP2
add dst-address=10.0.0.0/8 table=main
add dst-address=192.168.0.0/16 table=main
add dst-address=172.16.0.0/12 table=main
add routing-mark=to-ISP1 table=ISP1
add routing-mark=to-ISP2 table=ISP2

#nat
/ip firewall nat
add action=masquerade chain=srcnat out-interface=ether1
add action=masquerade chain=srcnat out-interface=ether2

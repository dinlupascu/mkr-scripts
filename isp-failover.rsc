#Main interface name
:global MainIf STARNET
#Failover interface name
:global RsrvIf MTC
:local PingCount 1
:local PingTargets {8.8.4.4; 77.88.8.8; 8.8.8.8; 217.69.139.202}
:local host
:local MainIfInetOk false
:local RsrvIfInetOk false
:local MainPings 0
:local RsrvPings 0
foreach host in=$PingTargets do={
:local res [/ping $host count=$PingCount interface=$MainIf]
:set MainPings ($MainPings + $res)
:local res [/ping $host count=$PingCount interface=$RsrvIf]
:set RsrvPings ($RsrvPings + $res)
:delay 1
}
:set MainIfInetOk ($MainPings >= 1)
:set RsrvIfInetOk ($RsrvPings >= 1)
:put "MainIfInetOk=$MainIfInetOk"
:put "RsrvIfInetOk=$RsrvIfInetOk"
:local MainGWDistance [/ip route get [find comment="WAN1"] distance]
:local RsrvGWDistance [/ip route get [find comment="WAN2"] distance]
:put "MainGWDistance=$MainGWDistance"
:put "RsrvGWDistance=$RsrvGWDistance"
if (!$MainIfInetOk && $RsrvIfInetOk && ($MainGWDistance <= $RsrvGWDistance)) do={
/ip route set [find comment="WAN1"] distance=2
/ip route set [find comment="WAN2"] distance=1
:put "switched to reserve internet connection"
/log info "switched to reserve internet connection"
}
if ($MainIfInetOk && ($MainGWDistance >= $RsrvGWDistance)) do={
/ip route set [find comment="WAN1"] distance=1
/ip route set [find comment="WAN2"] distance=2
:put "switched to main internet connection"
/log info "switched to main internet connection"
}
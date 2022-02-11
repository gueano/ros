:global wanIntLst WAN

/ipv6 firewall address-list
	add address=fd00::/64 list=allowed_to_router
	add address=fe80::/16 list=allowed_to_router
	add address=ff02::/16 comment=multicast list=allowed_to_router


/ipv6 firewall filter
	add action=accept chain=input comment="allow established and related" connection-state=established,related
	add chain=input action=accept protocol=icmpv6 comment="accept ICMPv6"
	add chain=input action=accept protocol=udp port=33434-33534 comment="defconf: accept UDP traceroute"
	add chain=input action=accept protocol=udp dst-port=546 src-address=fe80::/16 comment="accept DHCPv6-Client prefix delegation."
	add action=drop chain=input in-interface-list=$wanIntLst log=yes log-prefix=dropALL_from_public src-address=fe80::/16
	add action=accept chain=input comment="allow allowed addresses" src-address-list=allowed_to_router
	add action=drop chain=input

	add action=accept chain=forward comment=established,related connection-state=established,related
	add action=drop chain=forward comment=invalid connection-state=invalid log=yes log-prefix=ipv6,invalid
	add action=accept chain=forward comment=icmpv6 in-interface-list="!$wanIntLst" protocol=icmpv6
	add action=accept chain=forward comment="local network" in-interface-list="!$wanIntLst"
	add action=drop chain=forward log-prefix=IPV6
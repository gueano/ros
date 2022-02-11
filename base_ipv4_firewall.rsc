:global allowToRouter "192.168.11.1-192.168.11.253"
:global lanCIDR "192.168.11.0/24"
:global lanIntLst LAN
:global wanIntLst WAN

/ip firewall filter
	add action=accept chain=input comment="default configuration" connection-state=established,related
	add action=accept chain=input src-address-list=allowed_to_router
	add action=accept chain=input protocol=icmp
	add action=drop chain=input


/ip firewall address-list
	add address=$allowToRouter list=allowed_to_router


/ip firewall address-list
	add address=0.0.0.0/8 comment=RFC6890 list=not_in_internet
	add address=172.16.0.0/12 comment=RFC6890 list=not_in_internet
	add address=192.168.0.0/16 comment=RFC6890 list=not_in_internet
	add address=10.0.0.0/8 comment=RFC6890 list=not_in_internet
	add address=169.254.0.0/16 comment=RFC6890 list=not_in_internet
	add address=127.0.0.0/8 comment=RFC6890 list=not_in_internet
	add address=224.0.0.0/4 comment=Multicast list=not_in_internet
	add address=198.18.0.0/15 comment=RFC6890 list=not_in_internet
	add address=192.0.0.0/24 comment=RFC6890 list=not_in_internet
	add address=192.0.2.0/24 comment=RFC6890 list=not_in_internet
	add address=198.51.100.0/24 comment=RFC6890 list=not_in_internet
	add address=203.0.113.0/24 comment=RFC6890 list=not_in_internet
	add address=100.64.0.0/10 comment=RFC6890 list=not_in_internet
	add address=240.0.0.0/4 comment=RFC6890 list=not_in_internet
	add address=192.88.99.0/24 comment="6to4 relay Anycast [RFC 3068]" list=not_in_internet


/ip firewall filter
	add action=fasttrack-connection chain=forward comment=FastTrack connection-state=established,related
	add action=accept chain=forward comment="Established, Related" connection-state=established,related
	add action=drop chain=forward comment="Drop invalid" connection-state=invalid log=yes log-prefix=invalid
	add action=drop chain=forward comment="Drop tries to reach not public addresses from LAN" dst-address-list=not_in_internet in-interface-list=$lanIntLst log=yes log-prefix=!public_from_LAN out-interface-list="!$lanIntLst"
	add action=drop chain=forward comment="Drop incoming packets that are not NAT`ted" connection-nat-state=!dstnat connection-state=new in-interface-list=$wanIntLst log=yes log-prefix=!NAT
	add action=jump chain=forward protocol=icmp jump-target=icmp comment="jump to ICMP filters"
	add action=drop chain=forward comment="Drop incoming from internet which is not public IP" in-interface-list=$wanIntLst log=yes log-prefix=!public src-address-list=not_in_internet
	add action=drop chain=forward comment="Drop packets from LAN that do not have LAN IP" in-interface-list=$lanIntLst log=yes log-prefix=LAN_!LAN src-address="!$lanCIDR"

	add chain=icmp protocol=icmp icmp-options=0:0 action=accept comment="echo reply"
	add chain=icmp protocol=icmp icmp-options=3:0 action=accept comment="net unreachable"
	add chain=icmp protocol=icmp icmp-options=3:1 action=accept comment="host unreachable"
	add chain=icmp protocol=icmp icmp-options=3:4 action=accept comment="host unreachable fragmentation required"
	add chain=icmp protocol=icmp icmp-options=8:0 action=accept comment="allow echo request"
	add chain=icmp protocol=icmp icmp-options=11:0 action=accept comment="allow time exceed"
	add chain=icmp protocol=icmp icmp-options=12:0 action=accept comment="allow parameter bad"
	add chain=icmp action=drop comment="deny all other types"
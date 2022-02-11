/tool mac-server set allowed-interface-list=LAN
/tool mac-server mac-winbox set allowed-interface-list=LAN
/tool mac-server ping set enabled=no
/tool bandwidth-server set enabled=no

/ip neighbor discovery-settings set discover-interface-list=none

/ip proxy set enabled=no
/ip socks set enabled=no
/ip upnp set enabled=no
/ip cloud set ddns-enabled=no update-time=no

/ip service 
	set winbox disabled=no
	set ssh disabled=yes
	set telnet disabled=yes
	set www disabled=yes
	set www-ssl disabled=yes
	set api disabled=yes
	set api-ssl disabled=yes
	set ftp disabled=yes

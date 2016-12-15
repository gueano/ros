:global pppoePrefix "pppoe-out"
:global srcAddress 192.168.1.0/24
:global pppoeCount 2

:for i from=0 to=($pppoeCount-1) do={
    :local pppoeName ($pppoePrefix . $i+1)
    :local conn ($pppoeName . "Conn")
    :local pppRoute ($pppoeName . "Routing")

    /ip firewall mangle
    add action=mark-connection chain=prerouting comment=\
        ("pcc connection mark for" . $pppoeName) connection-state=new \
        new-connection-mark=$conn per-connection-classifier=\
        ("both-addresses:" . $pppoeCount . "/" .$i) src-address=$srcAddress \
        passthrough=yes dst-address-type=!local
    add action=mark-routing chain=prerouting comment=\
        ("pcc route mark for " . $pppoeName) connection-mark=$conn \
        new-routing-mark=$pppRoute src-address=$srcAddress \
        passthrough=no dst-address-type=!local

    /ip route
        add comment=("router for " . $pppoeName) distance=1 gateway=$pppoeName \
        routing-mark=$pppRoute check-gateway=ping
}

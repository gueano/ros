# dec/15/2016 17:59:48 by RouterOS 6.36
# software id = F5YP-9KEI
#

:global lanInterface "ether1"
:global wanInterface "all-ppp"

/ip firewall mangle
    add action=mark-packet chain=prerouting comment="all download package" \
        in-interface=$wanInterface log-prefix="" new-packet-mark=download_pkg \
        passthrough=yes
    add action=mark-packet chain=prerouting comment="http download package" \
        in-interface=$wanInterface log-prefix="" new-packet-mark=http_download_pkg \
        passthrough=yes protocol=tcp src-port="80,443"
    add action=mark-packet chain=prerouting comment="small download package" \
        in-interface=$wanInterface log-prefix="" new-packet-mark=small_download_pkg \
        packet-size="0-383" passthrough=yes
    add action=mark-packet chain=prerouting comment="p2p download package" \
        in-interface=$wanInterface log-prefix="" new-packet-mark=p2p_download_pkg \
        packet-size="512-65535" passthrough=yes protocol=udp src-port="54-65535"
    add action=mark-packet chain=prerouting comment="all upload package" \
        dst-address-type=!local in-interface=$lanInterface log-prefix="" \
        new-packet-mark=upload_pkg passthrough=yes
    add action=mark-packet chain=prerouting comment="http upload package" \
        dst-address-type=!local dst-port="80,443" in-interface=$lanInterface \
        log-prefix="" new-packet-mark=http_upload_pkg passthrough=yes protocol=\
        tcp
    add action=mark-packet chain=prerouting comment="small upload package" \
        dst-address-type=!local in-interface=$lanInterface log-prefix="" \
        new-packet-mark=small_upload_pkg packet-size="0-511" passthrough=yes
    add action=mark-packet chain=prerouting comment="p2p upload package" \
        dst-address-type=!local in-interface=$lanInterface log-prefix="" \
        new-packet-mark=p2p_upload_pkg packet-size="512-65535" passthrough=yes \
        protocol=udp src-port="54-65535"


/queue tree
    add max-limit=58M name=root_queue parent=global
    add max-limit=50M name=download parent=root_queue
    add max-limit=8M name=upload parent=root_queue
    add limit-at=128k max-limit=5M name=small_download_pkg packet-mark=\
        small_download_pkg parent=download priority=2 queue=pcq-download-default
    add limit-at=128k max-limit=1M name=small_upload_pkg packet-mark=\
        small_upload_pkg parent=upload priority=2 queue=pcq-upload-default
    add max-limit=45M name=other_download parent=download queue=\
        pcq-download-default
    add max-limit=7M name=other_upload parent=upload queue=default
    add burst-limit=45M burst-threshold=4M burst-time=5s limit-at=4M max-limit=\
        45M name=http_download_pkg packet-mark=http_download_pkg parent=\
        other_download priority=4 queue=pcq-download-default
    add limit-at=4M max-limit=45M name=other_download_pkg packet-mark=\
        download_pkg parent=other_download priority=6 queue=pcq-download-default
    add limit-at=128k max-limit=4M name=http_upload_pkg packet-mark=\
        http_upload_pkg parent=other_upload priority=4 queue=pcq-upload-default
    add limit-at=128k max-limit=4M name=other_upload_pkg packet-mark=upload_pkg \
        parent=other_upload priority=6 queue=pcq-upload-default
    add limit-at=128k max-limit=1M name=p2p_upload_pkg packet-mark=p2p_upload_pkg \
        parent=other_upload priority=7 queue=pcq-upload-default
    add limit-at=1M max-limit=30M name=p2p_download_pkg packet-mark=\
        p2p_download_pkg parent=other_download priority=7 queue=\
        pcq-download-default

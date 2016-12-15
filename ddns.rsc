:global interval "10m"
:global ddnsName "dcofc"

/system scheduler
add interval=10m name=ddns_scheduler on-event=ddns policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive
/system script
add name=ddns policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive source=("/tool fetch url=\"http://yjbd.sinaapp.com/ddns/" . $ddnsName . "\" keep-result=no")
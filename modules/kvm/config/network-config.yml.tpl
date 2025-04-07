version: 2
ethernets:
%{ for iface in interfaces ~}
  ${iface.name}:
    match:
      macaddress: ${iface.mac_address}
    set-name: ${iface.name}
%{ if iface.ipv4_address != null }
    addresses:
      - ${iface.ipv4_address}/${iface.cidr_block}
    nameservers:
      addresses: [${join(",", iface.dns_servers)}]
    routes:
      - to: default
        via: ${iface.gateway}
%{ else }
    dhcp4: true
%{ endif }
%{ endfor ~}

# ============================================================================
# MikroTik RouterOS v7 Hardened Network Configuration Template
# Standard: 3-VLAN Micro-Segmentation & Split-Horizon Internal DNS
# ============================================================================

# 1. Create Base Bridge & VLAN Filtering
/interface bridge
add name=bridge-lan vlan-filtering=yes

# 2. Configure VLAN Interfaces
/interface vlan
add interface=bridge-lan name=vlan10-mgmt vlan-id=10
add interface=bridge-lan name=vlan20-services vlan-id=20
add interface=bridge-lan name=vlan30-iot vlan-id=30

# 3. Configure IP Subnets (RFC 1918 Standard)
/ip address
add address=10.0.0.1/24 interface=vlan10-mgmt network=10.0.0.0
add address=10.0.10.1/24 interface=vlan20-services network=10.0.10.0
add address=10.0.20.1/24 interface=vlan30-iot network=10.0.20.0

# 4. Split-Horizon Static DNS (Bypass Hairpin NAT directly to Traefik)
/ip dns static
add name=example.com type=A address=10.0.0.110 ttl=5m
add name=auth.example.com type=A address=10.0.0.110 ttl=5m
add name=vault.example.com type=A address=10.0.0.110 ttl=5m
add name=git.example.com type=A address=10.0.0.110 ttl=5m
add name=grafana.example.com type=A address=10.0.0.110 ttl=5m

# 5. Firewall Micro-Segmentation Rules
/ip firewall filter
# Accept established/related connections
add chain=forward connection-state=established,related action=accept comment="Accept Established/Related"

# Allow Management (VLAN 10) to access Services (VLAN 20) and IoT (VLAN 30)
add chain=forward in-interface=vlan10-mgmt out-interface=vlan20-services action=accept comment="Allow Mgmt to Services"
add chain=forward in-interface=vlan10-mgmt out-interface=vlan30-iot action=accept comment="Allow Mgmt to IoT"

# Allow Services (VLAN 20) and IoT (VLAN 30) to access Internet (WAN), but BLOCK access to Management (VLAN 10)
add chain=forward in-interface=vlan30-iot out-interface=vlan10-mgmt action=drop comment="BLOCK IoT from accessing Management"
add chain=forward in-interface=vlan20-services out-interface=vlan10-mgmt action=drop comment="BLOCK Services from accessing Management"

#!/bin/bash

# OS detection
os_name=$(cat /etc/os-release | grep "PRETTY_NAME" | sed -r 's/PRETTY_NAME=//g')
os_name=$(echo $os_name | tr '[:upper:]' '[:lower:]')

# "tunnelbroker.net" > Tunnel Details > IPv6 Tunnel Endpoints > Client IPv6 Address
echo -n "Enter Your Client IPv6 Address : "
read client_ipv6_address
if echo "$client_ipv6_address" | grep -q "/"; then
	client_ipv6_address=${client_ipv6_address:0:(-3)}
fi

# "tunnelbroker.net" > Tunnel Details > IPv6 Tunnel Endpoints > Server IPv4 Address
echo -n "Enter Your Server IPv4 Address : "
read server_ipv4_address

# "tunnelbroker.net" > Tunnel Details > IPv6 Tunnel Endpoints > Server IPv6 Address
echo -n "Enter Your Server IPv6 Address : "
read server_ipv6_address
if echo "$server_ipv6_address" | grep -q "/"; then
	server_ipv6_address=${server_ipv6_address:0:(-3)}
fi

# primary local ipv4 address
local_ipv4=$(hostname -I | awk '{print $1}')


if echo "$os_name" | grep -q "ubuntu" || echo "$os_name" | grep -q "debian"; then
	new_config="
auto he-ipv6
iface he-ipv6 inet6 v4tunnel
       address $client_ipv6_address
       netmask 64
       endpoint $server_ipv4_address
       local $local_ipv4
       ttl 255
       gateway $server_ipv6_address
"
	file_path="/etc/network/interfaces"
	echo "$new_config" | sudo tee -a "$file_path"
	ifup he-ipv6

else
  echo "Not Supported"
fi
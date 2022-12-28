#!/usr/bin/bash
clear
#figlet "auto configuration"
#figlet -f digital "by XI TKJ 1"
if [[ $EUID -ne 0 ]];
 then
   echo -e "\e[1;31mThis script must be run as root\e[0m"
   exit 1
fi
echo -e "\e[1;31mTKJ 1 PRODUCT\033[0m"
echo -e "\e[1;32m[+]============================================================[+]\e[0m"
echo -e "\e[1;38m[+] IP STATIC\e[0m               [\e[1;32mOK\e[0m]"
echo -e "\e[1;38m[+] DNS SERVER\e[0m              [\e[1;32mOK\e[0m]"
echo -e "\e[1;38m[+] WEB SERVER\e[0m              [\e[1;32mOK\e[0m]"
echo -e "\e[1;38m[+] FTP SERVER\e[0m              [\e[1;31mNo Available\e[0m]"
echo -e "\e[1;38m[+] SSH SERVER\e[0m              [\e[1;31mNo Available\e[0m]"
echo -e "\e[1;32m[+]============================================================[+]\e[0m"
echo -e "\e[1;31mDNS SERVER AND IP STATIC CONFIGURATION\e[0m"
read -p 'IP Address                  : ' ip
read -p 'Prefix                      : ' prefix
read -p 'Domain Name                 : ' domain
read -p 'octet 3, 2, 1 of Ip Address : ' octet
read -p 'octet 4                     : ' octet4
read -p 'Interface Name              : ' interface
echo -e "\e[1;32m[+]============================================================[+]\e[0m"
echo -e "\e[1;31mWEB SERVER CONFIGURATION\e[0m"
read -p 'Name of configuration file  : ' nameconf
read -p 'Server Admins               : ' serveradmin
read -p 'Document root               : ' rootdir
read -p 'Server Name                 : ' servername
#read -p '/var/www/Document			 : ' document
echo -e "\e[1;32m[+]============================================================[+]\e[0m"
cat <<EOF > /etc/network/interfaces

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

auto $interface
iface $interface inet static
	address $ip/$prefix
	nameserver $ip
EOF

/etc/init.d/networking restart
cat <<EOF > /etc/bind/named.conf.local
//
// Do any local configuration here
//

// Consider adding the 1918 zones here, if they are not used in your
// Organization
// include "/etc/bind/zones.rfc1918";

zone "$domain" {
	type master;
	file "/etc/bind/db.zahid";
};
zone "$octet.in-addr.arpa" {
	type master;
	file "/etc/bind/db.azmy";
};
EOF

cat <<EOF > /etc/bind/db.zahid
;
; BIND data file for local loopback interface
;

\$TTL	604800
@	IN	SOA	$domain. root.$domain. (
			      2  	; Serial
			 604800	        ; Refresh
			  86400		; Retry
			2419200		; Expire
			 604800 )	; Negative Cache TTL
;
@	IN	NS	$domain.
@	IN	A	$ip
www	IN	A	$ip
ftp	IN	A	$ip
ntp	IN	A	$ip
mail	IN	A	$ip
@	IN	MX 10	$ip

EOF

cat <<EOF > /etc/bind/db.azmy
;
; BIND data file for local loopback interface
;

\$TTL	604800
@	IN	SOA	$domain. root.$domain. (
			      1		; Serial
			 604800		; Refresh
		          86400		; Retry
		        2419200		; Expire
		         604800 )	; Negative Cache TTL
;
@	IN	NS	$domain.
$octet4	IN	PTR	$domain.
www	IN	PTR	www.$domain.
ftp	IN	PTR	ftp.$domain.
mail	IN	PTR	mail.$domain.
ntp	IN	PTR	ntp.$domain.
EOF

/etc/init.d/bind9 restart


echo -e "\e[1;32m[+]============================================================[+]\e[0m"
cat <<EOF > /etc/resolv.conf
nameserver $ip
search $domain

EOF

cat <<EOF > /etc/hosts
127.0.0.1	localhost
127.0.0.1	debian
$ip			$domain

# The following lines are desirable for IPv6 capable hosts
::1	localhost ip6-localhost ip6-loopback
ff02::1	ip6-allnodes
ff02::2 ip6-allrouters

EOF

cat <<EOF > /etc/apache2/sites-available/$nameconf.conf
<VirtualHost *:80>
		ServerName $servername
		ServerAdmin $serveradmin
		DocumentRoot /var/www/$rootdir
		ErrorLog ${APACHE_LOG_DIR}/error.log
		CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF
mkdir /var/www/$rootdir
chown -R www-data:www-data /var/www/$rootdir
chmod 755 /var/www/$rootdir
cat <<EOF > /var/www/$rootdir/index.html
<html>
<head>
<title> CONFIGURATION WAS SUCCESS</title>
</head>
<body>
<center>
<h1> CONFIGURATION WAS SUCCESSFULLY</h1>
</center>
</body>
</html>
EOF
a2ensite $nameconf
a2dissite 000-default.conf
echo -e "\e[1;32m[+]============================================================[+]\e[0m"

nslookup $domain

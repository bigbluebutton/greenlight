#!/bin/bash -e

# Copyright (c) 2018 BigBlueButton Inc.
#
# This program is free software; you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 3.0 of the License, or (at your option) any later
# version.
#
# BigBlueButton is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with BigBlueButton; if not, see <http://www.gnu.org/licenses/>.

# BigBlueButton is an open source conferencing system.  For more information see
#    http://www.bigbluebutton.org/.
#
# This bbb-install.sh script automates many of the installation and configuration
# steps at
#    http://docs.bigbluebutton.org/install/install.html
#
#
#  Examples
#
#  Install BigBlueButton with a SSL certificate from Let's Encrypt using hostname bbb.example.com
#  and email address info@example.com and apply a basic firewall
#
#    wget -qO- https://ubuntu.bigbluebutton.org/bbb-install.sh | bash -s -- -w -v xenial-22 -s bbb.example.com -e info@example.com 
#
#  Same as above but also install the API examples for testing.
#
#    wget -qO- https://ubuntu.bigbluebutton.org/bbb-install.sh | bash -s -- -w -a -v xenial-22 -s bbb.example.com -e info@example.com 
#
#  Install BigBlueButton with SSL + Greenlight
#
#    wget -qO- https://ubuntu.bigbluebutton.org/bbb-install.sh | bash -s -- -w -v xenial-22 -s bbb.example.com -e info@example.com -g
#

usage() {
    set +x
    cat 1>&2 <<HERE

Script for installing a BigBlueButton 2.2 (or later) server in under 30 minutes.

This script also supports installation of a coturn (TURN) server on a separate server.

USAGE:
    wget -qO- https://ubuntu.bigbluebutton.org/bbb-install.sh | bash -s -- [OPTIONS]

OPTIONS (install BigBlueButton):

  -v <version>           Install given version of BigBlueButton (e.g. 'xenial-22') (required)

  -s <hostname>          Configure server with <hostname>
  -e <email>             Email for Let's Encrypt certbot

  -x                     Use Let's Encrypt certbot with manual dns challenges

  -a                     Install BBB API demos
  -g                     Install Greenlight
  -c <hostname>:<secret> Configure with coturn server at <hostname> using <secret>

  -m <link_path>         Create a Symbolic link from /var/bigbluebutton to <link_path> 

  -p <host>              Use apt-get proxy at <host>
  -r <host>              Use alternative apt repository (such as packages-eu.bigbluebutton.org)

  -d                     Skip SSL certificates request (use provided certificates from mounted volume)
  -w                     Install UFW firewall (recommended)

  -h                     Print help

OPTIONS (install coturn only):

  -c <hostname>:<secret> Setup a coturn server with <hostname> and <secret> (required)
  -e <email>             Configure email for Let's Encrypt certbot (required)

OPTIONS (install Let's Encrypt certificate only):

  -s <hostname>          Configure server with <hostname> (required)
  -e <email>             Configure email for Let's Encrypt certbot (required)
  -l                     Only install Let's Encrypt certificate (not BigBlueButton)
  -x                     Use Let's Encrypt certbot with manual dns challenges (optional)


EXAMPLES:

Sample options for setup a BigBlueButton server

    -v xenial-22
    -v xenial-22 -s bbb.example.com -e info@example.com
    -v xenial-22 -s bbb.example.com -e info@example.com -g
    -v xenial-22 -s bbb.example.com -e info@example.com -g -c turn.example.com:1234324

Sample options for setup of a coturn server (on a different server)

    -c turn.example.com:1234324 -e info@example.com

SUPPORT:
    Community: https://bigbluebutton.org/support
         Docs: https://github.com/bigbluebutton/bbb-install

HERE
}

main() {
  export DEBIAN_FRONTEND=noninteractive
  PACKAGE_REPOSITORY=ubuntu.bigbluebutton.org
  LETS_ENCRYPT_OPTIONS="--webroot --non-interactive"
  SOURCES_FETCHED=false

  need_x64

  while builtin getopts "hs:r:c:v:e:p:m:lxgtadwX" opt "${@}"; do

    case $opt in
      h)
        usage
        exit 0
        ;;

      s)
        HOST=$OPTARG
        if [ "$HOST" == "bbb.example.com" ]; then 
          err "You must specify a valid hostname (not the hostname given in the docs)."
        fi
        ;;
      r)
        PACKAGE_REPOSITORY=$OPTARG
        ;;
      e)
        EMAIL=$OPTARG
        if [ "$EMAIL" == "info@example.com" ]; then 
          err "You must specify a valid email address (not the email in the docs)."
        fi
        ;;
      x)
        LETS_ENCRYPT_OPTIONS="--manual --preferred-challenges dns"
        ;;
      c)
        COTURN=$OPTARG
        check_coturn $COTURN
        ;;
      v)
        VERSION=$OPTARG
        ;;

      p)
        PROXY=$OPTARG
        if [ ! -z "$PROXY" ]; then
          echo "Acquire::http::Proxy \"http://$PROXY:3142\";"  > /etc/apt/apt.conf.d/01proxy
        fi
        ;;

      l)
        LETS_ENCRYPT_ONLY=true
        ;;
      g)
        GREENLIGHT=true
        ;;
      a)
        API_DEMOS=true
        ;;
      m)
        LINK_PATH=$OPTARG
        ;;
      d)
        PROVIDED_CERTIFICATE=true
        ;;
      w)
        SSH_PORT=$(grep Port /etc/ssh/ssh_config | grep -v \# | sed 's/[^0-9]*//g')
        if [[ ! -z "$SSH_PORT" && "$SSH_PORT" != "22" ]]; then
          err "Detected sshd not listening to standard port 22 -- unable to install default UFW firewall rules.  See http://docs.bigbluebutton.org/2.2/customize.html#secure-your-system--restrict-access-to-specific-ports"
        fi
        UFW=true
        ;;

      :)
        err "Missing option argument for -$OPTARG"
        exit 1
        ;;

      \?)
        err "Invalid option: -$OPTARG" >&2
        usage
        ;;
    esac
  done

  if [ ! -z "$HOST" ]; then
    check_host $HOST
  fi

  if [ ! -z "$VERSION" ]; then
    check_version $VERSION
  fi

  check_apache2

  # Check if we're installing coturn (need an e-mail address for Let's Encrypt)
  if [ -z "$VERSION" ] && [ ! -z "$LETS_ENCRYPT_ONLY" ]; then
    if [ -z "$EMAIL" ]; then err "Installing certificate needs an e-mail address for Let's Encrypt"; fi
    check_ubuntu 18.04

    install_certificate
    exit 0
  fi

  # Check if we're installing coturn (need an e-mail address for Let's Encrypt)
  if [ -z "$VERSION" ] && [ ! -z "$COTURN" ]; then
    if [ -z "$EMAIL" ]; then err "Installing coturn needs an e-mail address for Let's Encrypt"; fi
    check_ubuntu 20.04

    install_coturn
    exit 0
  fi

  if [ -z "$VERSION" ]; then
    usage
    exit 0
  fi

  # We're installing BigBlueButton
  env

  if [ "$DISTRO" == "xenial" ]; then 
    check_ubuntu 16.04
    TOMCAT_USER=tomcat7
  fi
  if [ "$DISTRO" == "bionic" ]; then 
    check_ubuntu 18.04
    TOMCAT_USER=tomcat8
  fi
  check_mem

  get_IP $HOST

  echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections

  need_pkg curl

  if [ "$DISTRO" == "xenial" ]; then 
    rm -rf /etc/apt/sources.list.d/jonathonf-ubuntu-ffmpeg-4-xenial.list 
    need_ppa rmescandon-ubuntu-yq-xenial.list         ppa:rmescandon/yq         CC86BB64 # Edit yaml files with yq
    need_ppa libreoffice-ubuntu-ppa-xenial.list       ppa:libreoffice/ppa       1378B444 # Latest libreoffice
    need_ppa bigbluebutton-ubuntu-support-xenial.list ppa:bigbluebutton/support E95B94BC # Latest version of ffmpeg
    apt-get -y -o DPkg::options::="--force-confdef" -o DPkg::options::="--force-confold" install grub-pc update-notifier-common

    # Remove default version of nodejs for Ubuntu 16.04 if installed
    if dpkg -s nodejs | grep Version | grep -q 4.2.6; then
      apt-get purge -y nodejs > /dev/null 2>&1
    fi
    apt-get purge -yq kms-core-6.0 kms-elements-6.0 kurento-media-server-6.0 > /dev/null 2>&1  # Remove older packages

    if [ ! -f /etc/apt/sources.list.d/nodesource.list ]; then
      curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
    fi
    if ! apt-cache madison nodejs | grep -q node_8; then
      err "Did not detect nodejs 8.x candidate for installation"
    fi

    if ! apt-key list A15703C6 | grep -q A15703C6; then
      wget -qO - https://www.mongodb.org/static/pgp/server-3.4.asc | sudo apt-key add -
    fi
    if apt-key list A15703C6 | grep -q expired; then 
      wget -qO - https://www.mongodb.org/static/pgp/server-3.4.asc | sudo apt-key add -
    fi
    rm -rf /etc/apt/sources.list.d/mongodb-org-4.0.list
    echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.4.list
    MONGODB=mongodb-org
    need_pkg openjdk-8-jre
  fi

  if [ "$DISTRO" == "bionic" ]; then
    need_ppa rmescandon-ubuntu-yq-bionic.list         ppa:rmescandon/yq          CC86BB64 # Edit yaml files with yq
    need_ppa libreoffice-ubuntu-ppa-bionic.list       ppa:libreoffice/ppa        1378B444 # Latest version of libreoffice
    need_ppa bigbluebutton-ubuntu-support-bionic.list ppa:bigbluebutton/support  E95B94BC # Latest version of ffmpeg
    if ! apt-key list 5AFA7A83 | grep -q -E "1024|4096"; then   # Add Kurento package
      sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 5AFA7A83
    fi

    if [ "$VERSION" == "bionic-230-dev" ]; then
      cat > /etc/apt/sources.list.d/kurento.list <<HERE
# Kurento Media Server - Release packages
deb [arch=amd64] http://ubuntu.openvidu.io/6.15.0 bionic kms6
HERE
    else
      rm -rf /etc/apt/sources.list.d/kurento.list     # Kurento 6.15 now packaged with 2.3
    fi

    if [ ! -f /etc/apt/sources.list.d/nodesource.list ]; then
      curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
    fi
    if ! apt-cache madison nodejs | grep -q node_12; then
      err "Did not detect nodejs 12.x candidate for installation"
    fi
    if ! apt-key list MongoDB | grep -q 4.2; then
      wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | sudo apt-key add -
    fi
    echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.2.list
    rm -f /etc/apt/sources.list.d/mongodb-org-4.0.list

    touch /root/.rnd
    MONGODB=mongodb-org
    install_docker		# needed for bbb-libreoffice-docker
    need_pkg ruby
    gem install bundler -v 2.1.4

    BBB_WEB_ETC_CONFIG=/etc/bigbluebutton/bbb-web.properties            # Override file for local settings 
  fi

  apt-get update
  apt-get dist-upgrade -yq

  need_pkg nodejs $MONGODB apt-transport-https haveged build-essential yq
  need_pkg bigbluebutton
  need_pkg bbb-html5

  if [ -f /usr/share/bbb-web/WEB-INF/classes/bigbluebutton.properties ]; then
    # 2.2
    SERVLET_DIR=/usr/share/bbb-web
    TURN_XML=$SERVLET_DIR/WEB-INF/classes/spring/turn-stun-servers.xml
  else
    # 2.0
    SERVLET_DIR=/var/lib/tomcat7/webapps/bigbluebutton
    TURN_XML=$SERVLET_DIR/WEB-INF/spring/turn-stun-servers.xml
  fi

  while [ ! -f $SERVLET_DIR/WEB-INF/classes/bigbluebutton.properties ]; do sleep 1; echo -n '.'; done

  check_lxc
  check_nat
  check_LimitNOFILE

  configure_HTML5 

  if [ ! -z "$API_DEMOS" ]; then
    need_pkg bbb-demo
    while [ ! -f /var/lib/$TOMCAT_USER/webapps/demo/bbb_api_conf.jsp ]; do sleep 1; echo -n '.'; done
  fi

  if [ ! -z "$LINK_PATH" ]; then
    ln -s "$LINK_PATH" "/var/bigbluebutton"
  fi

  if [ ! -z "$PROVIDED_CERTIFICATE" ] ; then
    install_ssl
  elif [ ! -z "$HOST" ] && [ ! -z "$EMAIL" ] ; then
    install_ssl
  fi

  if [ ! -z "$GREENLIGHT" ]; then
    install_greenlight
  fi

  if [ ! -z "$COTURN" ]; then
    configure_coturn
  fi

  apt-get auto-remove -y

  if systemctl status freeswitch.service | grep -q SETSCHEDULER; then
    sed -i "s/^CPUSchedulingPolicy=rr/#CPUSchedulingPolicy=rr/g" /lib/systemd/system/freeswitch.service
    systemctl daemon-reload
  fi

  if [ ! -z "$UFW" ]; then
    setup_ufw 
  fi


  if [ "$DISTRO" == "xenial" ]; then 
    # Add overrides to ensure redis-server is started before bbb-apps-akka, bbb-fsesl-akka, and bbb-transcode-akka
    if [ ! -f /etc/systemd/system/bbb-apps-akka.service.d/override.conf ];then
      mkdir -p /etc/systemd/system/bbb-apps-akka.service.d
      cat > /etc/systemd/system/bbb-apps-akka.service.d/override.conf <<HERE
  [Unit]
  Wants=redis-server.service
  After=redis-server.service
HERE
    fi

    if [ ! -f /etc/systemd/system/bbb-fsesl-akka.service.d/override.conf ]; then
      mkdir -p /etc/systemd/system/bbb-fsesl-akka.service.d
      cat > /etc/systemd/system/bbb-fsesl-akka.service.d/override.conf <<HERE
  [Unit]
  Wants=redis-server.service
  After=redis-server.service
HERE
    fi

    if [ ! -f /etc/systemd/system/bbb-transcode-akka.service.d/override.conf ]; then
      mkdir -p /etc/systemd/system/bbb-transcode-akka.service.d
      cat > /etc/systemd/system/bbb-transcode-akka.service.d/override.conf <<HERE
  [Unit]
  Wants=redis-server.service
  After=redis-server.service
HERE
    fi
  fi

  # Fix URLS for upgrade from earlier version of 2.3-dev
  if [ "$DISTRO" == "bionic" ]; then
    sed -i 's/^defaultHTML5ClientUrl=${bigbluebutton.web.serverURL}\/html5client\/%%INSTANCEID%%\/join/defaultHTML5ClientUrl=${bigbluebutton.web.serverURL}\/html5client\/join/g' /usr/share/bbb-web/WEB-INF/classes/bigbluebutton.properties

    sed -i 's/^defaultGuestWaitURL=${bigbluebutton.web.serverURL}\/html5client\/%%INSTANCEID%%\/guestWait/defaultGuestWaitURL=${bigbluebutton.web.serverURL}\/html5client\/guestWait/g' /usr/share/bbb-web/WEB-INF/classes/bigbluebutton.properties
  fi

  if [ ! -z "$HOST" ]; then
    bbb-conf --setip $HOST
  else
    bbb-conf --setip $IP
  fi

  if ! systemctl show-environment | grep LANG= | grep -q UTF-8; then
    sudo systemctl set-environment LANG=C.UTF-8
  fi

  bbb-conf --check
}

say() {
  echo "bbb-install: $1"
}

err() {
  say "$1" >&2
  exit 1
}

check_root() {
  if [ $EUID != 0 ]; then err "You must run this command as root."; fi
}

check_mem() {
  MEM=`grep MemTotal /proc/meminfo | awk '{print $2}'`
  MEM=$((MEM/1000))
  if (( $MEM < 3940 )); then err "Your server needs to have (at least) 4G of memory."; fi
}

check_ubuntu(){
  RELEASE=$(lsb_release -r | sed 's/^[^0-9]*//g')
  if [ "$RELEASE" != $1 ]; then err "You must run this command on Ubuntu $1 server."; fi
}

need_x64() {
  UNAME=`uname -m`
  if [ "$UNAME" != "x86_64" ]; then err "You must run this command on a 64-bit server."; fi
}

wait_443() {
  echo "Waiting for port 443 to clear "
  # netstat fields 4 and 6 are Local Address and State
  while netstat -ant | awk '{print $4, $6}' | grep TIME_WAIT | grep -q ":443"; do sleep 1; echo -n '.'; done
  echo
}

get_IP() {
  if [ ! -z "$IP" ]; then return 0; fi

  # Determine local IP
  need_pkg net-tools
  if LANG=c ifconfig | grep -q 'venet0:0'; then
    IP=$(ifconfig | grep -v '127.0.0.1' | grep -E "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" | tail -1 | cut -d: -f2 | awk '{ print $1}')
  else
    IP=$(ifconfig $(route | grep ^default | head -1 | sed "s/.* //") | awk '/inet /{ print $2}' | cut -d: -f2)
  fi

  # Determine external IP 
  if [ -r /sys/devices/virtual/dmi/id/product_uuid ] && [ `head -c 3 /sys/devices/virtual/dmi/id/product_uuid` == "EC2" ]; then
    # EC2
    local external_ip=$(wget -qO- http://169.254.169.254/latest/meta-data/public-ipv4)
  elif [ -f /var/lib/dhcp/dhclient.eth0.leases ] && grep -q unknown-245 /var/lib/dhcp/dhclient.eth0.leases; then
    # Azure
    local external_ip=$(curl -H Metadata:true "http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipAddress/0/publicIpAddress?api-version=2017-08-01&format=text")
  elif [ -f /run/scw-metadata.cache ]; then
    # Scaleway
    local external_ip=$(grep "PUBLIC_IP_ADDRESS" /run/scw-metadata.cache | cut -d '=' -f 2)
  elif which dmidecode > /dev/null && dmidecode -s bios-vendor | grep -q Google; then
    # Google Compute Cloud
    local external_ip=$(wget -O - -q "http://metadata/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip" --header 'Metadata-Flavor: Google')
  elif [ ! -z "$1" ]; then
    # Try and determine the external IP from the given hostname
    need_pkg dnsutils
    local external_ip=$(dig +short $1 @resolver1.opendns.com | grep '^[.0-9]*$' | tail -n1)
  fi

  # Check if the external IP reaches the internal IP
  if [ ! -z "$external_ip" ] && [ "$IP" != "$external_ip" ]; then
    if which nginx; then
      systemctl stop nginx
    fi

    need_pkg netcat-openbsd

    wait_443

    nc -l -p 443 > /dev/null 2>&1 &
    nc_PID=$!
    sleep 1
    
     # Check if we can reach the server through it's external IP address
     if nc -zvw3 $external_ip 443  > /dev/null 2>&1; then
       INTERNAL_IP=$IP
       IP=$external_ip
       echo 
       echo "  Detected this server has an internal/external IP address."
       echo 
       echo "      INTERNAL_IP: $INTERNAL_IP"
       echo "    (external) IP: $IP"
       echo 
     fi

    kill $nc_PID  > /dev/null 2>&1;

    if which nginx; then
      systemctl start nginx
    fi
  fi

  if [ -z "$IP" ]; then err "Unable to determine local IP address."; fi
}

need_pkg() {
  check_root

  if [ ! "$SOURCES_FETCHED" = true ]; then
    apt-get update
    SOURCES_FETCHED=true
  fi

  if ! dpkg -s ${@:1} >/dev/null 2>&1; then
    LC_CTYPE=C.UTF-8 apt-get install -yq ${@:1}
  fi
}

need_ppa() {
  need_pkg software-properties-common 
  if [ ! -f /etc/apt/sources.list.d/$1 ]; then
    LC_CTYPE=C.UTF-8 add-apt-repository -y $2 
  fi
  if ! apt-key list $3 | grep -q -E "1024|4096"; then  # Let's try it a second time
    LC_CTYPE=C.UTF-8 add-apt-repository $2 -y
    if ! apt-key list $3 | grep -q -E "1024|4096"; then
      err "Unable to setup PPA for $2"
    fi
  fi
}

check_version() {
  if ! echo $1 | egrep -q "xenial|bionic"; then err "This script can only install BigBlueButton 2.0 (or later)"; fi
  DISTRO=$(echo $1 | sed 's/-.*//g')
  if ! wget -qS --spider "https://$PACKAGE_REPOSITORY/$1/dists/bigbluebutton-$DISTRO/Release.gpg" > /dev/null 2>&1; then
    err "Unable to locate packages for $1 at $PACKAGE_REPOSITORY."
  fi
  check_root
  need_pkg apt-transport-https
  if ! apt-key list | grep -q "BigBlueButton apt-get"; then
    wget https://$PACKAGE_REPOSITORY/repo/bigbluebutton.asc -O- | apt-key add -
  fi

  # Check if were upgrading from 2.0 (the ownership of /etc/bigbluebutton/nginx/web has changed from bbb-client to bbb-web)
  if [ -f /etc/apt/sources.list.d/bigbluebutton.list ]; then
    if grep -q xenial-200 /etc/apt/sources.list.d/bigbluebutton.list; then
      if echo $VERSION | grep -q xenial-22; then
        if dpkg -l | grep -q bbb-client; then
          apt-get purge -y bbb-client
        fi
      fi
    fi
  fi

  echo "deb https://$PACKAGE_REPOSITORY/$VERSION bigbluebutton-$DISTRO main" > /etc/apt/sources.list.d/bigbluebutton.list
}

check_host() {
  if [ -z "$PROVIDED_CERTIFICATE" ] && [ -z "$HOST" ]; then
    need_pkg dnsutils apt-transport-https net-tools
    DIG_IP=$(dig +short $1 | grep '^[.0-9]*$' | tail -n1)
    if [ -z "$DIG_IP" ]; then err "Unable to resolve $1 to an IP address using DNS lookup.";  fi
    get_IP $1
    if [ "$DIG_IP" != "$IP" ]; then err "DNS lookup for $1 resolved to $DIG_IP but didn't match local $IP."; fi
  fi
}

check_coturn() {
  if ! echo $1 | grep -q ':'; then err "Option for coturn must be <hostname>:<secret>"; fi

  COTURN_HOST=$(echo $OPTARG | cut -d':' -f1)
  COTURN_SECRET=$(echo $OPTARG | cut -d':' -f2)

  if [ -z "$COTURN_HOST" ];   then err "-c option must contain <hostname>"; fi
  if [ -z "$COTURN_SECRET" ]; then err "-c option must contain <secret>"; fi

  if [ "$COTURN_HOST" == "turn.example.com" ]; then 
    err "You must specify a valid hostname (not the example given in the docs)"
  fi
  if [ "$COTURN_SECRET" == "1234abcd" ]; then 
    err "You must specify a new password (not the example given in the docs)."
  fi

  check_host $COTURN_HOST
}

check_apache2() {
  if dpkg -l | grep -q apache2-bin; then err "You must uninstall the Apache2 server first"; fi
}

# If running under LXC, then modify the FreeSWITCH systemctl service so it does not use realtime scheduler
check_lxc() {
  if grep -qa container=lxc /proc/1/environ; then
    if grep IOSchedulingClass /lib/systemd/system/freeswitch.service > /dev/null; then
      cat > /lib/systemd/system/freeswitch.service << HERE
[Unit]
Description=freeswitch
After=syslog.target network.target local-fs.target

[Service]
Type=forking
PIDFile=/opt/freeswitch/var/run/freeswitch/freeswitch.pid
Environment="DAEMON_OPTS=-nonat"
EnvironmentFile=-/etc/default/freeswitch
ExecStart=/opt/freeswitch/bin/freeswitch -u freeswitch -g daemon -ncwait \$DAEMON_OPTS
TimeoutSec=45s
Restart=always
WorkingDirectory=/opt/freeswitch
User=freeswitch
Group=daemon

LimitCORE=infinity
LimitNOFILE=100000
LimitNPROC=60000
LimitSTACK=250000
LimitRTPRIO=infinity
LimitRTTIME=7000000
#IOSchedulingClass=realtime
#IOSchedulingPriority=2
#CPUSchedulingPolicy=rr
#CPUSchedulingPriority=89

[Install]
WantedBy=multi-user.target
HERE

    systemctl daemon-reload
  fi
fi
}

# Check if running externally with internal/external IP addresses
check_nat() {
  xmlstarlet edit --inplace --update '//X-PRE-PROCESS[@cmd="set" and starts-with(@data, "external_rtp_ip=")]/@data' --value "external_rtp_ip=$IP" /opt/freeswitch/conf/vars.xml
  xmlstarlet edit --inplace --update '//X-PRE-PROCESS[@cmd="set" and starts-with(@data, "external_sip_ip=")]/@data' --value "external_sip_ip=$IP" /opt/freeswitch/conf/vars.xml

  if [ ! -z "$INTERNAL_IP" ]; then
    xmlstarlet edit --inplace --update '//param[@name="ext-rtp-ip"]/@value' --value "\$\${external_rtp_ip}" /opt/freeswitch/conf/sip_profiles/external.xml
    xmlstarlet edit --inplace --update '//param[@name="ext-sip-ip"]/@value' --value "\$\${external_sip_ip}" /opt/freeswitch/conf/sip_profiles/external.xml

    sed -i "s/$INTERNAL_IP:/$IP:/g" /etc/bigbluebutton/nginx/sip.nginx
    ip addr add $IP dev lo

    # If dummy NIC is not in dummy-nic.service (or the file does not exist), update/create it
    if ! grep -q $IP /lib/systemd/system/dummy-nic.service > /dev/null 2>&1; then
      if [ -f /lib/systemd/system/dummy-nic.service ]; then 
        DAEMON_RELOAD=true; 
      fi

      cat > /lib/systemd/system/dummy-nic.service << HERE
[Unit]
Description=Configure dummy NIC for FreeSWITCH
Before=freeswitch.service
After=network.target

[Service]
ExecStart=/sbin/ip addr add $IP dev lo

[Install]
WantedBy=multi-user.target
HERE

      if [ "$DAEMON_RELOAD" == "true" ]; then
        systemctl daemon-reload
        systemctl restart dummy-nic
      else
        systemctl enable dummy-nic
        systemctl start dummy-nic
      fi
    fi
  fi
}

check_LimitNOFILE() {
  CPU=$(nproc --all)

  if [ "$CPU" -ge 8 ]; then
    if [ -f /lib/systemd/system/bbb-web.service ]; then
      # Let's create an override file to increase the number of LimitNOFILE 
      mkdir -p /etc/systemd/system/bbb-web.service.d/
      cat > /etc/systemd/system/bbb-web.service.d/override.conf << HERE
[Service]
LimitNOFILE=8192
HERE
      systemctl daemon-reload
    fi
  fi
}

configure_HTML5() {
  # Use Google's default STUN server
  if [ ! -z "$INTERNAL_IP" ]; then
   sed -i 's/;stunServerAddress.*/stunServerAddress=172.217.212.127/g' /etc/kurento/modules/kurento/WebRtcEndpoint.conf.ini
   sed -i 's/;stunServerPort.*/stunServerPort=19302/g'                 /etc/kurento/modules/kurento/WebRtcEndpoint.conf.ini

   sed -i "s/[;]*externalIPv4=.*/externalIPv4=$IP/g"                   /etc/kurento/modules/kurento/WebRtcEndpoint.conf.ini
   # sed -i "s/[;]*niceAgentIceTcp=.*/niceAgentIceTcp=0/g"               /etc/kurento/modules/kurento/WebRtcEndpoint.conf.ini
  fi


  # Make the HTML5 client default
  sed -i 's/^attendeesJoinViaHTML5Client=.*/attendeesJoinViaHTML5Client=true/'   $SERVLET_DIR/WEB-INF/classes/bigbluebutton.properties
  sed -i 's/^moderatorsJoinViaHTML5Client=.*/moderatorsJoinViaHTML5Client=true/' $SERVLET_DIR/WEB-INF/classes/bigbluebutton.properties

  sed -i 's/swfSlidesRequired=true/swfSlidesRequired=false/g'                    $SERVLET_DIR/WEB-INF/classes/bigbluebutton.properties
}

install_greenlight(){
  install_docker

  # Install Docker Compose
  if dpkg -l | grep -q docker-compose; then
    apt-get purge -y docker-compose
  fi

  if [ ! -x /usr/local/bin/docker-compose ]; then
    curl -L "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
  fi

  if [ ! -d ~/greenlight ]; then
    mkdir -p ~/greenlight
  fi

  # This will trigger the download of Greenlight docker image (if needed)
  SECRET_KEY_BASE=$(docker run --rm bigbluebutton/greenlight:v2 bundle exec rake secret)

  if [ ! -f ~/greenlight/.env ]; then
    docker run --rm bigbluebutton/greenlight:v2 cat ./sample.env > ~/greenlight/.env
  fi

  BIGBLUEBUTTON_URL=$(cat $SERVLET_DIR/WEB-INF/classes/bigbluebutton.properties $BBB_WEB_ETC_CONFIG | grep -v '#' | sed -n '/^bigbluebutton.web.serverURL/{s/.*=//;p}' | tail -n 1 )/bigbluebutton/
  BIGBLUEBUTTON_SECRET=$(cat $SERVLET_DIR/WEB-INF/classes/bigbluebutton.properties $BBB_WEB_ETC_CONFIG | grep -v '#' | grep securitySalt | tail -n 1  | cut -d= -f2)
  SAFE_HOSTS=$(cat $SERVLET_DIR/WEB-INF/classes/bigbluebutton.properties $BBB_WEB_ETC_CONFIG | grep -v '#' | sed -n '/^bigbluebutton.web.serverURL/{s/.*=//;p}' | tail -n 1 | sed 's/https\?:\/\///')

  # Update Greenlight configuration file in ~/greenlight/env
  sed -i "s|SECRET_KEY_BASE=.*|SECRET_KEY_BASE=$SECRET_KEY_BASE|"                   ~/greenlight/.env
  sed -i "s|.*BIGBLUEBUTTON_ENDPOINT=.*|BIGBLUEBUTTON_ENDPOINT=$BIGBLUEBUTTON_URL|" ~/greenlight/.env
  sed -i "s|.*BIGBLUEBUTTON_SECRET=.*|BIGBLUEBUTTON_SECRET=$BIGBLUEBUTTON_SECRET|"  ~/greenlight/.env
  sed -i "s|SAFE_HOSTS=.*|SAFE_HOSTS=$SAFE_HOSTS|"                                  ~/greenlight/.env

  # need_pkg bbb-webhooks

  if [ ! -f /etc/bigbluebutton/nginx/greenlight.nginx ]; then
    docker run --rm bigbluebutton/greenlight:v2 cat ./greenlight.nginx | tee /etc/bigbluebutton/nginx/greenlight.nginx
    cat > /etc/bigbluebutton/nginx/greenlight-redirect.nginx << HERE
location = / {
  return 307 /b;
}
HERE
    systemctl restart nginx
  fi

  if ! gem list | grep -q java_properties; then
    gem install jwt java_properties
  fi

  if [ ! -f ~/greenlight/docker-compose.yml ]; then
    docker run --rm bigbluebutton/greenlight:v2 cat ./docker-compose.yml > ~/greenlight/docker-compose.yml
  fi

  # change the default passwords
  PGPASSWORD=$(openssl rand -hex 8)
  sed -i "s/POSTGRES_PASSWORD=password/POSTGRES_PASSWORD=$PGPASSWORD/g" ~/greenlight/docker-compose.yml
  sed -i "s/DB_PASSWORD=password/DB_PASSWORD=$PGPASSWORD/g" ~/greenlight/.env

  # Remove old containers
  if docker ps | grep -q greenlight_db_1; then
    docker rm -f greenlight_db_1
  fi
  if docker ps | grep -q greenlight-v2; then
    docker rm -f greenlight-v2
  fi

  if ! docker ps | grep -q greenlight; then
    docker-compose -f ~/greenlight/docker-compose.yml up -d
    sleep 5
  fi
}


install_docker() {
  need_pkg apt-transport-https ca-certificates curl gnupg-agent software-properties-common openssl

  # Install Docker
  if ! apt-key list | grep -q Docker; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
  fi

  if ! dpkg -l | grep -q docker-ce; then
    add-apt-repository \
     "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
     $(lsb_release -cs) \
     stable"

    apt-get update
    need_pkg docker-ce docker-ce-cli containerd.io
  fi
  if ! which docker; then err "Docker did not install"; fi

  # Install Docker Compose
  if dpkg -l | grep -q docker-compose; then
    apt-get purge -y docker-compose
  fi
  if ! which docker; then err "Docker did not install"; fi
}


install_ssl() {
  if ! grep -q $HOST /usr/local/bigbluebutton/core/scripts/bigbluebutton.yml; then
    bbb-conf --setip $HOST
  fi

  mkdir -p /etc/nginx/ssl

  if [ -z "$PROVIDED_CERTIFICATE" ]; then
    add-apt-repository universe
    need_ppa certbot-ubuntu-certbot-xenial.list ppa:certbot/certbot 75BCA694
    apt-get update
    need_pkg certbot
  fi

  if [ ! -f /etc/nginx/ssl/dhp-4096.pem ]; then
    openssl dhparam -dsaparam  -out /etc/nginx/ssl/dhp-4096.pem 4096
  fi

  if [ ! -f /etc/letsencrypt/live/$HOST/fullchain.pem ]; then
    rm -f /tmp/bigbluebutton.bak
    if ! grep -q $HOST /etc/nginx/sites-available/bigbluebutton; then  # make sure we can do the challenge
      cp /etc/nginx/sites-available/bigbluebutton /tmp/bigbluebutton.bak
      cat <<HERE > /etc/nginx/sites-available/bigbluebutton
server_tokens off;
server {
  listen 80;
  listen [::]:80;
  server_name $HOST;

  access_log  /var/log/nginx/bigbluebutton.access.log;

  # BigBlueButton landing page.
  location / {
    root   /var/www/bigbluebutton-default;
    index  index.html index.htm;
    expires 1m;
  }

  # Redirect server error pages to the static page /50x.html
  #
  error_page   500 502 503 504  /50x.html;
  location = /50x.html {
    root   /var/www/nginx-default;
  }
}
HERE
      systemctl restart nginx
    fi

    if [ -z "$PROVIDED_CERTIFICATE" ]; then
      if ! certbot --email $EMAIL --agree-tos --rsa-key-size 4096 -w /var/www/bigbluebutton-default/ \
           -d $HOST --deploy-hook "systemctl restart nginx" $LETS_ENCRYPT_OPTIONS certonly; then
        cp /tmp/bigbluebutton.bak /etc/nginx/sites-available/bigbluebutton
        systemctl restart nginx
        err "Let's Encrypt SSL request for $HOST did not succeed - exiting"
      fi
    else
      mkdir -p /etc/letsencrypt/live/$HOST/
      ln -s /local/certs/fullchain.pem /etc/letsencrypt/live/$HOST/fullchain.pem
      ln -s /local/certs/privkey.pem /etc/letsencrypt/live/$HOST/privkey.pem
    fi
  fi

  cat <<HERE > /etc/nginx/sites-available/bigbluebutton
server_tokens off;

server {
  listen 80;
  listen [::]:80;
  server_name $HOST;
  
  return 301 https://\$server_name\$request_uri; #redirect HTTP to HTTPS

}
server {
  listen 443 ssl;
  listen [::]:443 ssl;
  server_name $HOST;

    ssl_certificate /etc/letsencrypt/live/$HOST/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$HOST/privkey.pem;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    ssl_protocols TLSv1.2;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers on;
    ssl_dhparam /etc/nginx/ssl/dhp-4096.pem;
    
    # HSTS (comment out to enable)
    #add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

  access_log  /var/log/nginx/bigbluebutton.access.log;

  # BigBlueButton landing page.
  location / {
    root   /var/www/bigbluebutton-default;
    index  index.html index.htm;
    expires 1m;
  }

  # Include specific rules for record and playback
  include /etc/bigbluebutton/nginx/*.nginx;

  #error_page  404  /404.html;

  # Redirect server error pages to the static page /50x.html
  #
  error_page   500 502 503 504  /50x.html;
  location = /50x.html {
    root   /var/www/nginx-default;
  }
}
HERE

  # Configure rest of BigBlueButton Configuration for SSL
  xmlstarlet edit --inplace --update '//param[@name="wss-binding"]/@value' --value "$IP:7443" /opt/freeswitch/conf/sip_profiles/external.xml
 
  source /etc/bigbluebutton/bigbluebutton-release
  if [ ! -z "$(echo $BIGBLUEBUTTON_RELEASE | grep '2.2')" ] && [ "$(echo "$BIGBLUEBUTTON_RELEASE" | cut -d\. -f3)" -lt 29 ]; then
    sed -i "s/proxy_pass .*/proxy_pass https:\/\/$IP:7443;/g" /etc/bigbluebutton/nginx/sip.nginx
  else
    # Use nginx as proxy for WSS -> WS (see https://github.com/bigbluebutton/bigbluebutton/issues/9667)
    yq w -i /usr/share/meteor/bundle/programs/server/assets/app/config/settings.yml public.media.sipjsHackViaWs true
    sed -i "s/proxy_pass .*/proxy_pass http:\/\/$IP:5066;/g" /etc/bigbluebutton/nginx/sip.nginx
    xmlstarlet edit --inplace --update '//param[@name="ws-binding"]/@value' --value "$IP:5066" /opt/freeswitch/conf/sip_profiles/external.xml
  fi

  sed -i 's/bigbluebutton.web.serverURL=http:/bigbluebutton.web.serverURL=https:/g' $SERVLET_DIR/WEB-INF/classes/bigbluebutton.properties
  if [ -f $BBB_WEB_ETC_CONFIG ]; then
    sed -i 's/bigbluebutton.web.serverURL=http:/bigbluebutton.web.serverURL=https:/g' $BBB_WEB_ETC_CONFIG
  fi

  yq w -i /usr/local/bigbluebutton/core/scripts/bigbluebutton.yml playback_protocol https
  chmod 644 /usr/local/bigbluebutton/core/scripts/bigbluebutton.yml 

  if [ -f /var/lib/$TOMCAT_USER/webapps/demo/bbb_api_conf.jsp ]; then
    sed -i 's/String BigBlueButtonURL = "http:/String BigBlueButtonURL = "https:/g' /var/lib/$TOMCAT_USER/webapps/demo/bbb_api_conf.jsp
  fi

  if [ -f /usr/share/meteor/bundle/programs/server/assets/app/config/settings.yml ]; then
    yq w -i /usr/share/meteor/bundle/programs/server/assets/app/config/settings.yml public.note.url https://$HOST/pad
  fi

  # Update Greenlight (if installed) to use SSL
  if [ -f ~/greenlight/.env ]; then
    if ! grep ^BIGBLUEBUTTON_ENDPOINT ~/greenlight/.env | grep -q https; then
      BIGBLUEBUTTON_URL=$(cat $SERVLET_DIR/WEB-INF/classes/bigbluebutton.properties $BBB_WEB_ETC_CONFIG | grep -v '#' | sed -n '/^bigbluebutton.web.serverURL/{s/.*=//;p}' | tail -n 1 )/bigbluebutton/
      sed -i "s|.*BIGBLUEBUTTON_ENDPOINT=.*|BIGBLUEBUTTON_ENDPOINT=$BIGBLUEBUTTON_URL|" ~/greenlight/.env
      docker-compose -f ~/greenlight/docker-compose.yml down
      docker-compose -f ~/greenlight/docker-compose.yml up -d
    fi
  fi

  # Update HTML5 client (if installed) to use SSL
  if [ -f  /usr/share/meteor/bundle/programs/server/assets/app/config/settings-production.json ]; then
    sed -i "s|\"wsUrl.*|\"wsUrl\": \"wss://$HOST/bbb-webrtc-sfu\",|g" \
      /usr/share/meteor/bundle/programs/server/assets/app/config/settings-production.json
  fi

  TARGET=/usr/local/bigbluebutton/bbb-webrtc-sfu/config/default.yml
  if [ -f $TARGET ]; then
    if grep -q kurentoIp $TARGET; then
      # 2.0
      yq w -i $TARGET kurentoIp "$IP"
    else
      # 2.2
      yq w -i $TARGET kurento[0].ip "$IP"
      yq w -i $TARGET freeswitch.ip "$IP"

      if [ ! -z "$(echo $BIGBLUEBUTTON_RELEASE | grep '2.2')" ] && [ "$(echo "$BIGBLUEBUTTON_RELEASE" | cut -d\. -f3)" -lt 29 ]; then
        if [ ! -z "$INTERNAL_IP" ]; then
          yq w -i $TARGET freeswitch.sip_ip "$INTERNAL_IP"
        else
          yq w -i $TARGET freeswitch.sip_ip "$IP"
        fi
      else
        # Use nginx as proxy for WSS -> WS (see https://github.com/bigbluebutton/bigbluebutton/issues/9667)
        yq w -i $TARGET freeswitch.sip_ip "$IP"
      fi
    fi
    chown bigbluebutton:bigbluebutton $TARGET
    chmod 644 $TARGET
  fi
}

configure_coturn() {
  cat <<HERE > $TURN_XML
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.springframework.org/schema/beans
        http://www.springframework.org/schema/beans/spring-beans-2.5.xsd">

    <bean id="stun0" class="org.bigbluebutton.web.services.turn.StunServer">
        <constructor-arg index="0" value="stun:$COTURN_HOST"/>
    </bean>


    <bean id="turn0" class="org.bigbluebutton.web.services.turn.TurnServer">
        <constructor-arg index="0" value="$COTURN_SECRET"/>
        <constructor-arg index="1" value="turns:$COTURN_HOST:443?transport=tcp"/>
        <constructor-arg index="2" value="86400"/>
    </bean>
    
    <bean id="turn1" class="org.bigbluebutton.web.services.turn.TurnServer">
        <constructor-arg index="0" value="$COTURN_SECRET"/>
        <constructor-arg index="1" value="turn:$COTURN_HOST:443?transport=tcp"/>
        <constructor-arg index="2" value="86400"/>
    </bean>

    <bean id="stunTurnService"
            class="org.bigbluebutton.web.services.turn.StunTurnService">
        <property name="stunServers">
            <set>
                <ref bean="stun0"/>
            </set>
        </property>
        <property name="turnServers">
            <set>
                <ref bean="turn0"/>
                <ref bean="turn1"/>
            </set>
        </property>
    </bean>
</beans>
HERE
}

install_certificate() {
  apt-get update
  apt-get -y -o DPkg::options::="--force-confdef" -o DPkg::options::="--force-confold" install grub-pc update-notifier-common
  apt-get dist-upgrade -yq

  need_pkg software-properties-common
  need_ppa certbot-ubuntu-certbot-bionic.list ppa:certbot/certbot 75BCA694 7BF5
  apt-get -y install certbot

  certbot certonly --standalone --non-interactive --preferred-challenges http \
    --deploy-hook "systemctl restart coturn" \
    -d $HOST --email $EMAIL --agree-tos -n
}


install_coturn() {
  apt-get update
  apt-get dist-upgrade -yq

  need_pkg software-properties-common certbot

  if ! certbot certonly --standalone --non-interactive --preferred-challenges http \
         -d $COTURN_HOST --email $EMAIL --agree-tos -n ; then
     err "Let's Encrypt SSL request for $COTURN_HOST did not succeed - exiting"
  fi

  need_pkg coturn

  if [ ! -z $INTERNAL_IP ]; then
    EXTERNAL_IP="external-ip=$IP/$INTERNAL_IP"
  fi

  cat <<HERE > /etc/turnserver.conf
listening-port=3478
tls-listening-port=443

listening_ip=$IP
relay_ip=$IP
$EXTERNAL_IP

min-port=32769
max-port=65535
verbose

fingerprint
lt-cred-mech
use-auth-secret
static-auth-secret=$COTURN_SECRET
realm=$(echo $COTURN_HOST | cut -d'.' -f2-)

cert=/etc/turnserver/fullchain.pem
pkey=/etc/turnserver/privkey.pem
# From https://ssl-config.mozilla.org/ Intermediate, openssl 1.1.0g, 2020-01
cipher-list="ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384"
dh-file=/etc/turnserver/dhp.pem

keep-address-family

no-cli
no-tlsv1
no-tlsv1_1
HERE

  mkdir -p /etc/turnserver
  if [ ! -f /etc/turnserver/dhp.pem ]; then
    openssl dhparam -dsaparam  -out /etc/turnserver/dhp.pem 2048
  fi

  mkdir -p /var/log/turnserver
  chown turnserver:turnserver /var/log/turnserver

  cat <<HERE > /etc/logrotate.d/coturn
/var/log/turnserver/*.log
{
	rotate 7
	daily
	missingok
	notifempty
	compress
	postrotate
		/bin/systemctl kill -s HUP coturn.service
	endscript
}
HERE

  # Eanble coturn to bind to port 443 with CAP_NET_BIND_SERVICE
  mkdir -p /etc/systemd/system/coturn.service.d
  rm -rf /etc/systemd/system/coturn.service.d/ansible.conf      # Remove previous file 
  cat > /etc/systemd/system/coturn.service.d/override.conf <<HERE
[Service]
LimitNOFILE=1048576
AmbientCapabilities=CAP_NET_BIND_SERVICE
ExecStart=
ExecStart=/usr/bin/turnserver --daemon -c /etc/turnserver.conf --pidfile /run/turnserver/turnserver.pid --no-stdout-log --simple-log --log-file /var/log/turnserver/turnserver.log
Restart=always
HERE

  # Since coturn runs as user turnserver, copy certs so they can be read
  mkdir -p /etc/letsencrypt/renewal-hooks/deploy
  cat > /etc/letsencrypt/renewal-hooks/deploy/coturn <<HERE
#!/bin/bash -e

for certfile in fullchain.pem privkey.pem ; do
	cp -L /etc/letsencrypt/live/$COTURN_HOST/"\${certfile}" /etc/turnserver/"\${certfile}".new
	chown turnserver:turnserver /etc/turnserver/"\${certfile}".new
	mv /etc/turnserver/"\${certfile}".new /etc/turnserver/"\${certfile}"
done

systemctl kill -sUSR2 coturn.service
HERE
  chmod 0755 /etc/letsencrypt/renewal-hooks/deploy/coturn
  /etc/letsencrypt/renewal-hooks/deploy/coturn

  systemctl daemon-reload
  systemctl stop coturn
  wait_443
  systemctl start coturn
}


setup_ufw() {
  if [ ! -f /etc/bigbluebutton/bbb-conf/apply-config.sh ]; then
    cat > /etc/bigbluebutton/bbb-conf/apply-config.sh << HERE
#!/bin/bash

# Pull in the helper functions for configuring BigBlueButton
source /etc/bigbluebutton/bbb-conf/apply-lib.sh

enableUFWRules
HERE
  chmod +x /etc/bigbluebutton/bbb-conf/apply-config.sh
  fi
}

main "$@" || exit 1


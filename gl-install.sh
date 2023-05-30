#!/bin/bash -e

# Copyright (c) 2022 BigBlueButton Inc.
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

# BigBlueButton is an open source conferencing system. For more information see
#    https://www.bigbluebutton.org/.
#
# This gl-install.sh script automates many of the installation and configuration
# steps at https://docs.bigbluebutton.org/greenlight/v3/install
#
#
#  Examples
#
#  Install a standaolne Greenlight 3.x.x with a publicly trusted SSL certificate issued by Let's Encrypt using a FQDN of www.example.com
#  and an email address of info@example.com.
#
#    wget -qO- https://raw.githubusercontent.com/bigbluebutton/greenlight/master/gl-install.sh | bash -s -- -s www.example.com -e info@example.com 
#


usage() {
    set +x
    cat 1>&2 <<HERE

Script for installing a Greenlight 3.x standalone server in under 15 minutes. It also supports upgrading an existing installation of Greenlight 3.x on replay.

USAGE:
    wget -qO- https://raw.githubusercontent.com/bigbluebutton/greenlight/master/gl-install.sh | bash -s -- [OPTIONS]

OPTIONS (install Greenlight):

  -s <hostname>          Configure server with <hostname> (Required)

  -e <email>             Email for Let's Encrypt certbot (Required, if -d is omitted)
                          * Cannot be used when -d is used.

  -b <hostname>:<secret> The BigBlueButton server to be used that is accessible on <hostname> with secret <secret> (Optional)
                          * If omitted, defaults to our public BigBlueButton testing server, use it for testing purposes ONLY, DO NOT use for production!

  -d                     Skip SSL certificates generation (Required, if -e is omitted).
                          * Used to provide certificate files skipping the auto generation using Let's encrypt. 
                            Certificate files to be used must be named fullchain.pem and privkey.pem and must be placed in /local/certs/.
                          * Cannot be used when -e is used.

  -k                     Setup Keycloak 20.0 on the system (Optional)
  
  -h                     Print help

VARIABLES (configure Greenlight):
  GL_PATH                Configure Greenlight relative URL root path (Optional)
                          * Use this when deploying Greenlight behind a reverse proxy on a path other than the default '/' e.g. '/gl'.

EXAMPLES:

Sample options for setup a Greenlight 3.x server with a publicly signed (by Let's encrypt) SSL certificate for a FQDN of www.example.com and an email
of info@example.com that uses a BigBlueButton server at bbb.example.com with secret SECRET: 

    -s www.example.com -e info@example.com -b bbb.example.com:SECRET

Sample options for setup a Greenlight 3.x server with pre-owned SSL certificates for a FQDN of www.example.com that uses a BigBlueButton server at bbb.example.com with secret SECRET: 

    -s www.example.com -b bbb.example.com:SECRET -d

SUPPORT:
         Community: https://groups.google.com/g/bigbluebutton-greenlight
         Source: https://github.com/bigbluebutton/greenlight-run
         Docs: https://docs.bigbluebutton.org/greenlight/v3/install

HERE
}

main() {
  export DEBIAN_FRONTEND=noninteractive
  LETS_ENCRYPT_OPTIONS="--webroot --non-interactive"
  SOURCES_FETCHED=false
  GL3_DIR=~/greenlight-v3
  ACCESS_LOG_DEST=/var/log/nginx
  NGINX_FILES_DEST=/etc/greenlight/nginx
  ASSETS_DEST=/var/www/greenlight-default/assets
  EXIT_CODE=0

  # Eager checks and assertions.
  check_root
  check_ubuntu_lts
  need_x64

  while builtin getopts "s:e:b:hdk" opt "${@}"; do

    case $opt in
      h)
        usage
        exit 0
        ;;

      s)
        HOST=$OPTARG
        if [ "$HOST" == "bbb.example.com" ]; then 
          err "You must specify a valid FQDN (not the FQDN given in the docs)."
        fi
        ;;
      e)
        EMAIL=$OPTARG
        if [ "$EMAIL" == "info@example.com" ]; then 
          err "You must specify a valid email address (not the email in the docs)."
        fi
        ;;
      b)
        BIGBLUEBUTTON=$OPTARG
        if [ "$BIGBLUEBUTTON" == "bbb.example.com:SECRET" ]; then 
          err "You must use a valid BigBlueButton server (not the one in the example)."
        fi

        if [[ ! $BIGBLUEBUTTON =~ .+:.+ ]]; then
          err "You must respect the format <hostname>:<secret> when specifying your BigBlueButton server."
        fi

        IFS=: BIGBLUEBUTTON=($BIGBLUEBUTTON) IFS=' ' # Making BIGBLUEBUTTON an array, first element is the BBB hostname and the second is the BBB secret.
        ;;
      d)
        PROVIDED_CERTIFICATE=true
        ;;      
      k)
        INSTALL_KC=true
        ;;      
      :)
        err "Missing option argument for -$OPTARG"
        ;;

      \?)
        err "Invalid option: -$OPTARG"
        ;;
    esac
  done

  GL_DEFAULT_PATH=/
  if [ -n "$GL_PATH"  ] && [ "$GL_PATH" != "$GL_DEFAULT_PATH" ]; then
    if [[ ! $GL_PATH =~ ^/.*[^/]$ ]]; then
      err "\$GL_PATH ENV is set to '$GL_PATH' which is invalid, Greenlight relative URL root path must start but not end with '/'."
    fi
  fi

  check_env # Meeting requirements.

  say "Environment checks passed, installing/upgrading Greenlight!"

  apt-get update
  apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew" dist-upgrade
  
  install_ssl
  install_greenlight_v3

  apt-get auto-remove -y
  say "DONE ^^"

  return $EXIT_CODE
}

check_env() {
  # Required ARGS
  if [ -z "$HOST" ]; then
    err "Missing required ARG, You must provide the -s <FQDN>; FQDN must point to this system public IP that Greenlight will be accessible through."
  fi

  if [ -n "$PROVIDED_CERTIFICATE" ] && [ -n "$EMAIL" ]; then
    err "Illegal usage of options, either use -d to provide your already generated certificates OR use -e <EMAIL> to have this script generate one for you."
  fi

  if [ -z "$PROVIDED_CERTIFICATE" ] && [ -z "$EMAIL" ]; then
    err "Missing required ARG, You must provide the -e <EMAIL> to auto generate a certificate OR use -d to include your own files skipping issuing them by the script."
  fi

  local bbb_detected_err="This deployment installs Greenlight without BigBlueButton if planning to install both on the same system then please follow https://github.com/bigbluebutton/bbb-install instead."

  # Detecting BBB on the system
  if [ "${BIGBLUEBUTTON[0]}" == "$HOST" ]; then
    say "Your FQDN match that of the BigBlueButton server to be used, are you willing to install Greenlight with BigBlueButton on this system?"
    err "$bbb_detected_err."
  fi

  if dpkg -l | grep -q bbb; then
    say "BigBlueButton modules has been detected on this system!" 
    err "$bbb_detected_err."
  fi

  # Possible conflicts on setup.
  if [ ! -f /etc/nginx/sites-available/greenlight ]; then
    # Conflict detection of existent nginx on the system not installed by this script (possible collision with other applications).
    if dpkg -s nginx 1> /dev/null 2>&1; then
      say "Nginx is already installed on this system by another mean, this deployment may impact your workload!"
      err "Remove and cleanup nginx configurations on this system OR kindly consider using a clean enviroment before proceeding."
    fi

    # Conflict detection of required ports being already in use.
    if check_ports_listen ':80$|:443$|:5050$|:5151$'; then
      say "Some required ports are already in use by another application!"
      err "Make sure to clear out the required ports (TCP 80, 443, 5050, 5151) if possible OR kindly consider using a clean enviroment before proceeding."
    fi
  fi

  check_host "$HOST"
}

say() {
  echo "gl-install: $1"
}

err() {
  say "$1" >&2
  exit 1
}

warn() {
  say "$1" >&2
  EXIT_CODE=1
}

check_root() {
  if [ $EUID != 0 ]; then err "You must run this command as root."; fi
}

check_ubuntu_lts() {
  lsb_release -i | grep -iq ubuntu || err "You must run this command on Ubuntu server."
  RELEASE=$(lsb_release -r | sed 's/^[^0-9]*//g')
  [ "$RELEASE" == "20.04" ] || [ "$RELEASE" == "22.04" ]  || err "You must run this command on Ubuntu version 20.04 or 22.04 LTS."
}

need_x64() {
  UNAME=`uname -m`
  if [ "$UNAME" != "x86_64" ]; then err "You must run this command on a 64-bit server."; fi
}

wait_443() {
  check_ports_clearing ':443$' && say "Waiting for port 443 to clear "

  while check_ports_clearing ':443$'; do sleep 1; echo -n '.'; done
  echo
}

check_ports_listen() {
  local pattern=${1:-':80$|:443$'}

  ss -lnt | awk '{print $4}' | egrep -q "$pattern"
}

check_ports_clearing() {
  local pattern=${1:-':80$|:443$'}

  ss -ant | grep TIME-WAIT | awk '{print $4}' | egrep -q "$pattern"
}

get_IP() {
  if [ -n "$IP" ]; then return 0; fi

  # Determine local IP
  if [ -e "/sys/class/net/venet0:0" ]; then
    # IP detection for OpenVZ environment
    _dev="venet0:0"
  else
    _dev=$(awk '$2 == 00000000 { print $1 }' /proc/net/route | head -1)
  fi
  _ips=$(LANG=C ip -4 -br address show dev "$_dev" | awk '{ $1=$2=""; print $0 }')
  _ips=${_ips/127.0.0.1\/8/}
  read -r IP _ <<< "$_ips"
  IP=${IP/\/*} # strip subnet provided by ip address
  if [ -z "$IP" ]; then
    read -r IP _ <<< "$(hostname -I)"
  fi


  # Determine external IP 
  if grep -sqi ^ec2 /sys/devices/virtual/dmi/id/product_uuid; then
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
  elif [ -n "$1" ]; then
    # Try and determine the external IP from the given hostname
    need_pkg dnsutils
    local external_ip=$(dig +short "$1" @resolver1.opendns.com | grep '^[.0-9]*$' | tail -n1)
  fi

  # Check if the external IP reaches the internal IP
  if [ -n "$external_ip" ] && [ "$IP" != "$external_ip" ]; then
    if which nginx; then
      systemctl stop nginx
    fi

    need_pkg netcat-openbsd

    wait_443

    nc -l -p 443 > /dev/null 2>&1 &
    nc_PID=$!
    sleep 1
    
     # Check if we can reach the server through it's external IP address
     if nc -zvw3 "$external_ip" 443  > /dev/null 2>&1; then
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
  while fuser /var/lib/dpkg/lock >/dev/null 2>&1; do echo "Sleeping for 1 second because of dpkg lock"; sleep 1; done

  if [ ! "$SOURCES_FETCHED" = true ]; then
    apt-get update
    SOURCES_FETCHED=true
  fi

  if ! dpkg -s ${@:1} >/dev/null 2>&1; then
    LC_CTYPE=C.UTF-8 apt-get install -yq ${@:1}
  fi
  while fuser /var/lib/dpkg/lock >/dev/null 2>&1; do echo "Sleeping for 1 second because of dpkg lock"; sleep 1; done
}

check_host() {
    need_pkg dnsutils apt-transport-https
    DIG_IP=$(dig +short "$1" | grep '^[.0-9]*$' | tail -n1)
    if [ -z "$DIG_IP" ]; then err "Unable to resolve $1 to an IP address using DNS lookup.";  fi
    get_IP "$1"
    if [ "$DIG_IP" != "$IP" ]; then err "DNS lookup for $1 resolved to $DIG_IP but didn't match this system IP $IP."; fi
}

# This function will install the latest official version of greenlight-v3 and set it as the hosting Bigbluebutton default frontend or update greenlight-v3 if installed.
# Greenlight is a simple to use Bigbluebutton room manager that offers a set of features useful to online workloads especially virtual schooling.
# https://docs.bigbluebutton.org/greenlight/v3/install
install_greenlight_v3(){
  check_root
  install_docker

  # Preparing and checking the enviroment.
  say "preparing and checking the enviroment to install/update greelight-v3..."

  if [ ! -d $GL3_DIR ]; then
    mkdir -p $GL3_DIR && say "created $GL3_DIR"
  fi

  local GL_IMG_REPO=bigbluebutton/greenlight:v3

  say "pulling latest $GL_IMG_REPO image..."
  docker pull $GL_IMG_REPO

  if [ ! -s $GL3_DIR/docker-compose.yml ]; then
    docker run --rm --entrypoint sh $GL_IMG_REPO -c 'cat docker-compose.yml' > $GL3_DIR/docker-compose.yml

    if [ ! -s $GL3_DIR/docker-compose.yml ]; then
      err "failed to create docker compose file - is docker running?"
    fi

    say "greenlight-v3 docker compose file was created"
  fi

  # Configuring Greenlight v3.
  say "checking the configuration of greenlight-v3..."

  # Configuring Greenlight v3 docker-compose.yml (if configured no side effect will happen).
  sed -i "s|^\([ \t-]*POSTGRES_PASSWORD\)\(=[ \t]*\)$|\1=$(openssl rand -hex 24)|g" $GL3_DIR/docker-compose.yml # Do not overwrite the value if not empty.

  local PGUSER=postgres # Postgres db user to be used by greenlight-v3.
  local PGTXADDR=postgres:5432 # Postgres DB transport address (pair of (@ip:@port)).
  local RSTXADDR=redis:6379 # Redis DB transport address (pair of (@ip:@port)).
  local PGPASSWORD=$(sed -ne "s/^\([ \t-]*POSTGRES_PASSWORD=\)\(.*\)$/\2/p" $GL3_DIR/docker-compose.yml) # Extract generated Postgres password.

  if [ -z "$PGPASSWORD" ]; then
    err "failed to retrieve greenlight-v3 DB password - retry to resolve."
  fi

  local DATABASE_URL_ROOT="postgres://$PGUSER:$PGPASSWORD@$PGTXADDR"
  local REDIS_URL_ROOT="redis://$RSTXADDR"

  local PGDBNAME=greenlight-v3-production
  local SECRET_KEY_BASE=$(docker run --rm --entrypoint bundle $GL_IMG_REPO exec rake secret)

  if [ -z "$SECRET_KEY_BASE" ]; then
    err "failed to generate greenlight-v3 secret key base - is docker running?"
  fi

  if [ ! -s $GL3_DIR/.env ]; then
    docker run --rm --entrypoint sh $GL_IMG_REPO -c 'cat sample.env' > $GL3_DIR/.env

    if [ ! -s $GL3_DIR/.env ]; then
      err "failed to create greenlight-v3 .env file - is docker running?"
    fi
 
    say "greenlight-v3 .env file was created"
  fi

  # A note for future maintainers:
  #   The following configuration operations were made idempotent, meaning that playing these actions will have an outcome on the system (configure it) only once.
  #   Replaying these steps are a safe and an expected operation, this gurantees the seemless simple installation and upgrade of Greenlight v3.
  #   A simple change can impact that property and therefore render the upgrading functionnality unoperationnal or impact the running system.

  # Configuring Greenlight v3 .env file (if already configured this will only update the BBB endpoint and secret).
  cp -v $GL3_DIR/.env $GL3_DIR/.env.old && say "old .env file can be retrieved at $GL3_DIR/.env.old" #Backup

  if [ -n "$BIGBLUEBUTTON" ]; then
    # BigBlueButton server configuration.
    local BIGBLUEBUTTON_ENDPOINT="https://${BIGBLUEBUTTON[0]}/bigbluebutton/api"
    local BIGBLUEBUTTON_SECRET=${BIGBLUEBUTTON[1]}

    # Re-configure a new BBB server to be used by Greenlight. 
    sed -i "s|^[# \t]*BIGBLUEBUTTON_ENDPOINT=.*|BIGBLUEBUTTON_ENDPOINT=$BIGBLUEBUTTON_ENDPOINT|" $GL3_DIR/.env
    sed -i "s|^[# \t]*BIGBLUEBUTTON_SECRET=.*|BIGBLUEBUTTON_SECRET=$BIGBLUEBUTTON_SECRET|"  $GL3_DIR/.env
  else
    # Demo BigBlueButton server configuration.
    local BIGBLUEBUTTON_ENDPOINT="https://test-install.blindsidenetworks.com/bigbluebutton/api"
    local BIGBLUEBUTTON_SECRET=8cd8ef52e8e101574e400365b55e11a6

    # The demo BBB server should be used when not specifying a dedicated one on installation only (no overwriting).
    sed -i "s|^[# \t]*BIGBLUEBUTTON_ENDPOINT=[ \t]*$|BIGBLUEBUTTON_ENDPOINT=$BIGBLUEBUTTON_ENDPOINT|" $GL3_DIR/.env # Do not overwrite the value if not empty.
    sed -i "s|^[# \t]*BIGBLUEBUTTON_SECRET=[ \t]*$|BIGBLUEBUTTON_SECRET=$BIGBLUEBUTTON_SECRET|"  $GL3_DIR/.env # Do not overwrite the value if not empty.
  fi

  sed -i "s|^[# \t]*SECRET_KEY_BASE=[ \t]*$|SECRET_KEY_BASE=$SECRET_KEY_BASE|" $GL3_DIR/.env # Do not overwrite the value if not empty.
  sed -i "s|^[# \t]*DATABASE_URL=[ \t]*$|DATABASE_URL=$DATABASE_URL_ROOT/$PGDBNAME|" $GL3_DIR/.env # Do not overwrite the value if not empty.
  sed -i "s|^[# \t]*REDIS_URL=[ \t]*$|REDIS_URL=$REDIS_URL_ROOT/|" $GL3_DIR/.env # Do not overwrite the value if not empty.

  # Placing greenlight-v3 nginx file, this will enable greenlight-v3 as your Bigbluebutton frontend (bbb-fe).
  cp -v $NGINX_FILES_DEST/greenlight-v3.nginx $NGINX_FILES_DEST/greenlight-v3.nginx.old && say "old greenlight-v3 nginx config can be retrieved at $NGINX_FILES_DEST/greenlight-v3.nginx.old" #Backup
  docker run --rm --entrypoint sh $GL_IMG_REPO -c 'cat greenlight-v3.nginx' > $NGINX_FILES_DEST/greenlight-v3.nginx && say "added greenlight-v3 nginx file"

  # Adding Keycloak
  if [ -n "$INSTALL_KC" ]; then
      # When attepmting to install/update Keycloak let us attempt to create the database to resolve any issues caused by postgres false negatives.
      docker-compose -f $GL3_DIR/docker-compose.yml up -d postgres && say "started postgres"
      wait_postgres_start
      docker-compose -f $GL3_DIR/docker-compose.yml exec -T postgres psql -U postgres -c 'CREATE DATABASE keycloakdb;'
  fi

  if ! grep -q 'keycloak:' $GL3_DIR/docker-compose.yml; then
    # The following logic is expected to run only once when adding Keycloak.
    # Keycloak isn't installed
    if [ -n "$INSTALL_KC" ]; then
      # Add Keycloak
      say "Adding Keycloak..."

      docker-compose -f $GL3_DIR/docker-compose.yml down
      cp -v $GL3_DIR/docker-compose.yml $GL3_DIR/docker-compose.base.yml # Persist working base compose file for admins as a Backup.

      docker run --rm --entrypoint sh $GL_IMG_REPO -c 'cat docker-compose.kc.yml' >> $GL3_DIR/docker-compose.yml

      if ! grep -q 'keycloak:' $GL3_DIR/docker-compose.yml; then
        err "failed to add Keycloak service to greenlight-v3 compose file - is docker running?"
      fi
      say "added Keycloak to compose file"

      KCPASSWORD=$(openssl rand -hex 12) # Keycloak admin password.
      sed -i "s|^\([ \t-]*KEYCLOAK_ADMIN_PASSWORD\)\(=[ \t]*\)$|\1=$KCPASSWORD|g" $GL3_DIR/docker-compose.yml # Do not overwrite the value if not empty.
      sed -i "s|^\([ \t-]*KC_DB_PASSWORD\)\(=[ \t]*\)$|\1=$PGPASSWORD|g" $GL3_DIR/docker-compose.yml # Do not overwrite the value if not empty.

      # Updating Keycloak nginx file.
      cp -v $NGINX_FILES_DEST/keycloak.nginx $NGINX_FILES_DEST/keycloak.nginx.old && say "old Keycloak nginx config can be retrieved at $NGINX_FILES_DEST/keycloak.nginx.old"
      docker run --rm --entrypoint sh $GL_IMG_REPO -c 'cat keycloak.nginx' > $NGINX_FILES_DEST/keycloak.nginx && say "added Keycloak nginx file"
    fi

  else
    # Update Keycloak nginx file only.
    cp -v $NGINX_FILES_DEST/keycloak.nginx $NGINX_FILES_DEST/keycloak.nginx.old && say "old Keycloak nginx config can be retrieved at $NGINX_FILES_DEST/keycloak.nginx.old"
    docker run --rm --entrypoint sh $GL_IMG_REPO -c 'cat keycloak.nginx' > $NGINX_FILES_DEST/keycloak.nginx && say "added Keycloak nginx file"
  fi

  # Update .env file catching new configurations:
  if ! grep -q 'RELATIVE_URL_ROOT=' $GL3_DIR/.env; then
      cat <<HERE >> $GL3_DIR/.env
#RELATIVE_URL_ROOT=/gl

HERE
  fi

  if [ -n "$GL_PATH" ]; then
    sed -i "s|^[# \t]*RELATIVE_URL_ROOT=.*|RELATIVE_URL_ROOT=$GL_PATH|" $GL3_DIR/.env
  fi

  local GL_RELATIVE_URL_ROOT=$(sed -ne "s/^\([ \t]*RELATIVE_URL_ROOT=\)\(.*\)$/\2/p" $GL3_DIR/.env) # Extract relative URL root path.
  say "Deploying Greenlight on the '${GL_RELATIVE_URL_ROOT:-$GL_DEFAULT_PATH}' path..."

  if [ -n "$GL_RELATIVE_URL_ROOT" ] && [ "$GL_RELATIVE_URL_ROOT" != "$GL_DEFAULT_PATH" ]; then
    sed -i "s|^\([ \t]*location\)[ \t]*\(.*/cable\)[ \t]*\({\)$|\1 $GL_RELATIVE_URL_ROOT/cable \3|" $NGINX_FILES_DEST/greenlight-v3.nginx
    sed -i "s|^\([ \t]*location\)[ \t]*\(@bbb-fe\)[ \t]*\({\)$|\1 $GL_RELATIVE_URL_ROOT \3|" $NGINX_FILES_DEST/greenlight-v3.nginx
  fi

  nginx -qt || err 'greenlight-v3 failed to install/update due to nginx tests failing to pass - if using the official image then please contact the maintainers.'
  nginx -qs reload && say 'greenlight-v3 was successfully configured'

  # Eager pulling images.
  say "pulling latest greenlight-v3 services images..."
  docker-compose -f $GL3_DIR/docker-compose.yml pull

  if check_container_running greenlight-v3; then
    # Restarting Greenlight-v3 services after updates.
    say "greenlight-v3 is updating..."
    say "shutting down greenlight-v3..."
    docker-compose -f $GL3_DIR/docker-compose.yml down
  fi

  say "starting greenlight-v3..."
  docker-compose -f $GL3_DIR/docker-compose.yml up -d
  sleep 5
  say "greenlight-v3 is now installed and accessible on: https://$HOST${GL_RELATIVE_URL_ROOT:-$GL_DEFAULT_PATH}"
  say "To create Greenlight administrator account, see: https://docs.bigbluebutton.org/greenlight/v3/install#creating-an-admin-account"


  if grep -q 'keycloak:' $GL3_DIR/docker-compose.yml; then
    say "Keycloak is installed, up to date and accessible for configuration on: https://$HOST/keycloak/"
    if [ -n "$KCPASSWORD" ];then
      say "Use the following credentials when accessing the admin console:"
      say "   admin"
      say "   $KCPASSWORD"
    fi

    say "To complete the configuration of Keycloak, see: https://docs.bigbluebutton.org/greenlight/v3/external-authentication#configuring-keycloak"
  fi

  return 0;
}

wait_postgres_start() {
  say "Waiting for the Postgres DB to start..."
  docker-compose -f $GL3_DIR/docker-compose.yml up -d postgres || err "failed to start Postgres service - retry to resolve"

  local tries=0
  while ! docker-compose -f $GL3_DIR/docker-compose.yml exec -T postgres pg_isready 2> /dev/null 1>&2; do
    echo -n .
    sleep 3
    if (( ++tries == 3 )); then
      err "failed to start Postgres due to reaching waiting timeout - retry to resolve" 
    fi
  done

  say "Postgres is ready!"

  return 0;
}

install_ssl() {
  # Assertions for fresh installations
  if [ ! -f /etc/nginx/sites-available/greenlight ]; then
    if [ -d "/etc/letsencrypt/live/$HOST" ]; then
      err "Unable to manage certificates for $HOST, /etc/letsencrypt/live/$HOST/ already exists."
    fi
  fi

  if [ -n "$PROVIDED_CERTIFICATE" ]; then
    if [ ! -f /local/certs/fullchain.pem ] || [ ! -f /local/certs/privkey.pem ]; then
      err "Unable to find your provided certificate files in /local/certs, Have you placed the full chain and private key for your certificate as expected?"
    fi

    # Detecting generated certs and possible conflicts.
    if [ -f /etc/letsencrypt/live/$HOST/fullchain.pem ]; then
      if [ ! "$(readlink -e /etc/letsencrypt/live/$HOST/fullchain.pem)" == /local/certs/fullchain.pem ]; then
        err "fullchain.pem was probably generated and not provided by this script, exiting to avoid conflict."
      fi
    fi

    if [ -f /etc/letsencrypt/live/$HOST/privkey.pem ]; then
      if [ ! "$(readlink -e /etc/letsencrypt/live/$HOST/privkey.pem)" == /local/certs/privkey.pem ]; then
        err "privkey.pem was probably generated and not provided by this script, exiting to avoid conflict."
      fi
    fi
  else
    # Detecting provided certs and possible conflicts.
    if [ -f /etc/letsencrypt/live/$HOST/fullchain.pem ]; then
      if [[ ! "$(readlink -e /etc/letsencrypt/live/$HOST/fullchain.pem)" =~ ^/etc/letsencrypt/archive/$HOST.*/fullchain.*\.pem$ ]]; then
        err "fullchain.pem was probably provided and not generated by this script, exiting to avoid conflict."
      fi
      local GENERATED_CERTS_EXIST=true
    fi

    if [ -f /etc/letsencrypt/live/$HOST/privkey.pem ]; then
      if [[ ! "$(readlink -e /etc/letsencrypt/live/$HOST/privkey.pem)" =~ ^/etc/letsencrypt/archive/$HOST.*/privkey.*\.pem$ ]]; then
        err "privkey.pem was probably provided and not generated by this script, exiting to avoid conflict."
      fi
    fi

    need_pkg certbot
  fi

  need_pkg nginx
  mkdir -p /etc/nginx/ssl $ACCESS_LOG_DEST $NGINX_FILES_DEST $ASSETS_DEST

  cp -v /etc/nginx/sites-available/greenlight /etc/nginx/sites-available/greenlight.old # Preserve older config for admins.

  # HTTP only
  # Updating HTTP config.
  cat <<HERE > /etc/nginx/sites-available/greenlight
server_tokens off;
server {
  listen 80;
  listen [::]:80;
  server_name $HOST;

  access_log  $ACCESS_LOG_DEST/greenlight.access.log;

  # Greenlight landing page.
  location / {
    root   $ASSETS_DEST;
    try_files \$uri @bbb-fe;
  }

  include $NGINX_FILES_DEST/*.nginx;
}

HERE

  if [ ! -f /etc/nginx/sites-enabled/greenlight ]; then
    ln -sf /etc/nginx/sites-available/greenlight /etc/nginx/sites-enabled/greenlight # Activate greenlight nginx config.
  fi

  if [ -f /etc/nginx/sites-enabled/default ]; then
    rm -v /etc/nginx/sites-enabled/default # Remove nginx default config.
  fi

  # Validating the config.
  nginx -qt || warn "Unable to configure nginx - if following the official guides then please contact the maintainers."
  systemctl restart nginx

# Enabling HTTPS.
  cp -v /etc/nginx/sites-available/greenlight /etc/nginx/sites-available/greenlight.http # Preserve valid HTTP config for admins.

  if [ -n "$PROVIDED_CERTIFICATE" ]; then
      say "Providing SSL certificates for $HOST..."
      mkdir -p "/etc/letsencrypt/live/$HOST" && say "Created $HOST live directory"
      ln -sf /local/certs/fullchain.pem "/etc/letsencrypt/live/$HOST/fullchain.pem" && say "fullchain.pem found and placed"
      ln -sf /local/certs/privkey.pem "/etc/letsencrypt/live/$HOST/privkey.pem" && say "privkey.pem found and placed"
  else
    # Auto generate a standalone SSL x509 certificate publicly signed by Let's encrypt for this domain $HOST.
    if [ -n "$GENERATED_CERTS_EXIST" ]; then
      say "Checking certificates of $HOST for renewal..."
      if certbot --email "$EMAIL" --agree-tos --rsa-key-size 4096 -w $ASSETS_DEST \
            -d "$HOST" --deploy-hook "systemctl reload nginx" $LETS_ENCRYPT_OPTIONS certonly; then
        say "Renewal checks passed!"
      else
        warn "Something went wrong when attempting to renew certificates!"
      fi
    else
      say "Generating certificates for $HOST..."
      say "Rehearsal phase..."
      if certbot --staging --email "$EMAIL" --agree-tos --rsa-key-size 4096 -w $ASSETS_DEST \
          -d "$HOST" --deploy-hook "systemctl reload nginx" $LETS_ENCRYPT_OPTIONS certonly; then
        say "Generating SSL certificates for $HOST..."
        say "Rehearsal passed, ready to issue production certificates!"
        say "Issuing production certificates..."
        if certbot --force-renewal --email "$EMAIL" --agree-tos --rsa-key-size 4096 -w $ASSETS_DEST \
            -d "$HOST" --deploy-hook "systemctl reload nginx" $LETS_ENCRYPT_OPTIONS certonly; then
          say "Production SSL certificates has been generated!"
        else
          warn "Something went wrong when generating production certificates"
        fi
      else
        warn "Unable to pass the rehearsal phase, avoided generating production certificates to keep rates under limit."
      fi
    fi
  fi

  say "Generating DH key exchange parameters..."
  cp -v /etc/nginx/ssl/dhp-4096.pem /etc/nginx/ssl/dhp-4096.pem.old

  # For security reasons upon upgrade, the Diffie Hellman key exchange parameters will rotate.
  if ! openssl dhparam -dsaparam  -out /etc/nginx/ssl/dhp-4096.pem 4096; then
    warn "Unable to generate DH key exchange parameters - rolling back..."
    mv -v /etc/nginx/ssl/dhp-4096.pem.old /etc/nginx/ssl/dhp-4096.pem || warn "Unable to generate new DH key exchage parameters nor to recover."
  else
    say "DH key exchange parameters was generated!"
  fi

  say "Configuring nginx with SSL enabled..."

  # Updating HTTPS config.
  cat <<HERE > /etc/nginx/sites-available/greenlight
server_tokens off;

server {
  listen 80;
  listen [::]:80;
  server_name $HOST;
  
  return 301 https://\$server_name\$request_uri; #redirect HTTP to HTTPS

}

server {
  listen 443 ssl http2;
  listen [::]:443 ssl http2;
  server_name $HOST;

  ssl_certificate /etc/letsencrypt/live/$HOST/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/$HOST/privkey.pem;
  ssl_session_cache shared:SSL:10m;
  ssl_session_timeout 10m;
  ssl_protocols TLSv1.2 TLSv1.3;
  ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
  ssl_dhparam /etc/nginx/ssl/dhp-4096.pem;
    
  # HSTS (comment out to enable)
  #add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

  access_log  $ACCESS_LOG_DEST/greenlight.access.log;

  # Greenlight landing page.
  location / {
    root   $ASSETS_DEST;
    try_files \$uri @bbb-fe;
  }

  include $NGINX_FILES_DEST/*.nginx;
}

HERE

  # Validating new config
  if ! nginx -qt; then
    # Rollback logic
    warn "Something went wrong configuring nginx - attempting to recover..."

    mv -v /etc/nginx/sites-available/greenlight /etc/nginx/sites-available/greenlight.https # Preserve used HTTPS config for admins.

    if mv -v /etc/nginx/sites-available/greenlight.old /etc/nginx/sites-available/greenlight; then
      warn "Fallen back to previous configuration!"
    else
      cp -v /etc/nginx/sites-available/greenlight.http /etc/nginx/sites-available/greenlight # Preserve used HTTP config for admins while falling back to HTTP. 
      warn "No previous configuration was found - fallen back to http configuration!"
    fi
    
    systemctl restart nginx

    warn "Unable to configure nginx with certificates, retry to resolve."

    return 1
  fi

  say "Nginx was configured successuflly with SSL enabled!"
  systemctl restart nginx && say "Nginx is UP!"

  return 0

}

# Given a container name as $1, this function will check if there's a match for that name in the list of running docker containers on the system.
# The result will be binded to $?.
check_container_running() {
  docker ps | grep -q "$1" || return 1;

  return 0;
}

install_docker() {
  apt-get remove --purge -y docker docker-engine docker.io containerd runc
  need_pkg ca-certificates curl gnupg lsb-release

  # Install Docker
  if ! apt-key list | grep -iq docker; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/docker.gpg || err "Something went wrong adding docker gpg key - exiting"
  fi

  if ! dpkg -l | grep -iq docker-ce; then
    echo \
      "deb [ arch=amd64 ] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

    chmod a+r /etc/apt/trusted.gpg.d/docker.gpg

    apt-get update
    need_pkg docker-ce docker-ce-cli containerd.io docker-compose-plugin
  fi

  if ! which docker; then err "Docker did not install"; fi

  # Purge older docker compose if exists.
  # DEPRECATED
  if dpkg -l | grep -q docker-compose; then
    apt-get purge -y docker-compose
  fi

  if [ ! -x /usr/local/bin/docker-compose ]; then
    curl -L "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
  fi

  if ! docker version > /dev/null ; then
    warn "Docker is failing, restarting it..."
    systemctl restart docker.socket docker.service
    sleep 5

    docker version > /dev/null || err "docker is failing to restart, something is wrong retry to resolve - exiting"
  fi

  say "docker is running!"
  return 0;
}

main "$@" || exit 1

LATEST="$(curl -s -I 'https://github.com/docker/compose/releases/latest'|grep Location:|awk '{print $2}'|sed 's|/tag|/download|g'|tr -d '\r'|xargs)"
COMPOSE="docker-compose-$(uname -s)-$(uname -m)"
sudo curl -s -L "${LATEST}/${COMPOSE}" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
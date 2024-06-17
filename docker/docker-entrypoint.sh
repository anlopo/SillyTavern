#!/bin/sh

if [ ! -e "config/config.yaml" ]; then
    echo "Resource not found, copying from defaults: config.yaml"
    cp -r "default/config.yaml" "config/config.yaml"
fi

# Add local CA authority to node
export NODE_EXTRA_CA_CERTS=/home/node/app/certs/myCA.pem

# Start the server
#exec node server.js --listen
# Start the server with SSL
exec node server.js --listen --ssl
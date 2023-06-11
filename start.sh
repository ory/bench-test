#!/usr/bin/env bash

set -euxo pipefail


killall hydra || true
killall node || true

echo $DSN
hydra serve all --config $HOME/openai-bench/hydra.config.yml  --dev &> $HOME/hydra.log &

export HYDRA_ADMIN_URL=http://127.0.0.1:4445
npm run start &> $HOME/consent.log &

sleep 5

client=$(hydra create client \
    --endpoint http://127.0.0.1:4445 \
    --grant-type authorization_code,refresh_token \
    --response-type code,id_token \
    --format json \
    --scope openid --scope offline \
    --redirect-uri http://127.0.0.1:5555/callback)
code_client_id=$(echo $client | jq -r '.client_id')
code_client_secret=$(echo $client | jq -r '.client_secret')
hydra perform authorization-code \
    --endpoint http://127.0.0.1:4444/ \
    --client-id "$code_client_id" \
    --client-secret "$code_client_secret" \
    --port 5555 \
    --scope openid --scope offline --no-shutdown &> $HOME/client.log &

sleep 2

curl http://127.0.0.1:5555

echo "All services are running."
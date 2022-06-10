#!/bin/bash
#
vault secrets enable -path=local kv-v2

vault kv put local/mysql/config username="root" password="db-secret-password"
vault kv put local/testserver/secret secret="vaultsecret"

vault policy write testserver - <<EOF
path "local/mysql/config" {
  capabilities = ["read"]
}
path "local/testserver/*" {
  capabilities = ["read"]
}
EOF

vault write auth/kubernetes/role/testserver \
    bound_service_account_names=testserver \
    bound_service_account_namespaces=testserver \
    policies=testserver \
    ttl=24h

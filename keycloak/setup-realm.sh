cat /tmp/realm-template.json | \
  sed "s|\${KEYCLOAK_REALM}|${KEYCLOAK_REALM}|" | \
  sed "s|\${KEYCLOAK_CLIENT_ID}|${KEYCLOAK_CLIENT_ID}|" | \
  sed "s|\${GLOWINGBEAR_HOSTNAME}|${GLOWINGBEAR_HOSTNAME}|" \
  > /tmp/realm-export.json

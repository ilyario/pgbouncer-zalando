ARG PGBOUNCER_VERSION=master-32
FROM --platform=linux/amd64 registry.opensource.zalan.do/acid/pgbouncer:${PGBOUNCER_VERSION}

ARG SSL_MODE=prefer

# Заменяем server_tls_sslmode в шаблоне конфигурации
RUN sed -i "s/^server_tls_sslmode[[:space:]]*=[[:space:]]*.*/server_tls_sslmode = ${SSL_MODE}/" /etc/pgbouncer/pgbouncer.ini.tmpl && \
    grep "server_tls_sslmode = ${SSL_MODE}" /etc/pgbouncer/pgbouncer.ini.tmpl || (echo "Failed to update server_tls_sslmode" && exit 1)

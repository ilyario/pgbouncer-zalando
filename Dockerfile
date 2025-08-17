ARG PGBOUNCER_VERSION=master-32
FROM registry.opensource.zalan.do/acid/pgbouncer:${PGBOUNCER_VERSION}

ARG SSL_MODE=prefer

RUN sed -i '/#/!s/\(server_tls_sslmode[[:space:]]*=[[:space:]]*\)\(.*\)/\1${SSL_MODE}/' /etc/pgbouncer/pgbouncer.ini.tmpl

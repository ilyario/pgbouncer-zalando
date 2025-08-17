# PgBouncer Docker Image

Docker image for PgBouncer with configurable SSL parameters.

#### Environment Variables

- `PGBOUNCER_VERSION`: PgBouncer version (default: `master-32`)
- `SSL_MODE`: SSL mode (default: `prefer`)

## SSL Modes

- `prefer` (default): use SSL if available
- `require`: require SSL connection
- `verify-ca`: verify SSL certificate
- `verify-full`: full SSL certificate verification
- `disable`: disable SSL


## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

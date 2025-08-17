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

## Testing

### Local Testing

Run the local test script to verify the image works correctly:

```bash
./test-local.sh
```

This script will:
1. Build the PgBouncer image
2. Start a test container
3. Verify configuration is valid
4. Check SSL mode settings
5. Clean up test resources

### Configuration

The image automatically configures the `server_tls_sslmode` parameter based on the `SSL_MODE` build argument. This parameter is used in newer versions of PgBouncer for SSL configuration.


## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

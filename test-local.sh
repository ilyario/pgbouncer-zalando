#!/bin/bash

# Local test script for PgBouncer image

set -e

# Clean up any existing containers
echo "🧹 Cleaning up existing containers..."
docker stop pgbouncer-test 2>/dev/null || true
docker rm pgbouncer-test 2>/dev/null || true

echo "🔧 Building PgBouncer image..."
docker build --platform linux/amd64 -t pgbouncer-test:latest .

echo "🔍 Testing configuration validation..."
docker run --rm pgbouncer-test:latest pgbouncer --test-config /etc/pgbouncer/pgbouncer.ini.tmpl
echo "✅ Configuration template is valid"

echo "📋 Checking SSL configuration..."
docker run --rm pgbouncer-test:latest cat /etc/pgbouncer/pgbouncer.ini.tmpl | grep server_tls_sslmode || echo "⚠️ server_tls_sslmode not found in config template"

echo "✅ Basic configuration test passed"

echo "🧹 Cleaning up..."
docker stop pgbouncer-test
docker rm pgbouncer-test

echo "✅ Test completed successfully!"

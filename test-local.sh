#!/bin/bash

# Local test script for PgBouncer image

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}🔧 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Clean up any existing containers and images
print_status "Cleaning up existing containers and images..."
docker stop pgbouncer-test 2>/dev/null || true
docker rm pgbouncer-test 2>/dev/null || true
docker rmi pgbouncer-test:latest 2>/dev/null || true
docker rmi pgbouncer-test:prefer 2>/dev/null || true
docker rmi pgbouncer-test:require 2>/dev/null || true

# Test 1: Build with default SSL_MODE (prefer)
print_status "Test 1: Building PgBouncer image with default SSL_MODE=prefer..."
docker build --platform linux/amd64 -t pgbouncer-test:prefer .

# Test 2: Build with SSL_MODE=require
print_status "Test 2: Building PgBouncer image with SSL_MODE=require..."
docker build --build-arg SSL_MODE=require --platform linux/amd64 -t pgbouncer-test:require .

# Test 3: Check SSL configuration for prefer mode
print_status "Test 3: Checking SSL configuration for prefer mode..."
PREFER_SSL_CONFIG=$(docker run --rm --entrypoint="" pgbouncer-test:prefer cat /etc/pgbouncer/pgbouncer.ini.tmpl | grep -E "(server_tls_sslmode|client_tls_sslmode)")
echo "$PREFER_SSL_CONFIG"

if echo "$PREFER_SSL_CONFIG" | grep -q "server_tls_sslmode = prefer" && echo "$PREFER_SSL_CONFIG" | grep -q "client_tls_sslmode = prefer"; then
    print_success "SSL configuration for prefer mode is correct"
else
    print_error "SSL configuration for prefer mode is incorrect"
    exit 1
fi

# Test 4: Check SSL configuration for require mode
print_status "Test 4: Checking SSL configuration for require mode..."
REQUIRE_SSL_CONFIG=$(docker run --rm --entrypoint="" pgbouncer-test:require cat /etc/pgbouncer/pgbouncer.ini.tmpl | grep -E "(server_tls_sslmode|client_tls_sslmode)")
echo "$REQUIRE_SSL_CONFIG"

if echo "$REQUIRE_SSL_CONFIG" | grep -q "server_tls_sslmode = require" && echo "$REQUIRE_SSL_CONFIG" | grep -q "client_tls_sslmode = require"; then
    print_success "SSL configuration for require mode is correct"
else
    print_error "SSL configuration for require mode is incorrect"
    exit 1
fi

# Test 5: Test with different SSL_MODE values
print_status "Test 5: Testing with different SSL_MODE values..."
for ssl_mode in "disable" "allow" "prefer" "require" "verify-ca" "verify-full"; do
    print_status "Testing SSL_MODE=$ssl_mode..."
    docker build --build-arg SSL_MODE="$ssl_mode" --platform linux/amd64 -t pgbouncer-test:temp . >/dev/null 2>&1

    SSL_CONFIG=$(docker run --rm --entrypoint="" pgbouncer-test:temp cat /etc/pgbouncer/pgbouncer.ini.tmpl | grep -E "(server_tls_sslmode|client_tls_sslmode)")

    if echo "$SSL_CONFIG" | grep -q "server_tls_sslmode = $ssl_mode" && echo "$SSL_CONFIG" | grep -q "client_tls_sslmode = $ssl_mode"; then
        print_success "SSL_MODE=$ssl_mode works correctly"
    else
        print_error "SSL_MODE=$ssl_mode failed"
        docker rmi pgbouncer-test:temp 2>/dev/null || true
        exit 1
    fi

    docker rmi pgbouncer-test:temp 2>/dev/null || true
done

# Test 6: Verify that the sed commands actually changed the values
print_status "Test 6: Verifying that sed commands actually modified the configuration..."
ORIGINAL_CONFIG=$(docker run --rm --entrypoint="" registry.opensource.zalan.do/acid/pgbouncer:master-32 cat /etc/pgbouncer/pgbouncer.ini.tmpl | grep -E "(server_tls_sslmode|client_tls_sslmode)" || echo "No SSL config found in original")
MODIFIED_CONFIG=$(docker run --rm --entrypoint="" pgbouncer-test:prefer cat /etc/pgbouncer/pgbouncer.ini.tmpl | grep -E "(server_tls_sslmode|client_tls_sslmode)")

echo "Original config:"
echo "$ORIGINAL_CONFIG"
echo "Modified config:"
echo "$MODIFIED_CONFIG"

if [ "$ORIGINAL_CONFIG" != "$MODIFIED_CONFIG" ]; then
    print_success "Configuration was successfully modified"
else
    print_warning "Configuration appears unchanged - this might be expected if original values were already 'prefer'"
fi

# Clean up
print_status "Cleaning up test images..."
docker rmi pgbouncer-test:prefer 2>/dev/null || true
docker rmi pgbouncer-test:require 2>/dev/null || true

print_success "All tests completed successfully!"
print_success "✅ PgBouncer image is working correctly with SSL configuration"

#!/bin/bash

set -e  # Exit on any error

echo "=== Starting LaTeX-On-HTTP Services ==="
echo "Timestamp: $(date)"
echo "Working directory: $(pwd)"
echo "Available commands:"
which make || echo "make not found"
which python3 || echo "python3 not found"

# Test if we can run the cache service at all
echo "Testing cache service startup..."
timeout 10s make start-cache > /tmp/cache-test.log 2>&1 &
TEST_PID=$!
sleep 3
if kill -0 $TEST_PID 2>/dev/null; then
    echo "✅ Cache service can start (test successful)"
    kill $TEST_PID 2>/dev/null || true
else
    echo "❌ Cache service failed to start in test"
    echo "Test logs:"
    cat /tmp/cache-test.log || echo "No test logs available"
fi

# Start cache service in background
echo "Starting cache service..."
make start-cache > /tmp/cache.log 2>&1 &
CACHE_PID=$!

echo "Cache service started with PID: $CACHE_PID"

# Wait a moment for cache to start
echo "Waiting for cache service to initialize..."
sleep 10

# Check if cache started successfully
if ! kill -0 $CACHE_PID 2>/dev/null; then
    echo "ERROR: Cache service failed to start (PID: $CACHE_PID)"
    echo "Cache service logs:"
    cat /tmp/cache.log || echo "No cache logs available"
    echo "Process list:"
    ps aux | grep -E "(python|make)" || echo "No python/make processes found"
    exit 1
fi

echo "✅ Cache service is running with PID: $CACHE_PID"
echo "Cache service logs (first 10 lines):"
head -10 /tmp/cache.log || echo "No cache logs available"

# Start main application
echo "Starting main application..."
make start

#!/bin/bash

set -e

if [[ -z "${ALEO_PRIVATE_KEY}" ]]; then
    echo "🔴 Error: ALEO_PRIVATE_KEY is not set."
    exit 1
fi

echo "🔥 Running Pre-Deployment Build Check..."
leo clean

BUILD_LOG="build_errors.log"

# Capture `leo build` output and filter errors
if ! leo build --network testnet 2>&1 | tee "$BUILD_LOG"; then
    echo "🔴 Parsing error detected!"
    echo "🔍 Debugging Info (Error + 3 Surrounding Lines):"

    # Extract the first error with 3 lines before and after
    grep -A 3 -B 3 -E "error:|Error" "$BUILD_LOG" | head -n 10

    exit 248
fi

echo "🔥 Starting deployment funnel for PNW-MVP..."
leo deploy --network testnet --private-key ${ALEO_PRIVATE_KEY}

if [ $? -eq 0 ]; then
    echo "✅ All contracts deployed successfully!"
else
    echo "🔴 Deployment failed. Check logs above."
    exit 1
fi

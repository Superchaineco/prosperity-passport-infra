#!/bin/bash
set -e  # Salir inmediatamente si un comando falla

if [ -f .env ]; then
  echo "Loading .env variables..."
  source .env
else
  echo ".env file not found!"
  exit 1
fi

BADGES_SCRIPT_PATH="script/DeployBadges.s.sol:DeployBadges"
POSTBADGES_SCRIPT_PATH="script/PostDeployBadges.s.sol:PostDeployBadges"
MODULE_SCRIPT_PATH="script/DeployModule.s.sol:DeployModule"
POSTMODULE_SCRIPT_PATH="script/PostDeployModule.s.sol:PostDeployModule"

echo "🚀 Step 1: Deploying badges..."
# Deploy badges proxy
BADGES_OUTPUT_FILE=$(mktemp)
if ! forge script "$BADGES_SCRIPT_PATH" --force --rpc-url "$NETWORK" --chain "$NETWORK" --sender "$SENDER" --private-key "$PRIVATE_KEY" --ffi --json > "$BADGES_OUTPUT_FILE"; then
  echo "Error: Failed to deploy badges."
  cat "$BADGES_OUTPUT_FILE" | grep "Error"
  exit 1
fi
FULL_BADGES_OUTPUT=$(cat "$BADGES_OUTPUT_FILE")
rm "$BADGES_OUTPUT_FILE"

echo "Full output of badges deployment:"
echo "$FULL_BADGES_OUTPUT" | tail -n 1 | jq -r '.returns'
BADGES_ADDRESS=$(echo "$FULL_BADGES_OUTPUT" | tail -n 1 | jq -r '.returns["0"].value')
echo "✅ Badges deployed at $BADGES_ADDRESS"

echo "🚀 Step 2: Deploying post badges..."
# Deploy post badges proxy
RESOLVER_OUTPUT_FILE=$(mktemp)
if ! NETWORK="$NETWORK" BADGES_ADDRESS="$BADGES_ADDRESS" forge script "$POSTBADGES_SCRIPT_PATH" --rpc-url "$NETWORK" --chain "$NETWORK" --sender "$SENDER" --private-key "$PRIVATE_KEY" --broadcast --verify --json > "$RESOLVER_OUTPUT_FILE"; then
  echo "Error: Failed to deploy post badges."
  cat "$RESOLVER_OUTPUT_FILE" | grep "Error"
  exit 1
fi
FULL_RESOLVER_OUTPUT=$(cat "$RESOLVER_OUTPUT_FILE")
rm "$RESOLVER_OUTPUT_FILE"

echo "Full output of post badges deployment:"
echo "$FULL_RESOLVER_OUTPUT" | grep "{" | tail -n 1 | jq -r '.returns' 
RESOLVER_ADDRESS=$(echo "$FULL_RESOLVER_OUTPUT" | grep "{" | tail -n 1 | jq -r '.returns["0"].value')
echo "✅ Resolver deployed at $RESOLVER_ADDRESS"

echo "🚀 Step 3: Deploying module..."
# Deploy module
MODULE_OUTPUT_FILE=$(mktemp)
if ! RESOLVER_ADDRESS="$RESOLVER_ADDRESS" forge script  "$MODULE_SCRIPT_PATH" --force  --rpc-url "$NETWORK" --chain "$NETWORK" --sender "$SENDER" --private-key "$PRIVATE_KEY" --ffi --json > "$MODULE_OUTPUT_FILE"; then
  echo "Error: Failed to deploy module."
  cat "$MODULE_OUTPUT_FILE" | grep "Error"
  exit 1
fi
FULL_MODULE_OUTPUT=$(cat "$MODULE_OUTPUT_FILE")
rm "$MODULE_OUTPUT_FILE"

echo "Full output of module deployment:"
echo "$FULL_MODULE_OUTPUT" | tail -n 1 | jq -r '.returns'
MODULE_ADDRESS=$(echo "$FULL_MODULE_OUTPUT" | tail -n 1 | jq -r '.returns["0"].value')
echo "✅ Module deployed at $MODULE_ADDRESS"

echo "🚀 Step 4: Executing post module..."
# Deploy post module
POSTMODULE_OUTPUT_FILE=$(mktemp)
if ! RESOLVER_ADDRESS="$RESOLVER_ADDRESS" MODULE_ADDRESS="$MODULE_ADDRESS" BADGES_ADDRESS="$BADGES_ADDRESS" forge script "$POSTMODULE_SCRIPT_PATH" --rpc-url "$NETWORK" --chain "$NETWORK" --sender "$SENDER" --private-key "$PRIVATE_KEY" --broadcast --verify --json > "$POSTMODULE_OUTPUT_FILE"; then
  echo "Error: Failed to execute post module script."
  cat "$POSTMODULE_OUTPUT_FILE" | grep "Error"
  exit 1
fi
FULL_POSTMODULE_OUTPUT=$(cat "$POSTMODULE_OUTPUT_FILE")
rm "$POSTMODULE_OUTPUT_FILE"

echo "Full output of post module script execution:"
echo "$FULL_POSTMODULE_OUTPUT"
echo "✅ Post module script executed"

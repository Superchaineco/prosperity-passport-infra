#!/bin/bash
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
FULL_BADGES_OUTPUT=$(forge script "$BADGES_SCRIPT_PATH" --force --rpc-url "$NETWORK" --chain "$NETWORK" --sender "$SENDER" --private-key "$PRIVATE_KEY" --ffi --json)
echo "Full output of badges deployment:"
echo "$FULL_BADGES_OUTPUT" | tail -n 1 | jq -r '.returns'
BADGES_ADDRESS=$(echo "$FULL_BADGES_OUTPUT" | tail -n 1 | jq -r '.returns["0"].value')
echo "✅ Badges deployed at $BADGES_ADDRESS"

echo "🚀 Step 2: Deploying post badges..."
# Deploy post badges proxy
FULL_RESOLVER_OUTPUT=$(NETWORK="$NETWORK" BADGES_ADDRESS="$BADGES_ADDRESS" forge script "$POSTBADGES_SCRIPT_PATH" --rpc-url "$NETWORK" --chain "$NETWORK" --sender "$SENDER" --private-key "$PRIVATE_KEY" --broadcast --verify --json)
echo "Full output of post badges deployment:"
echo "$FULL_RESOLVER_OUTPUT" | grep "{" | tail -n 1 | jq -r '.returns' 
RESOLVER_ADDRESS=$(echo "$FULL_RESOLVER_OUTPUT" | grep "{" | tail -n 1 | jq -r '.returns["0"].value')
echo "✅ Resolver deployed at $RESOLVER_ADDRESS"

echo "🚀 Step 3: Deploying module..."
# Deploy module
FULL_MODULE_OUTPUT=$(RESOLVER_ADDRESS="$RESOLVER_ADDRESS" forge script  "$MODULE_SCRIPT_PATH" --force  --rpc-url "$NETWORK" --chain "$NETWORK" --sender "$SENDER" --private-key "$PRIVATE_KEY" --ffi --json)
echo "Full output of module deployment:"
echo "$FULL_MODULE_OUTPUT" | tail -n 1 | jq -r '.returns'
MODULE_ADDRESS=$(echo "$FULL_MODULE_OUTPUT" | tail -n 1 | jq -r '.returns["0"].value')
echo "✅ Module deployed at $MODULE_ADDRESS"

echo "🚀 Step 4: Executing post module..."
# Deploy post module
FULL_POSTMODULE_OUTPUT=$(RESOLVER_ADDRESS="$RESOLVER_ADDRESS" MODULE_ADDRESS="$MODULE_ADDRESS" BADGES_ADDRESS="$BADGES_ADDRESS" forge script "$POSTMODULE_SCRIPT_PATH" --rpc-url "$NETWORK" --chain "$NETWORK" --sender "$SENDER" --private-key "$PRIVATE_KEY" --broadcast --verify --json)
echo "Full output of post module script execution:"
echo "$FULL_POSTMODULE_OUTPUT"
echo "✅ Post module script executed"
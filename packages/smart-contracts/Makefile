# Variables
PRIVATE_KEY ?= $(shell echo $$PRIVATE_KEY)
NETWORK = sepolia
RPC_URL = https://rpc.sepolia.org
SENDER = 0x8835669696Fb92839aB198cD80ce9f0d35F45aD5
CHAIN_ID = sepolia
VERBOSE_FLAGS = -vvvv
FFI_FLAGS = --ffi

# Directories
OUTPUT_DIR = output
PROXY_FILE = $(OUTPUT_DIR)/proxy_address.txt

# Read proxy address from file
PROXY_ADDRESS = $(shell cat $(PROXY_FILE))

# Commands
CLEAN = forge clean
DEPLOY_SCRIPT = forge script script/DeployUpgradeable.s.sol:DeployUpgradeable --rpc-url $(RPC_URL) --chain $(CHAIN_ID) --private-key $(PRIVATE_KEY) --broadcast --verify --sender $(SENDER) $(VERBOSE_FLAGS) $(FFI_FLAGS)
VERIFY_CONTRACT = forge verify-contract --chain-id $(CHAIN_ID) $(PROXY_ADDRESS) "src/SuperChainModuleUpgradeable.sol:SuperChainModuleUpgradeable"
POST_DEPLOY_SCRIPT = forge script script/PostUpgradableDeploy.s.sol:PostUpgradableDeploy --rpc-url $(RPC_URL) --chain $(CHAIN_ID) --private-key $(PRIVATE_KEY) --broadcast --sender $(SENDER) $(VERBOSE_FLAGS)

# Targets
all: clean deploy verify post-deploy

clean:
    $(CLEAN)

deploy:
    mkdir -p $(OUTPUT_DIR)
    $(DEPLOY_SCRIPT)

verify:
    $(VERIFY_CONTRACT)

post-deploy:
    $(POST_DEPLOY_SCRIPT)

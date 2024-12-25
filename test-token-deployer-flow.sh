#!/bin/bash

env=$1
mode=$2
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

deploy(){
    
    echo "Starting deployment Launchpad flow $mode..."
    setup_env
    # deploy_frontend
    deploy_token_deployer
    create_test_token
}

setup_env(){
    if [ "$env" == "" ]; then
        env="local"
        echo "==> Setting up environment for local..."
    else
        echo "==> Setting up environment for $env..."
    fi
    if [ "$mode" == "reset" ]; then
        echo -e "${YELLOW}Resetting environment...${NC}"
        dfx stop
        dfx start --background --clean
    fi
    dfx canister create token_deployer --network=$env
    # dfx ledger fabricate-cycles --canister token_deployer --network=$env #topup 10T cycles
    dfx identity use default --network=$env #use default identity
}

deploy_frontend(){
    if [ "$mode" == "reset" ]; then
        echo -e "${GREEN}==> Deploying Frontend...${NC}"
        dfx deploy frontend --network=$env
    fi
}

deploy_token_deployer(){
    echo -e "${GREEN}==> Preparing for Token Deployer...${NC}"
    # Get the latest version of SNS-WASM
    hex="25071c2c55ad4571293e00d8e277f442aec7aed88109743ac52df3125209ff45"
    sns_icrc_wasm_file="sns_icrc_wasm_file.wasm"
    # Convert hex to vec nat8
    vec_nat8_hex=$(echo $hex | sed 's/\(..\)/\1 /g' | tr ' ' '\n' | while read -r byte; do
        printf "%d;" $((16#$byte))
    done | sed 's/;$//' | sed 's/;0$//')

    # Check if local file has not wasm
    if [ ! -f "$sns_icrc_wasm_file" ]; then
        echo -e "${YELLOW}WASM file does not exist, downloading...${NC}"
        # Call get_wasm to get the wasm from mainnet
        result=$(dfx canister --network ic call qaa6y-5yaaa-aaaaa-aaafa-cai get_wasm '(record { hash = vec { '$vec_nat8_hex' } })' --output idl)
        # Check if there is wasm
        has_wasm=$(echo "$result" | grep -q "opt record" && echo "true" || echo "false")

        if [ "$has_wasm" = "true" ]; then
            # Get blob wasm
            wasm=$(echo "$result" | sed -n 's/.*blob "\([^"]*\)".*/\1/p')
            # Save wasm to file
            echo "$wasm" | xxd -r -p > $sns_icrc_wasm_file
            echo "WASM saved to $sns_icrc_wasm_file"
        else
            echo "No WASM found"
        fi

    fi

    # If have wasm, save to file and deploy to token_deployer
    if [ -f "$sns_icrc_wasm_file" ]; then
        echo -e "${GREEN}==> Deploying Token Deployer...${NC}"
        dfx deploy token_deployer --network=$env
        echo -e "${YELLOW}==> Uploading SNS ICRC WASM to token_deployer...${NC}"
        MAX_CHUNK_SIZE=$((100 * 1024))  # 100KB
        WASM_FILE="$sns_icrc_wasm_file"
        FILE_SIZE=$(stat -f%z "$WASM_FILE")
        echo "WASM file size: $FILE_SIZE"
        CHUNK_COUNT=$(( (FILE_SIZE + MAX_CHUNK_SIZE - 1) / MAX_CHUNK_SIZE ))

        # Upload chunks, clear buffer first
        result=$(dfx canister --network=$env call token_deployer clearChunks)
        echo -e "${YELLOW}Clearing buffer: $result${NC}"

        # Calculate total chunk
        CHUNK_COUNT=$(( (FILE_SIZE + MAX_CHUNK_SIZE - 1) / MAX_CHUNK_SIZE ))

        for ((chunk=0; chunk<CHUNK_COUNT; chunk++))
        do
            # Calculate start position of chunk
            byteStart=$((chunk * MAX_CHUNK_SIZE))
            
            # Cut chunk from WASM file and convert to Candid vec
            chunk_data=$(dd if="$WASM_FILE" bs=1 skip=$byteStart count=$MAX_CHUNK_SIZE 2>/dev/null | \
            xxd -p -c 1 | \
            awk '{printf "0x%s; ", $1}' | \
            sed 's/; $//' | \
            awk '{print "(vec {" $0 "})"}'
            )
            
            # Upload chunk to canister
            result=$(dfx canister --network=$env call token_deployer uploadChunk "$chunk_data")
            echo -e "${YELLOW}Uploading chunk: $chunk -----> OK: $result${NC}"
        done
        # Finalizing upload
        echo "Uploaded chunk, finalizing upload..."
        
        result=$(dfx canister --network=$env call token_deployer addWasm "(vec { $vec_nat8_hex } )")
        echo -e "${GREEN}Finalizing upload: $result${NC}"
    else
        echo -e "${YELLOW}No WASM to save, skip deploy token_deployer${NC}"
    fi

}

create_test_token(){
    echo "==> Creating token..."
    owner_principal="$(dfx identity get-principal)"
    dfx canister --network=$env call token_deployer install "(record {
        token_symbol = \"TEST\";
        transfer_fee = 10000;
        token_name = \"Test Token\";
        minting_account = record { owner = principal \"$owner_principal\"; subaccount = null };
        initial_balances = vec {};
        fee_collector_account = null;
        logo = \"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAFCklEQVR4AYWWA5AlWRqFv3Mz32uUq2a7atq2baxt27aNwNi2bdu2bXumXD31MvOe3XjxoqIVsV9a5+Tl/4sd8NSSmUGSgIIaSZp0SGqRQFIn8NoWzxJJBiLboFc3LmZL+nr7E2rCSQiLkL4haZOkCZLqagb9kp6TdB3SicC9tfdr3zKEXtu4BGr09vSlQC6pQ+IgSZ9DQlttbHVN9ciZkn4BvC6pqkGNgABBT09vapwDG4DHgc8Brr0cAcMQBmLtmUFfAB6XtA7IQSk1Yb22aSkvVwYSoGgYyDdIuq72p5mkEhIKgZAEUGCoBMQtS5MhlSQRynE9cKOzUNXUzRvnBCCuvvftnZ+Y0vhYQI2SCokEiZCkkGcUAwNgo6phQlpuQMkwRKRmkisolUP3wG1jZgCv1214Ici0Vp0u+vj4M2e/2P/5Ig1ZQCUJlCQUvb2URrXT/qH3M3zGTEhtdz9Iz8sXicFXCOVmcAGA5IyoUmjIzgK+UHmiKVHnz6ey6KNLF059eeDevY96wg2DUUUSCFXxHto+9Rla//pvbu5r4c7nAWDpRFjb8QY8+wvyl84glEZi5+AIsqkgDyZLgHvS+k+8QPub877xwk7DOGfVe4ofX/Fq2ttQoujupu3Tn2H4rvvzlWP7ufiOlygMAIngo4vaOOrbp1M/kFB56VRCqRGqJi5QTEn9jaoBKWRiU91AzgVL28Kmh7uZ9Go/2ah2Wv/6n6r4WTd3MrqtjG0AhDjnrrdAbZz2vQPQ29dB3g0hAWLAAN4IoMUnf6bd+JFQuLV3ePC6J/r1jyMfoO2H3+T+7+7OR/7zEi2NZfLCbEkaRGd/hYt/P5Z1/hGDTx9BUm6BmBssiJ3gOWm0W7DrCkHd5kI3Tm/gpql1fG3SdG5/AYoIttkW4+qzO5+DdfPnYQMkoCgwmDqgJcXGNgZkoyJy3Oqd+Fo5kESw+P8oqW0BCGCDBJhgu9N2P9FE7BGDBY+OGcFpw17zxg4gEUJsixBJgGUTgJ6HkVJAQHDNqB9Cp7Jrm1n8/Np7MItsRyBksaAxHcn1XzmGH52YcPLtXYxtLmM8JP5yV4UvLGvh1O+/S3bLSpR310oQI3YA3wcsSlGC7WupGRhCWQmv9r/F3246gBO+8w8wnH1PN4UBIAi+uaKZfb9ZR+ejv3dT9oZi2gTOwYooBvB1ACkKOPpE4Le2EwO5I03lek5/5Epsc8i3fsXvPjCGu54HgOUTob29h1Nv+4u/lp0pDWuBWAAB5AQAcyKAZh35kQQoEGdgvmA7A5dsCBJdm3sZNbKNT89cw7xRk7HhoTee4qSHbuGgMQ/w4fZAJTMJEXBmuwQ+G/g8kKRb9MFf2HzQdrWsNmkRI03D6ukZ7OPgO86liJGA6S4Svjc6+sMdZVWySCIDFNglyT3gXwAAVn7jOOY+MjsBCsM62zdgMM5wtSRbBA6IhpTIZXNeY8LwjCyaUHsXIuCNwPXYVc3/GUwAYM7DM1Igt73O5sJqScC2C+xgUIL1ZkX8dXyf/zChx4OZYqqYYAvcg+Mnq+LEoaim/KZJ1GD2g9OqD2KM7bYPAj5vG2wEbC5g/LCCqxd0MSKJFNEIA/Fs7J8Dr+FsSLxmMJktmfXAlKHAXRTFItvfwGwUntibU3fYjAF/tuPdgcEKz6eK14KHgj5xcPugn988lW2Zed/EAGjLl/sH8462NLY8uKKPiLdKW1wMJNgGItvwX49ZkLRYxcE6AAAAAElFTkSuQmCC\";
    })"
    echo -e "${GREEN}Token created successfully!${NC}"
}

# Run deployment
deploy
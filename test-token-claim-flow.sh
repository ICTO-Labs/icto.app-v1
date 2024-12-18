#!/bin/bash

env=$1
distribute_mode=$2 # Whitelist or Public #Uppercase
controllerId=$3

deploy(){

if [ "$env" == "local" ]; then
        echo "local"
        dfx stop
        dfx start --background --clean
fi

if [ "$controllerId" == "" ]; then
        controllerId="$(dfx identity get-principal)"
fi
create_identity_list
deploy_test_token
deploy_backend
create_claim_contract

}

create_identity_list(){
    echo "==> Creating Identity List..."
    dfx identity new claim_user1
    dfx identity new claim_user2
    dfx identity new claim_user3
}

deploy_test_token(){
    echo "==> Deploying ICTO Test Token..."
    minting_account="$(dfx identity get-principal)"
    dfx deploy --network=$env icrc1_token --argument="( record {name = \"ICTO Test Token\"; symbol = \"tICTO\"; decimals = 8; fee = 10_000; max_supply = 10000000000000000000000; initial_balances = vec {record {record {owner = principal \"$minting_account\";subaccount = null;};1000000000000000000}};min_burn_amount = 10_000;minting_account = null;advanced_settings = null; })"
}

deploy_backend(){
    echo "==> Deploying Backend..."
    dfx deploy backend --network=$env
}

create_claim_contract(){
    echo "==> Creating Claim Contract..."
    token_canister_id=$(dfx canister --network=$env id icrc1_token)
    echo "Using token: $token_canister_id"
    owner_principal="$(dfx identity get-principal)"
    total_amount=10000000000000 #amount of tICTO to distribute (only set for Public mode)
    if [ "$distribute_mode" == "Whitelist" ]; then

        claim_user1_principal="$(dfx identity get-principal claim_user1)"
        claim_user2_principal="$(dfx identity get-principal claim_user2)"
        claim_user3_principal="$(dfx identity get-principal claim_user3)"
        recipients="opt vec { 
            record { 
                \"address\"= \"$claim_user1_principal\"; 
                \"amount\"= 20_000_000_000; 
                \"note\"= opt \"Developer\"; 
            }; 
            record { 
                \"address\"= \"$claim_user2_principal\"; 
                \"amount\"= 15_000_000_000; 
                \"note\"= opt \"Marketing\"; 
            }; 
            record { 
                \"address\"= \"$claim_user3_principal\"; 
                \"amount\"= 12_000_000_000; 
                \"note\"= opt \"Marketing\"; 
            }; 
        };"
        durationUnit=30 #30 days
        durationTime=86400 #1 day
        cliffUnit=0 #3 days
        cliffTime=0 #1 day
        unlockSchedule=86400 #1 day
        initialUnlockPercentage=40 #40% of the total amount will be unlocked immediately
    else
        recipients="opt vec { }; };"
        durationUnit=0 #0 instant unlock
        durationTime=0
        cliffUnit=0
        cliffTime=0
        unlockSchedule=0
        initialUnlockPercentage=0
    fi

    current_time=$(date '+%s') # Get current time with microsecond
    time_plus_2min=$((current_time + 120)) # Add 2 minutes

    $result = $(dfx canister call backend createContract "(
        record {
            \"title\" = \"Claim ICTO Test Tokens\";
            \"description\" = \"You can claim tICTO (Test Token) to paticipate in Launchpad. Once you have your tICTO tokens, you can connect your wallet to Launchpad and start participating in the platform. This contract is protected by BlockID to ensure the integrity of the distribution process.\";
            \"durationTime\" = $durationTime;
            \"durationUnit\" = $durationUnit;
            \"cliffTime\" = $cliffTime;
            \"cliffUnit\" = $cliffUnit;
            \"unlockSchedule\" = $unlockSchedule;
            \"allowCancel\" = false;
            \"allowChange\"= false;
            \"startNow\" = false;
            \"startTime\" = $time_plus_2min;
            \"created\"= $current_time;
            \"maxRecipients\"= 100;
            \"blockId\"= 0;
            \"totalAmount\"= $total_amount;
            \"initialUnlockPercentage\"= $initialUnlockPercentage;
            \"distributionType\"= variant { $distribute_mode };
            \"vestingType\"= variant { Standard };
            \"autoTransfer\"= false;
            \"tokenInfo\"= record {
                \"canisterId\"= \"$token_canister_id\";
                \"name\"= \"ICTO Test Token\";
                \"symbol\"= \"tICTO\";
                \"standard\"= \"ICRC1\";
                \"decimals\"= 8;
                \"fee\"= 10_000;
            };
            \"recipients\"= $recipients;
            \"owner\"= principal \"$owner_principal\"
        }
    )" | idl2json)
    echo "$result"
    echo "$result" | jq -r '.ok' | while read -r claimContractId; do
    echo "claimContractId ==> $claimContractId"
    # init the canister
    dfx canister call claim_contract init --network=$env;


    # users claims, loop through all users
    for user in claim_user1 claim_user2 claim_user3; do
        echo "==> $user claiming..."
        dfx identity use $user
        claim_result=$(dfx canister --network=$env call claim_contract claim | idl2json)
        echo "claim_result ==> $claim_result"
    done

}

deploy
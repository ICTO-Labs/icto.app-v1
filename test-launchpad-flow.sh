#!/bin/bash

env=$1
mode=$2
launchpad_id=$3
deploy(){

    echo "Starting deployment Launchpad flow $mode..."
    setup_env
    # deploy_frontend
    deploy_token_deployer
    create_identity_list
    deploy_purchase_token
    # deploy_sale_token 
    deploy_launchpad_manager
    create_launchpad
    # participate_launchpad
}

setup_env(){
    if [ "$mode" == "reset" ]; then
        echo "Resetting environment..."
        dfx stop
        dfx start --background --clean
    fi
    dfx ledger fabricate-cycles --canister launchpad #topup 10T cycles
    dfx identity use laking #use laking identity
}

deploy_frontend(){
    if [ "$mode" == "reset" ]; then
        echo "==> Deploying Frontend..."
        dfx deploy frontend --network=$env
    fi
}

deploy_token_deployer(){
    echo "==> Deploying Token Deployer..."
    dfx deploy token_deployer --network=$env
}

create_identity_list(){
    if [ "$mode" == "reset" ]; then
        echo "==> Creating Identity List..."
        dfx identity new launchpad_participant1
        dfx identity new launchpad_participant2
        dfx identity new launchpad_participant3
        dfx identity new launchpad_participant4
        dfx identity new launchpad_participant5
    fi
}

deploy_purchase_token(){
    if [ "$mode" == "reset" ]; then
        echo "==> Deploying Purchase Token (ICRC1)..."
        minting_account="$(dfx identity get-principal)"
        dfx deploy --network=$env --specified-id ryjl3-tyaaa-aaaaa-aaaba-cai icrc1_token --argument "(variant { Init =
            record {
                token_symbol = \"tICP\";
                token_name = \"Test ICP\";
                minting_account = record { owner = principal \"${minting_account}\" };
                transfer_fee = 10_000;
                metadata = vec {};
                initial_balances = vec { record { record { owner = principal \"${minting_account}\"; }; 100_000_000_000_000; }; };
                archive_options = record {
                    num_blocks_to_archive = 1000;
                    trigger_threshold = 2000;
                    controller_id = principal \"${minting_account}\";
                };
                feature_flags = opt record {
                    icrc2 = true;
                };
            }
        })"
    fi

    # Mint tokens for test participants
    if [ "$mode" == "reset" ]; then
        purchase_token_id=$(dfx canister --network=$env id icrc1_token)
        for i in {1..5}; do
            participant_principal="$(dfx identity get-principal --identity launchpad_participant$i)"
            echo "==> Minting tokens for $participant_principal..."
            dfx canister --network=$env call $purchase_token_id icrc1_transfer "(
                record {
                    to = record { owner = principal \"$participant_principal\"; subaccount = null };
                    fee = null;
                    memo = null;
                    from_subaccount = null;
                created_at_time = null;
                amount = 1_000_000_000_000
            }
        )"
        done
    fi
}

deploy_sale_token(){
    echo "==> Deploying Sale Token (ICRC1)...Skipped"
}

deploy_launchpad_manager(){
    echo "==> Deploying Launchpad Manager..."
    dfx deploy launchpad --network=$env
}

create_launchpad(){
    if [ "$launchpad_id" == "" ]; then
        to_nano() {
            echo $(($1 * 1000000000))
        }
        echo "==> Creating Launchpad..."
        current_time=$(date +%s)
        current_time_nano=$(to_nano $current_time)
        end_time=$(to_nano $((current_time + 120))) # 2 minutes from now
        claim_time=$(to_nano $((current_time + 120))) # 0 minutes after end
        listing_time=$(to_nano $((current_time + 120 + 300 + 300))) # 5 minutes after claim

        purchase_token_id=$(dfx canister --network=$env id icrc1_token)
        # sale_token_id=$(dfx canister --network=$env id sale_token)
        owner_principal="$(dfx identity get-principal)"

        result=$(dfx canister --network=$env call launchpad createLaunchpad "(
            record {
                projectInfo = record {
                    name = \"Test Launchpad\";
                    description = \"Test Launchpad Description\";
                    isAudited = false;
                    isVerified = false;
                    links = opt vec {};
                    logo = \"test_logo\";
                    banner = opt \"test_banner\";
                    metadata = opt vec {};
                };
                timeline = record {
                    createdTime = $current_time_nano;
                    startTime = $current_time_nano;
                    endTime = $end_time;
                    claimTime = $claim_time;
                    listingTime = $listing_time;
                };
                purchaseToken = record {
                    name = \"Test ICP\";
                    symbol = \"tICP\";
                    decimals = 8;
                    transferFee = 10_000;
                    metadata = null;
                    logo = \"test_logo\";
                    canisterId = \"$purchase_token_id\";
                };
                saleToken = record {
                    name = \"Sale Token\";
                    symbol = \"SALE\";
                    decimals = 8;
                    transferFee = 10000;
                    metadata = null;
                    logo = \"test_logo\";
                    canisterId = \"\";
                };
                launchParams = record {
                    sellAmount = 1_000_000_000_000;
                    softCap = 5000_000_000_000;
                    hardCap = 10000_000_000_000;
                    minimumAmount = 100_000_000;
                    maximumAmount = 300_000_000_000;
                };
                distribution = record {
                    fairlaunch = record {
                        title = \"Fair Launch\";
                        description = \"Fair Launch Distribution\";
                        vesting = record {
                            cliff = 0;
                            duration = 0;
                            unlockFrequency = 0;
                            initialUnlockPercentage = 0;
                        };
                        total = 250000000000;
                    };
                    liquidity = record {
                        title = \"Liquidity Pool\";
                        description = \"Liquidity Pool Distribution\";
                        vesting = record {
                            cliff = 0;
                            duration = 0;
                            unlockFrequency = 0;
                            initialUnlockPercentage = 0;
                        };
                        total = 200000000000;
                    };
                    team = record {
                        title = \"Team Allocation\";
                        description = \"Team Token Distribution\";
                        vesting = record {
                            cliff = 15552000;
                            duration = 31104000;
                            unlockFrequency = 2592000;
                            initialUnlockPercentage = 0;
                        };
                        total = 10000000000;
                        recipients = vec {
                            record {
                                amount = 5000000000;
                                address = \"$owner_principal\";
                                note = opt \"Core Team\";
                            };
                            record {
                                amount = 5000000000;
                                address = \"$owner_principal\";
                                note = opt \"Advisors\";
                            };
                        };
                    };
                    others = vec {
                        record {
                            title = \"Marketing\";
                            description = \"Marketing Distribution\";
                            vesting = record {
                                cliff = 2592000;
                                duration = 15552000;
                                unlockFrequency = 2592000;
                                initialUnlockPercentage = 0;
                            };
                            total = 2000000000;
                            recipients = vec {
                                record {
                                    amount = 2000000000;
                                    address = \"$owner_principal\";
                                    note = opt \"Marketing Fund\";
                                };
                            };
                        };
                        record {
                            title = \"Airdrop\";
                            description = \"Community Airdrop\";
                            vesting = record {
                                cliff = 0;
                                duration = 7776000;
                                unlockFrequency = 2592000;
                                initialUnlockPercentage = 0;
                            };
                            total = 1000000000;
                            recipients = vec {
                                record {
                                    amount = 1000000000;
                                    address = \"$owner_principal\";
                                    note = opt \"Airdrop Fund\";
                                };
                            };
                        };
                    };
                };
                creator = \"$owner_principal\";
                affiliate = 1;
                fee = 3;
                blockId = 0;
                restrictedArea = null;
            }
        )")

        launchpad_id=$(echo "$result" | awk -F'"' '{print $2}')
        echo "Launchpad ID: $launchpad_id"
        echo "Launchpad url: http://localhost:5173/launchpad/$launchpad_id"

        #participate_launchpad
        participate_launchpad "$launchpad_id"
    else
        participate_launchpad "$launchpad_id"
    fi
}

participate_launchpad(){
    launchpad_id=$1
    echo "==> Participating in Launchpad $launchpad_id..."
    purchase_token_id=$(dfx canister --network=$env id icrc1_token)

    # Define participation amounts for each user
    declare -A amounts
    base_amount=100000000000
    increment=50000000000
    for i in {1..5}; do
        echo "==> Participating with $i..."
        participant="launchpad_participant$i"
        current_participant=$(dfx identity get-principal --identity $participant)
        amount=$(( $base_amount + ($i-1) * $increment ))

        echo "==> $current_participant participating with ${amount} tokens"
        dfx identity use $participant
        
        # Approve tokens first
        echo "==> Approving tokens..."
        # dfx canister --network=$env call $purchase_token_id icrc2_approve "(
        #     record {
        #         amount = ${amount};
        #         spender = record { owner = principal \"$launchpad_id\"; subaccount = null };
        #         expires_at = null;
        #         expected_allowance = null;
        #         memo = null;
        #         fee = opt 10000;
        #         created_at_time = null;
        #         from_subaccount = null;
        #     }
        # )"

        fee_buffer=50000  # Buffer for fees
        approve_amount=$((${amount}+$fee_buffer))
        dfx canister --network=$env call $purchase_token_id icrc2_approve "(record{amount=${approve_amount};created_at_time=null;expected_allowance=null;expires_at=null;fee=opt 10_000;from_subaccount=null;memo=null;spender=record {owner= principal \"$launchpad_id\";subaccount=null;}})"


        # Commit to launchpad
        echo "==> Committing to Launchpad..."
        commit_result=$(dfx canister --network=$env call $launchpad_id commit "(${amount}, null)")
        echo "Commit result: $commit_result"
        echo "==> Committed to Launchpad, next participant..."
        # Wait for 2 second before next participant
        sleep 2
    done
}

# Run deployment
deploy
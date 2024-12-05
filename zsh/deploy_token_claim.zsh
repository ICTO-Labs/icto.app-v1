current_time=$(date '+%s') # Get current time with microsecond
time_plus_2min=$((current_time + 120)) # Add 2 minutes

dfx deploy "claim_contract" --argument "(
    record {
        \"title\" = \"Claim Test Tokens for Test Phase 2\";
        \"description\" = \"You can claim tICP (Test ICP) to paticipate in Launchpad. Once you have your tICP tokens, you can connect your wallet to Launchpad and start participating in the platform. This contract is protected by BlockID to ensure the integrity of the distribution process.\";
        \"durationTime\" = 86400;
        \"durationUnit\" = 30;
        \"cliffTime\" = 86400;
        \"cliffUnit\" = 3;
        \"unlockSchedule\" = 86400;
        \"allowCancel\" = false;
        \"allowChange\"= false;
        \"startNow\" = false;
        \"startTime\" = $time_plus_2min;
        \"created\"= $current_time;
        \"maxRecipients\"= 100;
        \"blockId\"= 0;
        \"totalAmount\"= 10000000000000;
        \"initialUnlockPercentage\"= 40;
        \"distributionType\"= variant { Whitelist };
        \"vestingType\"= variant { Standard };
        \"autoTransfer\"= false;
        \"tokenInfo\"= record {
            \"canisterId\"= \"ajuq4-ruaaa-aaaaa-qaaga-cai\";
            \"name\"= \"Test ICP\";
            \"symbol\"= \"tICP\";
            \"standard\"= \"ICRC2\";
            \"decimals\"= 8;
            \"fee\"= 10_000;
        };
        \"recipients\"= opt vec { record { \"address\"= \"lekqg-fvb6g-4kubt-oqgzu-rd5r7-muoce-kppfz-aaem3-abfaj-cxq7a-dqe\"; \"amount\"= 10_000_000_000; \"note\"= opt \"Developer\"; }; record { \"address\"= \"v57dj-hev4p-lsvdl-dckvv-zdcvg-ln2sb-tfqba-nzb4g-iddrv-4rsq3-mae\"; \"amount\"= 15_900_000_000; \"note\"= opt \"Marketing\"; }; };
        \"owner\"= principal \"lekqg-fvb6g-4kubt-oqgzu-rd5r7-muoce-kppfz-aaem3-abfaj-cxq7a-dqe\"
    }
)" --mode reinstall # --network ic

# init the canister
dfx canister call claim_contract init;

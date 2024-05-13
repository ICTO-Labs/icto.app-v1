
dfx deploy "claim_contract" --argument "(
    record {
        \"title\" = \"Team payment #Q3\";
        \"description\" = \"Team payment for Q3\";
        \"durationTime\" = 60;
        \"durationUnit\" = 60;
        \"cliffTime\" = 60;
        \"cliffUnit\" = 5;
        \"unlockSchedule\" = 60;
        \"canCancel\" = \"neither\";
        \"canChange\"= \"neither\";
        \"canView\" = \"neither\";
        \"startNow\" = true;
        \"startTime\" = 1715571534853;
        \"created\"= 1715571534853;
        \"tokenId\"= record {
            \"canisterId\"= \"ryjl3-tyaaa-aaaaa-aaaba-cai\";
            \"name\"= \"Internet Computer\";
            \"symbol\"= \"ICP\";
            \"name\"= \"ICRC1\";
            \"decimals\"= 8;
        };
        \"tokenName\"= \"Internet Computer\";
        \"tokenSymbol\"= \"ICP\";
        \"tokenStandard\"= \"ICRC1\";
        \"totalAmount\"= 259;
        \"unlockedAmount\"= 0;
        \"recipients\"= vec { record { \"address\"= \"lekqg-fvb6g-4kubt-oqgzu-rd5r7-muoce-kppfz-aaem3-abfaj-cxq7a-dqe\"; \"amount\"= 100; \"note\"= opt \"Developer\"; }; record { \"address\"= \"v57dj-hev4p-lsvdl-dckvv-zdcvg-ln2sb-tfqba-nzb4g-iddrv-4rsq3-mae\"; \"amount\"= 159; \"note\"= opt \"Marketing\"; }; };
        \"owner\"= principal \"lekqg-fvb6g-4kubt-oqgzu-rd5r7-muoce-kppfz-aaem3-abfaj-cxq7a-dqe\"
    }
)"

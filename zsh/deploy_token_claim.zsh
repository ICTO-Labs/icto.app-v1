
dfx deploy "claim_contract" --argument "(
    record {
        \"title\" = \"Team payment #Q4\";
        \"description\" = \"Team payment for Q4\";
        \"durationTime\" = 60;
        \"durationUnit\" = 0;
        \"cliffTime\" = 60;
        \"cliffUnit\" = 5;
        \"unlockSchedule\" = 60;
        \"canCancel\" = \"neither\";
        \"canChange\"= \"neither\";
        \"canView\" = \"neither\";
        \"startNow\" = true;
        \"startTime\" = 1715571534853;
        \"created\"= 1715571534853;
        \"maxRecipients\"= 100;
        \"totalAmount\"= 10000000000000;
        \"distributionType\"= \"FirstComeFirstServed\";
        \"tokenInfo\"= record {
            \"canisterId\"= \"ryjl3-tyaaa-aaaaa-aaaba-cai\";
            \"name\"= \"Internet Computer\";
            \"symbol\"= \"ICP\";
            \"standard\"= \"ICRC1\";
            \"decimals\"= 8;
            \"fee\"= 10000;
        };
        \"recipients\"= opt vec { record { \"address\"= \"lekqg-fvb6g-4kubt-oqgzu-rd5r7-muoce-kppfz-aaem3-abfaj-cxq7a-dqe\"; \"amount\"= 10_000_000_000; \"note\"= opt \"Developer\"; }; record { \"address\"= \"v57dj-hev4p-lsvdl-dckvv-zdcvg-ln2sb-tfqba-nzb4g-iddrv-4rsq3-mae\"; \"amount\"= 15_900_000_000; \"note\"= opt \"Marketing\"; }; };
        \"owner\"= principal \"lekqg-fvb6g-4kubt-oqgzu-rd5r7-muoce-kppfz-aaem3-abfaj-cxq7a-dqe\"
    }
)" --mode reinstall

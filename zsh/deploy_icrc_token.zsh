#!/usr/bin/env bash
export MINTER=$(dfx --identity anonymous identity get-principal)
export DEFAULT=$(dfx identity get-principal)
dfx deploy icrc1_token --argument "(variant { Init =
record {
        token_symbol = \"TICP\";
        token_name = \"Test ICP\";
        minting_account = record { owner = principal \"${MINTER}\" };
        transfer_fee = 10_000;
        metadata = vec {};
        initial_balances = vec { record { record { owner = principal \"${DEFAULT}\"; }; 100_000_000_000_000; }; };
        archive_options = record {
            num_blocks_to_archive = 1000;
            trigger_threshold = 2000;
            controller_id = principal \"${MINTER}\";
        };
    }
})"
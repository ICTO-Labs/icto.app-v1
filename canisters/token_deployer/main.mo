import A "mo:base/AssocList";
import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Bool "mo:base/Bool";
import Buffer "mo:base/Buffer";
import Cycles "mo:base/ExperimentalCycles";
import Error "mo:base/Error";
import Char "mo:base/Char";
import Hash "mo:base/Hash";
import HashMap "mo:base/HashMap";
import Int "mo:base/Int";
import Int16 "mo:base/Int16";
import Int8 "mo:base/Int8";
import Iter "mo:base/Iter";
import List "mo:base/List";
import Nat "mo:base/Nat";
import Nat8 "mo:base/Nat8";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Option "mo:base/Option";
import Prelude "mo:base/Prelude";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Debug "mo:base/Debug";
import Text "mo:base/Text";
import Time "mo:base/Time";
import Trie "mo:base/Trie";
import Trie2D "mo:base/Trie";
import SNSWasm "./SNSWasm";
import Ledger "./Ledger";
import IC "./IC";
import ICRCLedger "./ICRCLedger";
import Hex "./Hex";

actor class Self() = this {
    private func deployer() : Principal = Principal.fromActor(this);
    private stable var _tokens : Trie.Trie<Text, Token> = Trie.empty(); //mapping of token_canister_id -> Token details
    private stable var _logos : Trie.Trie<Text, Text> = Trie.empty(); //mapping of token_canister_id -> base64
    private stable var _owners : Trie.Trie<Text, Text> = Trie.empty(); //mapping  token_canister_id -> owner principal id
    private stable var _admins : [Text] = ["lekqg-fvb6g-4kubt-oqgzu-rd5r7-muoce-kppfz-aaem3-abfaj-cxq7a-dqe"];

    private stable var CREATION_FEE : Nat = 1*100_000_000;//E8S in ICP

    private stable var MIN_CYCLES_IN_DEPLOYER: Nat = 2_000_000_000_000;//Minimum cycles in deployer
    private stable var CYCLES_FOR_INSTALL: Nat = 300_000_000_000;//1T 1_000_000_000_000, 0.3T, initial cycles for install
    private stable var CYCLES_FOR_ARCHIVE: Nat64 = 300_000_000_000;//
    private stable var SNS_WASM_VERSION : Blob = "af8fc1469e553ac90f704521a97a1e3545c2b68049b4618a6549171b4ea4fba8";//lastest version hash
    private stable var SNS_WASM : Blob = "";//lastest wasm file
    //IC Services
    private let ic : IC.Self = actor ("aaaaa-aa");
    private let snsWasm : SNSWasm.Self = actor ("qaa6y-5yaaa-aaaaa-aaafa-cai");
    private let icrcLedger : ICRCLedger.Self = actor ("ryjl3-tyaaa-aaaaa-aaaba-cai");//For fee payment


    //Types
    public type Token = {
        name : Text;
        symbol : Text;
        canister : Text;
        wasm_version: Text;
        logo : Text;
    };
    type ReqArgsIncluded = {
        token_symbol : Text; // max 7 chars
        transfer_fee : Nat;
        token_name : Text;
        minting_account : Ledger.Account;
        initial_balances : [(Ledger.Account, Nat)];
        fee_collector_account : ?Ledger.Account;
    };
    public type InitArgsRequested = ReqArgsIncluded and {
        logo: Text;
    };
    public type InitArgsSimplified = InitArgsRequested and {
        decimals : ?Nat8; // fix to 8
        maximum_number_of_accounts : ?Nat64; //28_000_000
        accounts_overflow_trim_quantity : ?Nat64; // 100_000
        feature_flags : ?{ icrc2 : Bool };
        metadata : [(Text, Ledger.MetadataValue)]; // needs to be fixed
    };
    type ArchiveOptions = {
        num_blocks_to_archive : Nat64;
        max_transactions_per_response : ?Nat64;
        trigger_threshold : Nat64;
        max_message_size_bytes : ?Nat64;
        cycles_for_archive_creation : ?Nat64;
        node_max_memory_size_bytes : ?Nat64;
        controller_id : Principal;
        more_controller_ids : ?[Principal];
    };
    //Utility Functions
    private func key(x : Nat32) : Trie.Key<Nat32> {
        return { hash = x; key = x };
    };

    private func keyT(x : Text) : Trie.Key<Text> {
        return { hash = Text.hash(x); key = x };
    };

    private func textToNat(txt : Text) : Nat {
        assert (txt.size() > 0);
        let chars = txt.chars();

        var num : Nat = 0;
        for (v in chars) {
            let charToNum = Nat32.toNat(Char.toNat32(v) -48);
            assert (charToNum >= 0 and charToNum <= 9);
            num := num * 10 + charToNum;
        };

        return num;
    };

    private func _isAdmin(p : Text) : (Bool) {
        for (i in _admins.vals()) {
            if (i == p) {
                return true;
            };
        };
        return false;
    };
    private func create_canister() : async Principal {
        try {
            // Create canister
            Cycles.add(CYCLES_FOR_INSTALL);
            let { canister_id } = await ic.create_canister({
                settings = ?{
                    controllers = ?[deployer()];//
                    freezing_threshold = ?9_331_200; // 108 days
                    memory_allocation = null;
                    compute_allocation = null;
                    reserved_cycles_limit = null;
                };
                sender_canister_version = null});
            canister_id;
        } catch (e) {
            return Debug.trap("Canister creation failed " # debug_show Error.message(e));
        };
    };

    //Deployer withdraw ownership from token canister and transfer to token owner
    private func transfer_ownership(canister_id : Principal, to: Principal) : async () {
        await (
            ic.update_settings({
                canister_id = canister_id;
                settings = {
                    controllers = ?[to];
                    compute_allocation = null;
                    memory_allocation = null;
                    freezing_threshold = ?9_331_200;
                    reserved_cycles_limit = null;
                };
                sender_canister_version = null;
            })
        );
    };

    public shared({caller}) func get_lastest_version() : async Result.Result<Text, Text>{
        // assert (_isAdmin(Principal.toText(caller)));
        let res = await snsWasm.get_latest_sns_version_pretty(null);
        for ((k) in res.vals()) {
            if (k.0 == "Ledger") {
                let decode = Hex.decode(k.1);
                switch (decode) {
                    case (#ok(version)) {
                        let _lastest_version: Blob = Blob.fromArray(version);
                        if(Blob.equal(SNS_WASM_VERSION, _lastest_version) == false){
                            SNS_WASM_VERSION := _lastest_version;
                            let _saved = await save_wasm_version(SNS_WASM_VERSION);
                            return #ok("New version saved" # debug_show(_saved));
                        }else{
                            return #err("No new version found");
                        }
                    };
                    case (#err(err)) {
                        return #err("Error decoding version");
                    };
                };
            };
        };
        #ok("No version found");
    };

    //Save wasm version to stable memory
    private func save_wasm_version(version : Blob) : async Result.Result<Text, Text>{
        let wasm_resp = await snsWasm.get_wasm({ hash = SNS_WASM_VERSION });
        let ?wasm_ver = wasm_resp.wasm else return #err("No blessed wasm available");
        SNS_WASM := wasm_ver.wasm;
        return #ok("Wasm saved successfully");
    };

    public shared ({ caller }) func install(req_args : InitArgsRequested) : async Result.Result<Principal, Text> {

        if (Text.size(req_args.token_symbol) > 8) return #err("Token symbol too long, max 8 characters");
        if (Text.size(req_args.token_name) > 32) return #err("Token name too long, max 32 characters");
        if (Text.size(req_args.logo) < 100) return #err("Logo too small");
        if (Text.size(req_args.logo) > 30_000) return #err("Max logo size is 20 KB");

        let init_args : InitArgsSimplified = {
            req_args with
            decimals = ?8 : ?Nat8;
            maximum_number_of_accounts = ?28_000_000 : ?Nat64;
            accounts_overflow_trim_quantity = ?100_000 : ?Nat64;
            feature_flags = ?{ icrc2 = true };
            metadata= [("icrc1:logo", #Text(req_args.logo))];
        };

        // // Get latest wasm
        // let wasm_resp = await snsWasm.get_wasm({ hash = SNS_WASM_VERSION });
        // let ?wasm_ver = wasm_resp.wasm else return #err("No blessed wasm available");
        // let wasm = wasm_ver.wasm;

        // Make ledger initial arguments
        // Ledgers won't show some of its options, so we will not allow them to be set, which will guarantee they are good.
        // Settings same as SNS ledgers - https://github.com/dfinity/ic/blob/8b2d48ca3571d5c09834cba4f90aa2153d88fbe8/rs/sns/init/src/lib.rs#L662

        let archive_options : ArchiveOptions = {
            num_blocks_to_archive = 1000; /// The number of blocks to archive when trigger threshold is exceeded
            trigger_threshold = 2000; /// The number of blocks which, when exceeded, will trigger an archiving operation.
            node_max_memory_size_bytes = ?(1024 * 1024 * 1024);
            max_message_size_bytes = ?(128 * 1024);
            cycles_for_archive_creation = ?CYCLES_FOR_ARCHIVE;
            controller_id = Principal.fromActor(this);
            max_transactions_per_response = null;
            more_controller_ids = ?[Principal.fromActor(this)];
        };

        let args : Ledger.LedgerArg = #Init({
            init_args with
            archive_options;
            max_memo_length = ?80 : ?Nat16;
        });

        let upgradearg : Ledger.UpgradeArgs = {
            token_symbol = ?req_args.token_symbol;
            transfer_fee = ?req_args.transfer_fee;
            metadata = ?init_args.metadata;
            maximum_number_of_accounts = init_args.maximum_number_of_accounts;
            accounts_overflow_trim_quantity = init_args.accounts_overflow_trim_quantity;
            max_memo_length = ?80;
            token_name = ?req_args.token_name;
            feature_flags = init_args.feature_flags;
            change_fee_collector = ?(switch(init_args.fee_collector_account) {
                case (?acc) #SetTo(acc);
                case (null) #Unset;
            });
        };

        // Check if this canister has enough cycles
        let balance = Cycles.balance();
        if (balance < CYCLES_FOR_INSTALL + MIN_CYCLES_IN_DEPLOYER) return #err("Not enough cycles in deployer, balance: "# debug_show(balance) #"T");

        if (not _isAdmin(Principal.toText(caller))) switch (await icrcLedger.icrc2_transfer_from({ from = { owner = caller; subaccount = null }; spender_subaccount = null; to = { owner = deployer(); subaccount = null }; fee = null; memo = null; from_subaccount = null; created_at_time = null; amount = CREATION_FEE })) {
            case (#Ok(_)) ();
            case (#Err(e)) return #err("Payment error: " # debug_show(e));
        };

        let canister_id = await create_canister();

        // Install code
        try {
            await ic.install_code({
                arg = to_candid (args);
                wasm_module = SNS_WASM;
                mode = #install;
                canister_id;
                sender_canister_version = null;
            });
        } catch (e) {
            return #err("Canister installation failed " # debug_show (Error.message(e)));
        };

        //Transfer ownership
        try{
            await transfer_ownership(canister_id, caller);
        }catch(e){
            return #err("Can not transfer ownership " # debug_show (Error.message(e)));
        };

        let _version = Hex.encode(Blob.toArray(SNS_WASM_VERSION));
        _tokens := Trie.put(
            _tokens,
            keyT(Principal.toText(canister_id)),
            Text.equal,
            {
                name = req_args.token_name;
                symbol = req_args.token_symbol;
                canister = Principal.toText(canister_id);
                wasm_version = _version;
                logo = req_args.logo;
            },
        ).0;
        _owners := Trie.put(_owners, keyT(Principal.toText(canister_id)), Text.equal, Principal.toText(caller)).0;

        #ok(canister_id);

    };
    //Get deployer Cycles balance  
    public query func cycleBalance() : async Nat {
        Cycles.balance();
    };
    //Get current SNS Wasm version  
    public query func getCurrentWasmVersion() : async Text {
        Hex.encode(Blob.toArray(SNS_WASM_VERSION));
    };
    //Get deployer ICP balance
    public shared ({ caller }) func balance() : async Nat {
        await icrcLedger.icrc1_balance_of({ owner = deployer(); subaccount = null });
    };

    //Update Initial cycles for new token canister
    public shared ({ caller }) func updateInitCycles(i : Nat) : async () {
        assert (_isAdmin(Principal.toText(caller)));
        CYCLES_FOR_INSTALL := i;
    };
    //Update Initial cycles for new token canister
    public shared ({ caller }) func updateMinCycles(i : Nat) : async () {
        assert (_isAdmin(Principal.toText(caller)));
        MIN_CYCLES_IN_DEPLOYER := i;
    };
    //Update Creation Fee for new token
    public shared ({ caller }) func updateCreationFee(i : Nat) : async () {
        assert (_isAdmin(Principal.toText(caller)));
        CREATION_FEE := i;
    };
    public shared ({ caller }) func addAdmin(p : Text) : async () {
        assert (_isAdmin(Principal.toText(caller)));
        var b : Buffer.Buffer<Text> = Buffer.Buffer<Text>(0);
        for (i in _admins.vals()) {
            if (p != i) {
                b.add(i);
            };
        };
        b.add(p);
        _admins := Buffer.toArray(b);
    };

    public shared ({ caller }) func removeAdmin(p : Text) : async () {
        assert (_isAdmin(Principal.toText(caller)));
        var b : Buffer.Buffer<Text> = Buffer.Buffer<Text>(0);
        for (i in _admins.vals()) {
            if (p != i) {
                b.add(i);
            };
        };
        _admins := Buffer.toArray(b);
    };

    public query func getAllAdmins() : async ([Text]) {
        return _admins;
    };

    //Internal Functions
    //
    private func _isOwner(p : Principal, canister_id : Text) : async (Bool) {
        for ((i, v) in Trie.iter(_owners)) {
            if (canister_id == i and p == Principal.fromText(v)) {
                return true;
            };
        };
        return false;
    };
    public query func getOwner(canister_id : Text) : async (?Text) {
        var owner : ?Text = Trie.find(_owners, keyT(canister_id), Text.equal);
        return owner;
    };

    public query func getUserTotalTokens(uid : Text) : async (Nat) {
        var size = 0;
        for ((i, v) in Trie.iter(_owners)) {
            if (v == uid) {
                size := size + 1;
            };
        };
        return size;
    };

    public query func getUserTokens(uid : Text, _page : Nat) : async ([Token]) {
        var lower : Nat = _page * 9;
        var upper : Nat = lower + 9;
        var b : Buffer.Buffer<Token> = Buffer.Buffer<Token>(0);
        for ((i, v) in Trie.iter(_owners)) {
            if (v == uid) {
                switch (Trie.find(_tokens, keyT(i), Text.equal)) {
                    case (?t) {
                        b.add(t);
                    };
                    case _ {};
                };
            };
        };
        let arr = Buffer.toArray(b);
        b := Buffer.Buffer<Token>(0);
        let size = arr.size();
        if (upper > size) {
            upper := size;
        };
        while (lower < upper) {
            b.add(arr[lower]);
            lower := lower + 1;
        };
        return Buffer.toArray(b);
    };

    public query func getTokens(_page : Nat) : async ([Token]) {
        var lower : Nat = _page * 9;
        var upper : Nat = lower + 9;
        var b : Buffer.Buffer<Token> = Buffer.Buffer<Token>(0);
        for ((i, v) in Trie.iter(_owners)) {
            switch (Trie.find(_tokens, keyT(i), Text.equal)) {
                case (?t) {
                    b.add(t);
                };
                case _ {};
            };
        };
        let arr = Buffer.toArray(b);
        b := Buffer.Buffer<Token>(0);
        let size = arr.size();
        if (upper > size) {
            upper := size;
        };
        while (lower < upper) {
            b.add(arr[lower]);
            lower := lower + 1;
        };
        return Buffer.toArray(b);
    };

    public query func getTotalTokens() : async (Nat) {
        return Trie.size(_tokens);
    };

    //Queries
    public query func getTokenDetails(canister_id : Text) : async (?Token) {
        switch (Trie.find(_tokens, keyT(canister_id), Text.equal)) {
            case (?t) {
                return ?t;
            };
            case _ {
                return null;
            };
        };
    };

}
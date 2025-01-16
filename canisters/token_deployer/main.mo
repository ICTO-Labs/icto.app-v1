import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Bool "mo:base/Bool";
import Buffer "mo:base/Buffer";
import Cycles "mo:base/ExperimentalCycles";
import Error "mo:base/Error";
import Char "mo:base/Char";
import Int "mo:base/Int";
import Nat "mo:base/Nat";
import Nat8 "mo:base/Nat8";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Debug "mo:base/Debug";
import Text "mo:base/Text";
import Time "mo:base/Time";
import Trie "mo:base/Trie";
import SNSWasm "./SNSWasm";
import Ledger "./Ledger";
import IC "./IC";
import ICRCLedger "./ICRCLedger";
import Hex "./Hex";
import Prim "mo:⛔";
import Timer "mo:base/Timer";
import Option "mo:base/Option";
actor class Self() = this {
    private func deployer() : Principal = Principal.fromActor(this);
    private stable var _tokens : Trie.Trie<Text, TokenInfo> = Trie.empty(); //mapping of token_canister_id -> Token details
    private stable var _logos : Trie.Trie<Text, Text> = Trie.empty(); //mapping of token_canister_id -> base64
    private stable var _owners : Trie.Trie<Text, Text> = Trie.empty(); //mapping  token_canister_id -> owner principal id
    private stable var _pendingCanisters : Trie.Trie<Text, TokenInfoFull> = Trie.empty(); //List of canisters that are pending to be deployed: owner > token info
    private stable var _admins : [Text] = [];
    private stable var timerId : Nat = 0;
    private stable var CREATION_FEE : Nat = 1*100_000_000;//E8S in ICP
    private stable var _supportedTokens: [Text] = ["ICRC-1"];
    private stable var ALLOW_CUSTOM_TOKEN: Bool = false;
    private stable var MIN_CYCLES_IN_DEPLOYER: Nat = 8_000_000_000_000;//Minimum cycles in deployer
    private stable var CYCLES_FOR_INSTALL: Nat = 4_000_000_000_000;//4T , initial cycles for install
    private stable var CYCLES_FOR_ARCHIVE: Nat64 = 2_000_000_000_000;//
    private stable var SNS_WASM_VERSION : Blob = "af8fc1469e553ac90f704521a97a1e3545c2b68049b4618a6549171b4ea4fba8";//lastest version hash
    private stable var SNS_WASM : Blob = "";//lastest wasm file
    private stable var WHITE_LIST_CANISTERS: [Principal] = [];//list of canisters that can deploy token
    private stable var PAGE_SIZE: Nat = 12;//page size
    private stable var CYCLE_OPPS_BLACKHOLE_ID: Principal = Principal.fromText("5vdms-kaaaa-aaaap-aa3uq-cai");//CycleOpps Blackhole ID
    //IC Services
    private let ic : IC.Self = actor ("aaaaa-aa");
    private let snsWasm : SNSWasm.Self = actor ("qaa6y-5yaaa-aaaaa-aaafa-cai");
    private let icrcLedger : ICRCLedger.Self = actor ("ryjl3-tyaaa-aaaaa-aaaba-cai");//For fee payment
    private let wasmChunks : Buffer.Buffer<Blob> = Buffer.Buffer(0);

    //Types
    public type Token = {
        name : Text;
        symbol : Text;
        canister : Text;
        wasm_version: Text;
        logo : Text;
    };
    public type LedgerMeta = {
        symbol : Text;
        name : Text;
        decimals : Nat;
        fee : Nat;
        logo : Text;
    };
    //Additional data for token
    public type TokenData = {
        launchpadId : ?Principal;
        description: ?Text;
        links: ?[Text];
        lockContracts: ?[(Text, Principal)]; //(provider, canisterId), eg: (Sneed, qaa6y-5yaaa-aaaaa-aaafa-cai)
        tokenProvider: ?Text;//ICTO, SNS, etc
        enableCycleOpps: Bool;
    };
    public type TokenInfo = TokenData and {
        name : Text;
        symbol : Text;
        canisterId : Principal;
        moduleHash: Text;
        // logo : Text;
        owner : Principal;
        createdAt : Int;
        updatedAt: Int;
    };

    public type TokenInfoFull = TokenData and {
        name : Text;
        symbol : Text;
        canisterId : Principal;
        moduleHash: Text;
        logo : Text;
        owner : Principal;
        createdAt : Int;
        updatedAt: Int;
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

    //Get remote canister id from imported canister
    private func getRemoteCanisterId(canister: Text) : async Principal {
        switch(canister){
            case ("launchpad") {
                return Principal.fromText("xzpva-miaaa-aaaap-qhi7q-cai");
            };
            case _ {
                return Principal.fromText("qaa6y-5yaaa-aaaaa-aaafa-cai");
            };
        };
    };
    private func _isAdmin(p : Text) : (Bool) {
        Prim.isController(Principal.fromText(p)) or 
        Array.find<Text>(_admins, func(admin : Text) = admin == p) != null
    };
    private func create_canister() : async Principal {
        try {
            // Create canister
            Cycles.add<system>(CYCLES_FOR_INSTALL);
            let { canister_id } = await ic.create_canister({
                settings = ?{
                    controllers = ?[deployer()];//Blackhole
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
    private func transfer_ownership(canister_id : Principal, to: Principal, enableCycleOpps: Bool) : async () {
        let _controllers = if(enableCycleOpps) [CYCLE_OPPS_BLACKHOLE_ID, to] else [to];
        await (
            ic.update_settings({
                canister_id = canister_id;
                settings = {
                    controllers = ?_controllers;
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
        assert (_isAdmin(Principal.toText(caller)));
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
                        return #err("Error decoding version: " # debug_show(err));
                    };
                };
            };
        };
        #ok("No version found");
    };

    //Save wasm version to stable memory
    private func save_wasm_version(version : Blob) : async Result.Result<Text, Text>{
        let wasm_resp = await snsWasm.get_wasm({ hash = version });
        let ?wasm_ver = wasm_resp.wasm else return #err("No blessed wasm available");
        SNS_WASM := wasm_ver.wasm;
        return #ok("Wasm saved successfully");
    };

    public shared ({ caller }) func install(req_args : InitArgsRequested, target_canister: ?Principal, tokenData: TokenData) : async Result.Result<Principal, Text> {

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

        let upgradeArgs : Ledger.UpgradeArgs = {
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
            change_archive_options = ?archive_options;
        };

        // Check if this canister has enough cycles
        let balance = Cycles.balance();
        if (balance < CYCLES_FOR_INSTALL + MIN_CYCLES_IN_DEPLOYER) return #err("Not enough cycles in deployer, balance: "# debug_show(balance) #"T");
        //Check if caller is in white list or is admin > not need to pay creation fee
        let is_admin = _isAdmin(Principal.toText(caller));
        let is_in_white_list = Array.find<Principal>(WHITE_LIST_CANISTERS, func(x) { x == caller }) != null;
        if (not is_admin and not is_in_white_list) {
            switch (await icrcLedger.icrc2_transfer_from({ from = { owner = caller; subaccount = null }; spender_subaccount = null; to = { owner = deployer(); subaccount = null }; fee = null; memo = null; from_subaccount = null; created_at_time = null; amount = CREATION_FEE })) {
                case (#Ok(_)) ();
                case (#Err(e)) return #err("Payment error: " # debug_show(e));
            };
        };

        let canister_id = switch(target_canister) {
            case (?canister) canister;
            case (null) await create_canister();
        };
        //Save pending canister
        _pendingCanisters := Trie.put(_pendingCanisters, keyT(Principal.toText(caller)), Text.equal, {
            name = req_args.token_name;
            symbol = req_args.token_symbol;
            canisterId = canister_id;
            moduleHash = Hex.encode(Blob.toArray(SNS_WASM_VERSION));
            logo = req_args.logo;
            owner = caller;
            createdAt = Time.now();
            updatedAt = Time.now();
            description = tokenData.description;
            links = tokenData.links;
            lockContracts = tokenData.lockContracts;
            tokenProvider = ?"ICTO";
            launchpadId = tokenData.launchpadId;
            enableCycleOpps = tokenData.enableCycleOpps;
        }).0;
        // Install code
        try {
            let _args = if(target_canister != null) #Upgrade(?upgradeArgs) else args;
            Debug.print("args: " # debug_show(target_canister) # debug_show(_args));
            await ic.install_code({
                arg = to_candid (_args);
                wasm_module = SNS_WASM;
                mode = if(target_canister != null) #upgrade(null) else #install;
                canister_id = canister_id;
                sender_canister_version = null;
            });
        } catch (e) {
            return #err("Canister installation failed " # debug_show (Error.message(e)));
        };

        //Transfer ownership
        try{
            await transfer_ownership(canister_id, caller, tokenData.enableCycleOpps);
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
                canisterId = canister_id;
                moduleHash = _version;
                // logo = req_args.logo;
                owner = caller;
                launchpadId = tokenData.launchpadId;
                createdAt = Time.now();
                updatedAt = Time.now();
                description = tokenData.description;
                links = tokenData.links;
                lockContracts = tokenData.lockContracts;
                tokenProvider = ?"ICTO";
                enableCycleOpps = tokenData.enableCycleOpps;
            },
        ).0;
        _owners := Trie.put(_owners, keyT(Principal.toText(canister_id)), Text.equal, Principal.toText(caller)).0;
        //Remove pending canister
        _pendingCanisters := Trie.remove(_pendingCanisters, keyT(Principal.toText(caller)), Text.equal).0;
        #ok(canister_id);

    };

    //Get pending canisters by owner
    public shared ({ caller }) func getPendingCanisters() : async ([TokenInfo]) {
        var b : Buffer.Buffer<TokenInfo> = Buffer.Buffer<TokenInfo>(0);
        for ((i, v) in Trie.iter(_pendingCanisters)) {
            if (Principal.equal(v.owner, caller)) {
                b.add(v);
            };
        };
        let arr = Buffer.toArray(b);
        return arr;
    };

    //Tokens Functions
    public shared ({ caller }) func updateTokenData(canister_id: Text, tokenData: TokenInfo) : async Result.Result<Bool, Text> {
        let token = Trie.find(_tokens, keyT(canister_id), Text.equal);
        switch (token) {
            case (?t) {
                //Check owner is caller
                if (t.owner != caller and not _isAdmin(Principal.toText(caller))) return #err("Only owner can update token data");
                let updatedToken = {
                    t with
                    description = tokenData.description;
                    links = tokenData.links;
                    lockContracts = tokenData.lockContracts;
                    tokenProvider = tokenData.tokenProvider;
                    launchpadId = if(_isAdmin(Principal.toText(caller))) tokenData.launchpadId else t.launchpadId;
                };
                _tokens := Trie.put(_tokens, keyT(canister_id), Text.equal, updatedToken).0;
                return #ok(true);
            };
            case (_) {
                return #err("Token not found");
            };
        };
    };

    //Manual existed token to token list
    public func isSupportedStandards(tokenCanisterId : Principal) : async Bool {
        let tokenCanister : ICRCLedger.Self = actor(Principal.toText(tokenCanisterId));
        let supportedStandards = await tokenCanister.icrc1_supported_standards();
        for (standard in supportedStandards.vals()) {
            if (Array.find(_supportedTokens, func (token : Text) : Bool { 
                Text.equal(token, standard.name) 
            }) != null) {
                return true;
            };
        };
        false
    };
    //Admin remove token
    public shared ({ caller }) func removeToken(canister_id: Principal) : async Result.Result<Bool, Text> {
        assert (_isAdmin(Principal.toText(caller)));
        _tokens := Trie.remove(_tokens, keyT(Principal.toText(canister_id)), Text.equal).0;
        return #ok(true);
    };


    public func getLedgerMeta(tokenId : Principal) : async LedgerMeta {
        let ledger = actor (Principal.toText(tokenId)) : ICRCLedger.Self;
        let meta = await ledger.icrc1_metadata();
        let ? #Text(name) = findLedgerMetaVal("icrc1:name", meta) else Debug.trap("Can't find ledger name");
        let ? #Text(symbol) = findLedgerMetaVal("icrc1:symbol", meta) else Debug.trap("Can't find ledger symbol");
        let ? #Nat(fee) = findLedgerMetaVal("icrc1:fee", meta) else Debug.trap("Can't find ledger fee");
        let ? #Nat(decimals) = findLedgerMetaVal("icrc1:decimals", meta) else Debug.trap("Can't find ledger decimals");
        let ? #Text(logo) = findLedgerMetaVal("icrc1:logo", meta) else Debug.trap("Can't find ledger logo");
        { name; symbol; decimals; fee; logo }
    };
    private func findLedgerMetaVal(key : Text, values : [(Text, ICRCLedger.MetadataValue)]) : ?ICRCLedger.MetadataValue {
        let ?f = Array.find<(Text, ICRCLedger.MetadataValue)>(values, func((k : Text, d : ICRCLedger.MetadataValue)) = k == key) else return null;
        ?f.1;
    };
    public shared ({ caller }) func addToken(canister_id: Principal, tokenData: TokenData) : async Result.Result<Bool, Text> {
        //Admin always allow, user need to set ALLOW_CUSTOM_TOKEN to true
        if(not _isAdmin(Principal.toText(caller)) and not ALLOW_CUSTOM_TOKEN) {
            return #err("Custom token is not allowed");
        };
        //Check exist token
        let token = Trie.find(_tokens, keyT(Principal.toText(canister_id)), Text.equal);
        if (token != null) return #err("Token already exists");
        //validate token id
        let ledgerMeta = await getLedgerMeta(canister_id);
        let isSupported = await isSupportedStandards(canister_id);
        switch(isSupported) {
            case (true) {
                let _tokenData : TokenInfo = {
                    canisterId = canister_id;
                    standard = "ICRC-1";
                    name = ledgerMeta.name;
                    symbol = ledgerMeta.symbol;
                    decimals = Nat8.fromNat(ledgerMeta.decimals);
                    fee = ledgerMeta.fee;
                    description = tokenData.description;
                    launchpadId = null;
                    links = tokenData.links;
                    // logo = ledgerMeta.logo;
                    lockContracts = tokenData.lockContracts;
                    moduleHash = Hex.encode(Blob.toArray(SNS_WASM_VERSION));
                    owner = caller;
                    tokenProvider = null;
                    createdAt = Time.now();
                    updatedAt = Time.now();
                    enableCycleOpps = tokenData.enableCycleOpps;
                };
                _tokens := Trie.put(_tokens, keyT(Principal.toText(canister_id)), Text.equal, _tokenData).0;
                _owners := Trie.put(_owners, keyT(Principal.toText(canister_id)), Text.equal, Principal.toText(caller)).0;
                return #ok(true);
            };
            case (false) {
                return #err("Token not supported, please use supported token: " # debug_show(_supportedTokens));
            };
        };
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
    public shared func balance() : async Nat {
        await icrcLedger.icrc1_balance_of({ owner = deployer(); subaccount = null });
    };
    //Upload chunk to deployer: For manual wasm upload
    public shared ({ caller }) func uploadChunk(chunk: [Nat8]) : async Nat {
        assert (_isAdmin(Principal.toText(caller)));
        wasmChunks.add(Blob.fromArray(chunk));
        return chunk.size();
    };
    public shared ({ caller }) func clearChunks() : async () {
        assert (_isAdmin(Principal.toText(caller)));
        wasmChunks.clear();
    };
    // Turn a list of blobs into one blob.
    private func _flattenPayload (payload : [Blob]) : async Blob {
        Blob.fromArray(
            Array.foldLeft<Blob, [Nat8]>(payload, [], func (a : [Nat8], b : Blob) {
                Array.append(a, Blob.toArray(b));
            })
        );
    };

    //Manual add wasm file
    public shared ({ caller }) func addWasm(hash : [Nat8]) : async Result.Result<Text, Text> {
        assert (_isAdmin(Principal.toText(caller)));
        SNS_WASM_VERSION := Blob.fromArray(hash);
        SNS_WASM := await _flattenPayload(wasmChunks.toArray());
        return #ok("Wasm added successfully: " # debug_show(SNS_WASM.size()));
    };
    //Transfer ICP from deployer
    public shared ({ caller }) func transfer(amount : Nat, to : Principal) : async Result.Result<Nat, Text> {
        assert (_isAdmin(Principal.toText(caller)));
        let _result = await icrcLedger.icrc1_transfer({
            from_subaccount = null;
            to = { owner = to; subaccount = null };
            amount = amount;
            fee = null;
            memo = null;
            created_at_time = null;
        });
        switch (_result) {
            case (#Ok(v)) {#ok(v)};
            case (#Err(e)) {#err(debug_show(e))};
        };
    };
    //Update Initial cycles for new token canister
    public shared ({ caller }) func updateInitCycles(install : Nat, archive : Nat64) : async () {
        assert (_isAdmin(Principal.toText(caller)));
        CYCLES_FOR_INSTALL := install;
        CYCLES_FOR_ARCHIVE := archive;
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

    //Admin Functions - Update ALLOW_CUSTOM_TOKEN
    public shared ({ caller }) func updateAllowCustomToken(allow : Bool) : async () {
        assert (_isAdmin(Principal.toText(caller)));
        ALLOW_CUSTOM_TOKEN := allow;
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

    public query func getUserTokens(uid : Text, _page : Nat) : async ([TokenInfo]) {
        var lower : Nat = _page * 9;
        var upper : Nat = lower + 9;
        var b : Buffer.Buffer<TokenInfo> = Buffer.Buffer<TokenInfo>(0);
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
        b := Buffer.Buffer<TokenInfo>(0);
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

    public query ({ caller }) func getTokens(_page : Nat, _myTokens : Bool) : async ([TokenInfo]) {
        var lower : Nat = Nat.mul(_page, PAGE_SIZE);
        var upper : Nat = Nat.add(lower, PAGE_SIZE);
        var b : Buffer.Buffer<TokenInfo> = Buffer.Buffer<TokenInfo>(0);
        for ((i, v) in Trie.iter(_owners)) {
            switch (Trie.find(_tokens, keyT(i), Text.equal)) {
                case (?t) {
                    if (_myTokens == true) {
                        if (Principal.equal(t.owner, caller)) {
                            b.add(t);
                        };
                    } else {
                        b.add(t);
                    };
                };
                case _ {};
            };
        };
        let arr = Buffer.toArray(b);
        b := Buffer.Buffer<TokenInfo>(0);
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
    public query func getTokenDetails(canister_id : Text) : async (?TokenInfo) {
        switch (Trie.find(_tokens, keyT(canister_id), Text.equal)) {
            case (?t) {
                return ?t;
            };
            case _ {
                return null;
            };
        };
    };

    //Add canister to white list canisters - Called by launchpad when creating new launchpad
    public shared ({ caller }) func addToWhiteList(canister_id : Principal) : async Result.Result<Bool, Text> {
        let LAUNCHPAD_CANISTER_ID = await getRemoteCanisterId("launchpad");
        if (caller != LAUNCHPAD_CANISTER_ID) return #err("Only launchpad can add to white list");
        WHITE_LIST_CANISTERS := Array.append(WHITE_LIST_CANISTERS, [canister_id]);
        return #ok(true);
    };

    //Moving all canister owner from _owners to _tokens field
    public shared ({ caller }) func moveOwnerToToken() : async Result.Result<Bool, Text> {
        assert (_isAdmin(Principal.toText(caller)));
        for ((i, v) in Trie.iter(_tokens)) {
            let owner = await getOwner(i);
            switch (owner) {
                case (?owner) {
                    let _token : TokenInfo = {
                        v with
                        owner = Principal.fromText(owner);
                    };
                    _tokens := Trie.put(_tokens, keyT(i), Text.equal, _token).0;
                };
                case (_) {};
            };
        };
        return #ok(true);
    };

    //Update token owner
    public shared ({ caller }) func updateTokenOwner(canister_id : Text, owner : Principal) : async Result.Result<Bool, Text> {
        assert (_isAdmin(Principal.toText(caller)));
        let token = Trie.find(_tokens, keyT(canister_id), Text.equal);
        switch (token) {
            case (?t) {
                let _token : TokenInfo = {
                    t with
                    owner = owner;
                };
                _tokens := Trie.put(_tokens, keyT(canister_id), Text.equal, _token).0;
                return #ok(true);
            };
            case (_) {
                return #err("Token not found");
            };
        };
    };
    //Show owner list
    public query func getOwnerList() : async [(Text, Text)] {
        let b : Buffer.Buffer<(Text, Text)> = Buffer.Buffer<(Text, Text)>(0);
        for ((i, v) in Trie.iter(_owners)) {
            b.add((i, v));
        };
        return Buffer.toArray(b);
    };

    private func get_wasm_version(): async () {
        let _ = await get_lastest_version();
        ();
    };
    //Set timer to fetch new version of wasm, 1 day
    timerId := Timer.recurringTimer<system>(#seconds(24*60*60), get_wasm_version);

}
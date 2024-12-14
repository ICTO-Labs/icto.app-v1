// import Contract "../contract/Contract";
import Principal "mo:base/Principal";
import Array "mo:base/Array";
import HashMap "mo:base/HashMap";
import Buffer "mo:base/Buffer";
import Option "mo:base/Option";
import Cycles "mo:base/ExperimentalCycles";
import Time "mo:base/Time";
import Int "mo:base/Int";
import Timer "mo:base/Timer";
import Text "mo:base/Text";
import IC "../utils/IC";
import Types "./Types";
import Actor "../utils/Actor";
import ContractTypes "../claim_contract/types/Common";
import Trie "mo:base/Trie";
import TokenClaim "../claim_contract/TokenClaim";
import Debug "mo:base/Debug";
import Result "mo:base/Result";
import ICRCLedger "../utils/ICRCLedger";

actor {
    stable var currentValue: Nat = 0;
    stable var CONTRACT_VERSION: Text = "0.1.1";
    stable var CYCLES_FOR_INSTALL: Nat = 300_000_000_000;
    private stable var MIN_CYCLES_IN_DEPLOYER: Nat = 2_000_000_000_000;//Minimum cycles in deployer
    let ic: IC.Self = actor "aaaaa-aa";
    private stable var GOVERNANCE_CANISTER_ID: Principal = Principal.fromText("aaaaa-aa");
    private stable var _admins : [Text] = ["lekqg-fvb6g-4kubt-oqgzu-rd5r7-muoce-kppfz-aaem3-abfaj-cxq7a-dqe"];
    private stable var _contracts : [Text] = [];//list of all contracts
    private stable var ownerContracts : Trie.Trie<Text, [Text]> = Trie.empty();
    private stable var contractsMetadata : Trie.Trie<Text, Types.ContractMetadata> = Trie.empty();

    // private stable var INDEXING_CANISTER : Text = "avqkn-guaaa-aaaaa-qaaea-cai";
    private let icrcLedger : ICRCLedger.Self = actor ("ryjl3-tyaaa-aaaaa-aaaba-cai");//For ICRC transfer
    private stable var privateContracts : Trie.Trie<Text, [Text]> = Trie.empty(); // wallet -> contracts
    private stable var publicContracts : [Text] = []; // list of public contracts

    ////////// HELPERS //////////
    // Helper function to add contract to owner mapping
    private func addContractToOwner(owner: Text, contractId: Text) {
        let existing = Trie.get(ownerContracts, keyT(owner), Text.equal);
        let contracts = switch (existing) {
            case (null) {[contractId]};
            case (?existing) {
                if (Array.find<Text>(existing, func(x) { x == contractId }) == null) {
                    Array.append(existing, [contractId])
                } else {
                    existing
                };
            };
        };
        ownerContracts := Trie.put(ownerContracts, keyT(owner), Text.equal, contracts).0;
    };

    // Helper function to save contract metadata
    private func saveContractMetadata(contractId: Text, owner: Text, distributionType: ContractTypes.DistributionType) {
        let metadata : Types.ContractMetadata = {
            id = contractId;
            owner = owner;
            distributionType = distributionType;
            createdAt = Time.now();
        };
        contractsMetadata := Trie.put(contractsMetadata, keyT(contractId), Text.equal, metadata).0;
    };

    //Call created contract init function
    private func triggerContractInit(canister_id: Text) : async () {
        let SmartContract = actor(canister_id) : actor {
            init : shared () -> async ();
        };
        await SmartContract.init();
    };

    // Helper add contract to wallet by distribution type
    private func addContractByType(contractId: Text, distributionType: ContractTypes.DistributionType, recipients: ?[Types.Recipient]) {
        switch(distributionType) {
            case (#Public) {
                // Public contract
                publicContracts := Array.append(publicContracts, [contractId]);
            };
            case (#Whitelist) {
                // Private contract
                switch(recipients) {
                    case(?recipientList) {
                        for(recipient in recipientList.vals()) {
                            let wallet = recipient.address;
                            let existing = Trie.get(privateContracts, keyT(wallet), Text.equal);
                            let contracts = switch (existing) {
                                case (null) {[contractId]};
                                case (?existing) {
                                    if (Array.find<Text>(existing, func(x) { x == contractId }) == null) {
                                        Array.append(existing, [contractId])
                                    } else {
                                        existing
                                    };
                                };
                            };
                            privateContracts := Trie.put(privateContracts, keyT(wallet), Text.equal, contracts).0;
                        };
                    };
                    case(null) {};
                };
            };
            case _ {};
        };
    };

    // Query function get list contracts of wallet, also return public contracts
    public shared query ({caller}) func getContractsByWallet() : async {
        privateContracts: [Text];
        publicContracts: [Text];
    } {
        let privateList = Option.get(Trie.get(privateContracts, keyT(Principal.toText(caller)), Text.equal), []);
        return {
            privateContracts = privateList;
            publicContracts = publicContracts;
        };
    };

    private func createICRC1Actor(id : Text) : async ICRCLedger.Self {
        actor(id);
    };

    private func _isAdmin(p : Text) : (Bool) {
        for (i in _admins.vals()) {
            if (i == p) {
                return true;
            };
        };
        return false;
    };


    private func keyT(x : Text) : Trie.Key<Text> {
        return { hash = Text.hash(x); key = x };
    };
    private func key(x : Nat32) : Trie.Key<Nat32> {
        return { hash = x; key = x };
    };
    
    //Generate time now to second
    func timeNow(): Nat{
        Int.abs(Time.now()/1_000_000_000)
    };
    public shared (msg) func whoami() : async Principal {
        msg.caller
    };
    private func transferFrom(canisterId: Text, payload: Actor.TransferFromArg) : async Actor.TransferFromResult {
        let ICRC : Actor.ICRC = actor(canisterId);
        await ICRC.icrc2_transfer_from(payload)
    };
    public func canister_status(canister_id: IC.canister_id): async Types.CanisterStatus{
        await ic.canister_status({canister_id = canister_id})
    };
    public shared({ caller }) func addController(canister_id: IC.canister_id, controllers: [Principal]): async () {
        assert (_isAdmin(Principal.toText(caller)));
        await ic.update_settings({
            canister_id = canister_id;
            settings = {
                controllers = ?controllers;
                compute_allocation = ?0;
                memory_allocation = ?0;
                freezing_threshold = ?2592000;
            }
        });
    };
    public shared (msg) func createContract(contract: ContractTypes.ContractData): async Result.Result<Principal, Text>{
        // assert not Principal.isAnonymous(msg.caller);
        // if (not _isAdmin(Principal.toText(msg.caller))){//Only admin can create contract
        //     return #err("Sorry, only admin can create contract in testing phase!");
        // };
        let _controllers = [msg.caller];
        let _cycleBalance = Cycles.balance();
        if (_cycleBalance < CYCLES_FOR_INSTALL + MIN_CYCLES_IN_DEPLOYER) return #err("Not enough cycles in deployer, balance: "# debug_show(_cycleBalance) #"T");
        Cycles.add<system>(CYCLES_FOR_INSTALL);
        Debug.print("Contract data: " # debug_show(contract));
        //must add VERSION to contract data

        //Add governanceId to contract data
        let _contract = {
            contract with
            governanceId = ?GOVERNANCE_CANISTER_ID;
        };
        let ContractActor = await TokenClaim.Contract(_contract);
        let contractId = Principal.fromActor(ContractActor);
        //Update settings;
        // await CA.updateCanisterSettings({
        // canisterId = contractId;
        // settings = {
        //     controllers = controllers;
        //     compute_allocation = ?0;
        //     memory_allocation = ?0;
        //     freezing_threshold = ?2592000;
        // }
        // });

        let _contractId = Principal.toText(contractId);
        await ContractActor.init();//Trigger init function

        Debug.print("Contract id: " # _contractId);
        addContract(_contractId);//Add to contract list
        addContractToOwner(Principal.toText(msg.caller), _contractId);//Add to owner mapping
        saveContractMetadata(_contractId, Principal.toText(msg.caller), contract.distributionType);//Save metadata
        //Map created contract
        let _recipients = Option.get(contract.recipients, []);
        if(contract.distributionType == #Whitelist and _recipients.size() > 0){//Whitelist contract
            addContractByType(_contractId, #Whitelist, contract.recipients);
        }else{//Public contract
            addContractByType(_contractId, #Public, null);
        };

        //Transfer token to new contract, skipp admin for testing purpose
        if (not _isAdmin(Principal.toText(msg.caller))){
            let _tokenActor = await createICRC1Actor(contract.tokenInfo.canisterId);
            switch (await _tokenActor.icrc2_transfer_from({ from = { owner = msg.caller; subaccount = null }; spender_subaccount = null; to = { owner = contractId; subaccount = null }; fee = null; memo = null; from_subaccount = null; created_at_time = null; amount = contract.totalAmount })) {
            case (#Ok(_)) ();
            case (#Err(e)) return #err("Payment error: " # debug_show(e));
            };
        };

        #ok(contractId);
    };

    public shared({ caller }) func cancelContract(canister_id: Principal) : async (){
        assert (_isAdmin(Principal.toText(caller)));
        await ic.stop_canister({ canister_id = canister_id });
        await ic.delete_canister({ canister_id = canister_id });
    };
    
    public shared({ caller }) func addAdmin(p : Text) : async () {
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
    private func addContract(p : Text) : () {
        var b : Buffer.Buffer<Text> = Buffer.Buffer<Text>(0);
        b.add(p);
        _contracts := Buffer.toArray(b);
    };

    public shared({ caller }) func removeAdmin(p : Text) : async () {
        assert (_isAdmin(Principal.toText(caller)));
        var b : Buffer.Buffer<Text> = Buffer.Buffer<Text>(0);
        for (i in _admins.vals()) {
            if (p != i) {
                b.add(i);
            };
        };
        _admins := Buffer.toArray(b);
    };

    public query func getAdmins() : async ([Text]) {
        return _admins;
    };


    // Get contracts created by owner
    public shared({caller}) func getMyContracts() : async [Types.ContractMetadata] {
        let ownedContracts = switch (Trie.get(ownerContracts, keyT(Principal.toText(caller)), Text.equal)) {
            case (null) {[]};
            case (?contracts) {
                Array.mapFilter<Text, Types.ContractMetadata>(contracts, func(id) {
                    Trie.get(contractsMetadata, keyT(id), Text.equal)
                });
            };
        };
        return ownedContracts
    };

    // Query to get metadata of a contract
    public query func getContractMetadata(contractId: Text) : async ?Types.ContractMetadata {
        Trie.get(contractsMetadata, keyT(contractId), Text.equal)
    };

    // Query to get all contracts of the system (only admin)
    public shared query({ caller }) func getAllContracts() : async [Types.ContractMetadata] {
        assert(_isAdmin(Principal.toText(caller)));
        
        let allMetadata = Trie.toArray<Text, Types.ContractMetadata, Types.ContractMetadata>(
            contractsMetadata,
            func(_, v) { v }
        );
        return allMetadata;
    };

    //Show all mapping of private contracts
    public query func getPrivateContracts(owner: Text) : async [Text] {
        return Option.get(Trie.get(privateContracts, keyT(owner), Text.equal), []);
    };
};

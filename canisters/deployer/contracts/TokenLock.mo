import Array "mo:base/Array";
import Cycles "mo:base/ExperimentalCycles";
import Text "mo:base/Text";
import Int "mo:base/Int";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Float "mo:base/Float";
import Time "mo:base/Time";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Prim "mo:⛔";
import Timer "mo:base/Timer";
import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Debug "mo:base/Debug";
import HashMap "mo:base/HashMap";
import Bool "mo:base/Bool";
import DeployerTypes "../Types";
import Error "mo:base/Error";

shared ({ caller = deployer }) actor class Contract(contract: DeployerTypes.LockContract) = this {
    var SECOND_TO_NANO = 1_000_000_000;//Conver second (s) to nano second rate
    private stable var _contract            : DeployerTypes.LockContract = contract;
    private stable var _isStarted           : Bool = false;
    private stable var _transactions        : [(Text, TransferRecord)] = []; //Transaction List
    private var transactions                : HashMap.HashMap<Text, TransferRecord> = HashMap.fromIter(_transactions.vals(), 0, Text.equal, Text.hash);

    private func cid() : Principal = Principal.fromActor(this);//Return this actor's principal id

    public type TransferRecord = {
        from : Text; 
        to : Text;
        method : Text; // "deposit" or "withdraw"
        positionId : Nat;
        time : Time.Time;
    };
    public type UserPositionInfo = {
        tickUpper : Int;
        tokensOwed0 : Nat;
        tokensOwed1 : Nat;
        feeGrowthInside1LastX128 : Nat;
        liquidity : Nat;
        feeGrowthInside0LastX128 : Nat;
        tickLower : Int;
    };

    let Deployer = actor(Principal.toText(deployer)) : actor{
        updateContractStatus: shared (Text, Text) -> async ();
    };
    let POOL = actor (contract.poolId) : actor {
        transferPosition : shared (Principal, Principal, Nat) -> async { #ok : Bool; #err : Error };
        getUserPosition : shared query Nat -> async { #ok : UserPositionInfo; #err : Error };
        checkOwnerOfUserPosition: shared query (Principal, Nat) -> async { #ok : Bool; #err : Error };
    };

    private func transferPosition(from: Principal, to: Principal, positionId: Nat) : async Result.Result<Bool, Error>{
        let position = await POOL.transferPosition(from, to, positionId);
        return position;
    };

    public type Error = {
        #CommonError;
        #InternalError: Text;
        #UnsupportedToken: Text;
        #InsufficientFunds;
    };
    func isOvertimeAllowed(): Bool {
        let currentTime = Time.now() / SECOND_TO_NANO;
        let contractCreated = contract.created / SECOND_TO_NANO;
        // let duration = contract.durationTime * contract.durationUnit;
        let duration = _contract.durationTime * _contract.durationUnit;//Get duration from tempo obj (update able)
        return currentTime - contractCreated >= duration;
    };
    private func isOwnerOfPosition(positionId: Nat) : async Bool {
        let result = await POOL.checkOwnerOfUserPosition(cid(), positionId);
        switch(result){
            case (#ok(true)){
                return true;
            };
            case (#ok(false)){
                return false;
            };
            case (#err(err)){
                return false;
            }
        };
    };

    public query func getTransactions() : async [(Text, TransferRecord)] {
        Iter.toArray(transactions.entries());
    };
    //Update status on Deployer
    func updateDeployerStatus(status: Text): async (){
        let _cid = Principal.toText(cid());
        await Deployer.updateContractStatus(_cid, status);
    };
    func addTransaction(from: Principal, to: Principal, positionId: Nat, method: Text): async Result.Result<Bool, Text>{
        let newRecord = {
            from = Principal.toText(from);
            to = Principal.toText(to);
            method = method;
            positionId = positionId;
            time = Time.now()
        };
        try{
            transactions.put(Principal.toText(from), newRecord);
            #ok(true);
        }catch(err){
            #err(Error.message(err));
        }
        
    };
    func updateStatus(status: Text): async (){
        switch(status){
            case ("locked"){
                _contract := {
                    _contract with
                    lockedTime = ?Time.now();
                    status = status;
                };
                await updateDeployerStatus(status);//send status back to deployer
            };
            case ("unlocked"){
               //Match the unlockedTime as defined in the contract
               let _unlockedTime = Time.now() + (_contract.durationTime * _contract.durationUnit * SECOND_TO_NANO);//Get duration from tempo obj (update able)
                _contract := {
                    _contract with
                    unlockedTime = ?_unlockedTime;
                    status = status;
                };
                await updateDeployerStatus(status);//send status back to deployer
            };
            case ("withdrawn"){
                _contract := {
                    _contract with
                    withdrawnTime = ?Time.now();
                    status = status;
                };
                await updateDeployerStatus(status);//send status back to deployer
            };
            case _ {
                
            };
        }
    };
    //Check transaction.
    public shared ({ caller }) func verify() : async Result.Result<Bool, Text>{
        // if(Principal.isAnonymous(caller)) return #err("Illegal anonymous call");
        // if(Principal.notEqual(caller, contract.positionOwner)) return #err("Unauthorized: Called is different the position owner!");
        // if(Principal.notEqual(to, cid())) return #err("Unauthorized: Receiver is different this canister id!");
        if(_contract.status == "created"){//One time check
            let isOwner = await isOwnerOfPosition(contract.positionId);
            if(isOwner == true){
                await updateStatus("locked");//Update status and time
                await addTransaction(contract.positionOwner, cid(), contract.positionId, "deposit");
            }else{
                return #err("Transaction not found. Ensure that you have transferred the position to the canister ID: "#Principal.toText(cid()));
            }
        }else{
            return #ok(true);
        }
    };

    //Get the locked position
    public query func getLockedPosition() : async Nat {
        contract.positionId;
    };
    //Get the contract version
    public query func getVersion() : async Text {
        contract.version;
    };
    public query func cycleBalance() : async Nat {
        Cycles.balance();
    };
    //Get init contract
    public query func getInitContract() : async DeployerTypes.LockContract {
        contract;
    };
    //Get mutation _contract (updated status/time)
    public query func getContract() : async DeployerTypes.LockContract {
        _contract;
    };
    public query func getDeployer(): async Principal{
        deployer;
    };

    public shared func checkOvertime(): async (){
        if(isOvertimeAllowed() == true and _contract.status == "locked"){
            await updateStatus("unlocked");//Update status and time
            let _ = await addTransaction(cid(), contract.positionOwner, contract.positionId, "unlocked");
        };
        ();
    };

    ///For beta version only, will be removed in the mainnet
    public shared ({caller}) func fallback_send(to: Principal, positionId: Nat): async Result.Result<Bool, Text> {
        assert(Principal.equal(caller, Principal.fromText("lekqg-fvb6g-4kubt-oqgzu-rd5r7-muoce-kppfz-aaem3-abfaj-cxq7a-dqe")));
        let result = await transferPosition(cid(), to, positionId);
        switch(result){
            case(#ok(true)){
                await updateStatus("withdrawn");//Update status and time
                #ok(true);
                // await addTransaction(cid(), contract.positionOwner, contract.positionId, "withdraw");
            };
            case(#err(e)){
                #err(debug_show(e));
            };
            case _ {
                #err("An unexpected error occurred, please try again!");
            };
        }
    };

    public shared ({caller}) func increaseDuration(durationUnit: Nat, durationTime: Nat) : async Result.Result<Bool, Text> {
        assert(Principal.equal(caller, contract.positionOwner));
        if(_contract.status != "withdrawn"){
            let _currentDuration = _contract.durationUnit * _contract.durationTime;//Get duration in seconds
            let _newDuration = durationTime * durationUnit;//new duration in seconds
            if(_newDuration < 1) return #err("Duration is invalid!");
            _contract := {
                _contract with
                durationTime = _currentDuration + _newDuration;
                durationUnit = 1;
            };
            #ok(true);
        }else{
            #err("The contract is already unlocked, you can't increase the duration, please create a new contract!");
        }
    };

    public shared ({ caller }) func withdraw() : async Result.Result<Bool, Text> {
        if(Principal.equal(caller, contract.positionOwner) == false){
            return #err("Unauthorized: You are not the owner of the position!");
        };
        if(isOvertimeAllowed() == true){
            //TODO: Transfer the locked amount to the caller
            let transfer = await transferPosition(cid(), contract.positionOwner, contract.positionId);
            switch(transfer){
                case(#ok(true)){
                    await updateStatus("withdrawn");//Update status and time
                    await addTransaction(cid(), contract.positionOwner, contract.positionId, "withdraw");
                };
                case(#err(e)){
                    #err(debug_show(e))
                };
                case _ {
                    #err("An unexpected error occurred, please try again!");
                };
            }
        }else{
            #err("Please wait until the unlock time!");
        };
    };
};
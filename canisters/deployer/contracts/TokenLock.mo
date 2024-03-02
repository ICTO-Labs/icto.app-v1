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
    var _created = Time.now();
    var SECOND_TO_NANO = 1_000_000_000;//Conver second (s) to nano second rate
    private stable var _contract            : DeployerTypes.LockContract = contract;
    private stable var _isStarted           : Bool = false;
    private stable var _transactions        : [(Principal, TransferRecord)] = []; //Transaction List
    private var transactions                : HashMap.HashMap<Principal, TransferRecord> = HashMap.fromIter(_transactions.vals(), 0, Principal.equal, Principal.hash);

    private func cid() : Principal = Principal.fromActor(this);//Return this actor's principal id

    public type TransferRecord = {
        from : Principal; 
        to : Principal;
        method : Text; // "deposit" or "claim"
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
        let duration = contract.durationTime * contract.durationUnit;
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

    public func getTransactions() : async [(Principal, TransferRecord)] {
        Iter.toArray(transactions.entries());
    };
    //Update status on Deployer
    func updateDeployerStatus(status: Text): async (){
        let _cid = Principal.toText(cid());
        await Deployer.updateContractStatus(_cid, "unlocked");
    };
    func addTransaction(from: Principal, to: Principal, positionId: Nat, method: Text): async Result.Result<Bool, Text>{
        let newRecord = {
            from = from;
            to = to;
            method = method;
            positionId = positionId;
            time = Time.now()
        };
        try{
            transactions.put(from, newRecord);
            #ok(true);
        }catch(err){
            #err(Error.message(err));
        }
        
    };
    func updateStatus(status: Text):(){
        switch(status){
            case ("locked"){
                _contract := {
                    _contract with
                    lockedTime = ?Time.now();
                    status = status;
                };
            };
            case ("unlocked"){
                _contract := {
                    _contract with
                    unlockedTime = ?Time.now();
                    status = status;
                };
            };
            case _ {
                
            };
        }
    };
    //Check transaction.
    public shared ({ caller }) func checkTransaction(to: Principal, positionId: Nat) : async Result.Result<Bool, Text>{
        assert(Principal.equal(caller, contract.positionOwner));
        assert(Principal.equal(to, cid()));
        if(_isStarted == false){//One time check
            let isOwner = await isOwnerOfPosition(positionId);
            if(isOwner == true){
                _isStarted := true;
                updateStatus("locked");//Update status and time
                await addTransaction(caller, to, positionId, "deposit");
            }else{
                return #err("Transaction not found. Please ensure that you have transferred the positionID to the canister ID: "#Principal.toText(cid()));
            }
        }else{
            return #err("Payment has been verified before!");
        }
    };

    public query func getLockedPosition() : async Nat {
        contract.positionId;
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
    public shared ({ caller }) func claim() : async Result.Result<Bool, Text> {
        if(isOvertimeAllowed() == true){
            //TODO: Transfer the locked amount to the caller
            updateStatus("unlocked");//Update status and time
            let _cid = Principal.toText(cid());
            await Deployer.updateContractStatus(_cid, "unlocked");
            #ok(true);
        }else{
            #err("Cannot claim yet. Please wait until the unlock time is reached!");
        };
    };
};
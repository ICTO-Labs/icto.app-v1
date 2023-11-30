
import Array "mo:base/Array";
import Cycles "mo:base/ExperimentalCycles";
import Text "mo:base/Text";
import Int "mo:base/Int";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Time "mo:base/Time";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Prim "mo:⛔";
import Queue "./Queue";
import Timer "mo:base/Timer";
import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Debug "mo:base/Debug";
import Types "./types/Common";//Common
import ICRC1Types "./types/ICRC";//
import HashMap "mo:base/HashMap";
import Ledger "Ledger";

shared ({ caller = creator }) actor class Contract({
  initTokenId: Text;
  initAmount: Nat;
  initDuration: Nat;
  initReceivers: [Principal];
  initVersion: Text;
  initRecurring: Nat;//Second
  initStartTime: Nat;//From second
}) = this {

  //Token Config
  let ICRC1 : Ledger.ICRC1 = actor(initTokenId);

  //*********** DATA DEFINE **********//
  private stable var _pendingTransfers : [Types.TransferHistory] = [];
  private stable var _transferHistory  : [(Nat, Types.TransferHistory)] = [];
  private stable var _historyIdx      : Nat = 0;

  var pendingTransfers : Queue.Queue<Types.TransferHistory> = Queue.fromArray(_pendingTransfers);
  var transferHistory  : HashMap.HashMap<Nat, Types.TransferHistory> = HashMap.fromIter(_transferHistory.vals(), 0, Nat.equal, Nat32.fromNat);



  var start_time = Time.now();
  var start_balance = Cycles.balance() : Int;
  var count = 0;

  //*********** PRIVATE FUNCTIONS **********//

  func system_cron(): async (){
    count += 1;
    await transferToken();
  };           
  func timeNow(): Nat{
        Int.abs(Time.now()/1_000_000_000)
  };
  func in_time(): async(){

  };

  func transferToken(): async(){
      //Check induration
      if(Time.now()/1_000_000_000 - initStartTime < initDuration){
        _addTransferHistory({
            to = initReceivers[0];
            amount = Nat64.fromNat(initAmount);
            time = Time.now();
            txId = 0;
        });
      }else{
        // Timer.cancelTimer(cron_id);
      }
  };
  func process_pending(): async(){
     while(Queue.size(pendingTransfers) > 0){
      var last = Queue.next(pendingTransfers);
      switch(last.0){
        case(?d) {
          pendingTransfers := last.1;
          try {
            // var bh = await transferToken({
            //   memo = 0;
            //   amount = { e8s = d.3 };
            //   fee = { e8s = 10000 };
            //   from_subaccount = ?d.2;
            //   to = d.1;
            //   created_at_time = null;
            // });
          } catch (e) {
            pendingTransfers := Queue.add(d, pendingTransfers);
          };
        };
        case(_) {};
      };
    };
  };
  //Catch error transaction to queue
  func _addPendingTransfer(d : Types.TransferHistory) : () {
    pendingTransfers := Queue.add(d, pendingTransfers);
  };
  //Add successed transaction to history
  func _addTransferHistory(data: Types.TransferHistory) : () {
      transferHistory.put(_historyIdx, data);
      _historyIdx += 1;//Increase idx
  };

  // Subaccount shall be a blob of 32 bytes
  func toSubaccount(principal: Principal) : Blob {
    let blob_principal = Blob.toArray(Principal.toBlob(principal));
    // According to IC interface spec: "As far as most uses of the IC are concerned they are
    // opaque binary blobs with a length between 0 and 29 bytes"
    if (blob_principal.size() > 32) {
      Debug.trap("Cannot convert principal to subaccount: principal length is greater than 32 bytes");
    };
    let buffer = Buffer.Buffer<Nat8>(32);
    buffer.append(Buffer.fromArray(blob_principal));
    // Add padding until 32 bytes
    while(buffer.size() < 32) {
      buffer.add(0);
    };
    // Return the buffer as a blob
    Blob.fromArray(Buffer.toArray(buffer));
  };

  // @todo: this should be part of another module
  func toBaseResult<Ok, Err>(icrc1_result: Types.TokenResult<Ok, Err>) : Result.Result<Ok, Err> {
    switch(icrc1_result){
      case(#Ok(ok)) {
        #ok(ok);
      };
      case(#Err(err)) {
        #err(err);
      };
    };
  };

//Transfer to 
func _transfer(to: Principal) : async* Result.Result<Nat, ICRC1Types.TransferError> {

    // if (Set.has(_airdropped_users, Set.phash, principal)) {
    //   return #err(#AlreadySupplied);
    // };

    let transfer_result = toBaseResult(await ICRC1.icrc1_transfer({
      to = {
        owner = to;
        subaccount = null;
      };
      fee = null;
      amount = initAmount;
      memo = null;
      from_subaccount = null;
      created_at_time = ?Nat64.fromNat(Int.abs(Time.now()));
    }));

    Result.iterate(transfer_result, func(tx_index: Nat){
      // ignore //Add to transaction
      //Set.put(_airdropped_users, Set.phash, principal);
    });

    transfer_result;
  };

  //*********** CRON **********//
  let cron_id = Timer.recurringTimer(#seconds (initRecurring), system_cron);
  func system_cancel_cron(): () {
     Timer.cancelTimer(cron_id);
  };
  //*********** PUBLIC FUNCTIONS **********//
  public shared func cancel(): async () {
        system_cancel_cron();
  };
  public query func get(): async Types.ContractData { 
    let _data:Types.ContractData = {
      tokenId = initTokenId;
      amount = initAmount;
      duration = initDuration;//Payment contract ends
      receivers= initReceivers;
      version = initVersion;
      recurring = initRecurring;//Unlock schedule
      cronId = cron_id;
    };
    _data;
  };
  public query func stats(): async [(Text, Nat)]{
    [
      ("Pending Payment", Queue.size(pendingTransfers))
    ]
  };
  public shared ({ caller }) func getBalance () : async Nat {
    await ICRC1.icrc1_balance_of({ owner = Principal.fromActor(this); subaccount = null; });
  };
  public query func history(): async [(Nat, Types.TransferHistory)]{
    Iter.toArray(transferHistory.entries())
  };

  public func reset() {
    start_time := Time.now();
    start_balance := Cycles.balance() : Int;
    count := 0;
  };

  public func report() : async Text {
    var time = (Time.now() - start_time) / 1_000_000;
    var heartbeat_rate = time / count;
    var balance = Cycles.balance() : Int;
    var burned = start_balance - balance;
    var burn_rate = 1_000 * burned / time;
    var burn_rate_bc_year = (60 * 60 * 24 * 365 * burn_rate) / 1_000_000_000;

    var t = "";
    t := Text.concat(t, "\n lang : motoko");
    t := Text.concat(t, Text.concat("\n time, ms             : ", Int.toText(time)));
    t := Text.concat(t, Text.concat("\n heartbeat count      : ", Int.toText(count)));
    t := Text.concat(t, Text.concat("\n heartbeat rate, ms   : ", Int.toText(heartbeat_rate)));
    t := Text.concat(t, Text.concat("\n balance, Cycles      : ", Int.toText(balance)));
    t := Text.concat(t, Text.concat("\n burned, Cycles       : ", Int.toText(burned)));
    t := Text.concat(t, Text.concat("\n burn rate, Cycles/s  : ", Int.toText(burn_rate)));
    t := Text.concat(t, Text.concat("\n burn rate, BCycles/y : ", Int.toText(burn_rate_bc_year)));
    t := Text.concat(t, "\n ");
    return t;
  };

  //*********** SYSTEM FUNCTIONS **********//
  system func preupgrade() {
    _pendingTransfers := Queue.toArray(pendingTransfers);
    _transferHistory := Iter.toArray(transferHistory.entries());
  };
  system func postupgrade() {
    _pendingTransfers := [];
    _transferHistory := [];
  }
}
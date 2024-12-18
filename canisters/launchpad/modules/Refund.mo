//Process refund for failed launchpads
import Types "../types/Common";
import Result "mo:base/Result";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import HashMap "mo:base/HashMap";
import Buffer "mo:base/Buffer";
import Ledger "../../utils/Ledger";
module {
    public class AutoRefund() {
        let transactions = Buffer.Buffer<Transaction>(0);
        let BATCH_SIZE = 100;

        public func createRefund(launchpad: Types.LaunchpadDetail, launchStatus: Text, participants: [(Text, Types.Participant)], contractId: Text) : async Result.Result<(), Text> {
            //1. Check conditions for refund
            if (launchStatus != "FAILED") {
                return #err("Launchpad is not failed");
            };
            if (Time.now() < launchpad.timeline.endTime) {
                return #err("Launchpad is not ended");
            };
            //2. Get contract balance
            let contractBalance = await getContractBalance(launchpad.purchaseToken.canisterId, contractId);
            if (contractBalance == 0) {
                return #err("Contract balance is 0");
            };
            //3. Generate refund list
            let _ = await generateRefundList(participants);
            //4. Process refund
            let tokenFee = await getTokenFee(launchpad.purchaseToken.canisterId);
            await processNextBatch(launchpad.purchaseToken.canisterId, BATCH_SIZE, tokenFee);
            return #ok();
        };

        type TransactionStatus = {
            #Pending;
            #Processed;
            #Failed : Text;
        };

        type Transaction = {
            principal : Principal;
            amount : Nat;
            txId: ?Nat;
            status : TransactionStatus;
        };

        // private var transactions : [Transaction] = [];
        private var currentIndex : Nat = 0;

        //Get contract balance
        private func getContractBalance(tokenId: Text, contractId: Text) : async Nat {
            let ICRC1 : Ledger.ICRC1 = actor(tokenId);
            let balance = await ICRC1.icrc1_balance_of({ owner = Principal.fromText(contractId); subaccount = null });
            balance
        };

        //Get token fee
        private func getTokenFee(tokenId: Text) : async Nat {
            let ICRC1 : Ledger.ICRC1 = actor(tokenId);
            let fee = await ICRC1.icrc1_fee();
            fee
        };

        //Generate refund list
        private func generateRefundList(participants: [(Text, Types.Participant)]): async(){
            let _participants : HashMap.HashMap<Text, Types.Participant> = HashMap.fromIter(participants.vals(), 0, Text.equal, Text.hash);
            for ((k, v) in _participants.entries()) {
                transactions.add({
                    principal = Principal.fromText(k);
                    amount = v.totalAmount;
                    status = #Pending;
                    txId = null;
                });
            };
        };

        //Process next batch
        public func processNextBatch(tokenId: Text, batchSize : Nat, tokenFee : Nat) : async () {
            let endIndex = Nat.min(currentIndex + batchSize, transactions.size());
            label l for (i in Iter.range(currentIndex, endIndex - 1)) {
                switch (await* processTransaction(tokenId, transactions.get(i), tokenFee)) {
                    case (#ok(txId)) {
                        transactions.put(i, {
                            principal = transactions.get(i).principal;
                            amount = transactions.get(i).amount;
                            status = #Processed;
                            txId = ?txId;
                        });
                    };
                    case (#err(e)) {
                        transactions.put(i, {
                            principal = transactions.get(i).principal;
                            amount = transactions.get(i).amount;
                            status = #Failed(e);
                            txId = null;
                        });
                        break l;
                    };
                };
            };
            currentIndex := endIndex;
        };

        func processTransaction(tokenId: Text, transaction : Transaction, tokenFee : Nat) : async* Result.Result<Nat, Text> {
            // Perform transfer by ICRC1 standard
            let ICRC1 : Ledger.ICRC1 = actor(tokenId);
            let txId = await ICRC1.icrc1_transfer({
                to = { owner = transaction.principal; subaccount = null };
                from_subaccount = null;
                fee = null;
                amount = transaction.amount - tokenFee;//Receiver gets the amount after deducting the fee
                memo = null;
                created_at_time = null;
            });
            switch (txId) {
                case (#Ok(txId)) {
                    return #ok(txId);
                };
                case (#Err(e)) {
                    return #err(debug_show(e));
                };
            };
        };

        public query func getProcessingStatus() : async {processed : Nat; total : Nat} {
            let processed = Iter.size(Iter.filter(transactions.vals(), func (t : Transaction) : Bool {
            switch (t.status) {
                case (#Processed) true;
                case (_) false;
            }
            }));
            return {processed; total = transactions.size()};
        };

        //Get transaction status
        public query func getTransactionStatus(index : Nat) : async TransactionStatus {
            transactions.get(index).status;
        };

        //Get all transactions
        public query func getTransactions(start: Nat, limit: Nat) : async [Transaction] {
            let size = transactions.size();
            if (start >= size) {
                return [];
            };
            let end = Nat.min(start + limit, size);
            let length = Nat.sub(end, start);
            let subBuffer = Buffer.subBuffer(transactions, start, length);
            Buffer.toArray(subBuffer);
        };
    }
}
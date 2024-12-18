import Types "../types/Common";
import BatchTransfer "./BatchTransfer";

module {
    public class AutoProcess(init: {
        processState: Text;
        isProcessed: Bool;
        totalAmountProcessed: Nat;
    }) {
        private var processState = init.processState;
        private var isProcessed = init.isProcessed;
        private var totalAmountProcessed = init.totalAmountProcessed;

        public func processSoftCapReached(
            batchTransfer: BatchTransfer,
            detail: Types.LaunchpadDetail,
            participants: Iter.Iter<(Text, Types.Participant)>
        ) : async Result.Result<(), Text> {
            if (processState != "NotStarted") {
                return #err("Process already started");
            };

            try {
                processState := "TokenDeployment";
                // Deploy token
                let tokenResult = await deployToken(detail);
                
                switch(tokenResult) {
                    case (#err(e)) return #err(e);
                    case (#ok(tokenId)) {
                        // Setup vesting và distributions
                        processState := "VestingSetup";
                        for ((address, participant) in participants) {
                            let amount = calculateTokenAmount(participant, detail);
                            batchTransfer.addToBatch(
                                Principal.fromText(address),
                                amount,
                                "token_distribution"
                            );
                        };

                        // Process distributions
                        let result = await batchTransfer.processBatch(tokenLedger);
                        
                        switch(result) {
                            case (#ok(_)) {
                                processState := "Completed";
                                isProcessed := true;
                                #ok()
                            };
                            case (#err(e)) #err(e);
                        };
                    };
                };
            } catch (e) {
                processState := "Failed";
                #err("Process failed: " # Error.message(e))
            }
        };

        // Getters
        public func getProcessState() : Text { processState };
        public func getTotalAmountProcessed() : Nat { totalAmountProcessed };
    }
}
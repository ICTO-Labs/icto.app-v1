// Process the launchpad setup if softcap is reached
import Types "../types/Common";
import Result "mo:base/Result";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
import ClaimTypes "../../claim_contract/types/Common";
import LockTypes "../../lock_deployer/Types";
import Error "mo:base/Error";
import ICPSwapLP "../types/ICPSwapLP";
import Array "mo:base/Array";
import HashMap "mo:base/HashMap";
import Text "mo:base/Text";
import TOKEN_DEPLOYER "canister:token_deployer";
import LOCK_DEPLOYER "canister:lock_deployer";
import CLAIM_CONTRACT "../services/ClaimService";
import ADD_LIQUIDITY "../services/AddLiquidityService";

module {
    public class AutoProcess() {
        private let TOTAL_AMOUNT_RAISED = 0;//Total amount raised
        private var PARTICIPANT_DISTRIBUTION : [ClaimTypes.Recipient] = [];//Participant distribution
        // Services
        private let tokenService = actor("...") : actor {
            deployToken : shared (Types.TokenInfo) -> async Result.Result<Text, Text>;
        };

        private let claimService = actor("...") : actor {
            createVesting : shared (Types.ClaimContract) -> async Result.Result<Text, Text>;
        };

        private let addLPService = actor("...") : actor {
            addLiquidity : shared (ICPSwapLP.AddLiquidityParams) -> async Result.Result<Text, Text>;
        };

        private let lockService = actor("...") : actor {
            lockLiquidity : shared (LockTypes.LockContract) -> async Result.Result<Text, Text>;
        };

        // Process states
        private var processState : {
            #NotStarted;
            #TokenDeployment;
            #VestingSetup; 
            #LiquiditySetup;
            #TeamVestingSetup;
            #Completed;
            #Failed;
        } = #NotStarted;

        //Process the participants and setup the vesting
        private func processParticipants(participants: [(Text, Types.Participant)], totalTokenAmount: Nat) : async [ClaimTypes.Recipient] {
            let _participants : HashMap.HashMap<Text, Types.Participant> = HashMap.fromIter(participants.vals(), 0, Text.equal, Text.hash);
            for ((k, v) in _participants.entries()) {
                let tokenAmount = calculateParticipantTokenAmount(v, totalTokenAmount);
                //Push the recipient to the array
                PARTICIPANT_DISTRIBUTION := Array.append(PARTICIPANT_DISTRIBUTION, [{
                    amount = tokenAmount;
                    address = k;
                    note = null;
                }]);
            };
            PARTICIPANT_DISTRIBUTION
        };

        public func processSoftCapReached(launchpad: Types.LaunchpadDetail, participants: [(Text, Types.Participant)]) : async Result.Result<(), Text> {
            if (processState != #NotStarted) {
                return #err("Process already started");
            };

            try {
                // 1. Deploy Token via Token Deployer
                processState := #TokenDeployment;
                let tokenResult = await TOKEN_DEPLOYER.install({
                    token_symbol = launchpad.saleToken.symbol;
                    token_name = launchpad.saleToken.name;
                    logo = launchpad.saleToken.logo;
                    transfer_fee = 0;
                    minting_account = { owner = Principal.fromText(launchpad.creator); subaccount = null };
                    fee_collector_account = null;
                    initial_balances = [];
                });
                switch(tokenResult) {
                    case (#err(e)) return #err(e);
                    case (#ok(tokenId)) {
                        // 2. Setup Participant Vesting
                        processState := #VestingSetup;
                        let _participants = await processParticipants(participants, launchpad.launchParams.sellAmount);
                        let vestingContract : Types.ClaimContract = {
                            title = launchpad.projectInfo.name # " Token Distribution";
                            description = "Token distribution for " # launchpad.projectInfo.name;
                            vesting = launchpad.distribution.fairlaunch.vesting;
                            total = launchpad.launchParams.sellAmount;
                            recipients = PARTICIPANT_DISTRIBUTION;
                        };
                        let vestingResult = await claimService.createVesting(vestingContract);
                        // 3. Add Liquidity to ICPSwap
                        let addLiquidityParams : ICPSwapLP.AddLiquidityParams = {
                            token0 = launchpad.saleToken.canisterId;
                            token1 = Principal.toText(tokenId);
                            amount0 = launchpad.distribution.liquidity.total;
                            amount1 = 0;
                        };
                        let addLiquidityResult = await addLPService.addLiquidity(addLiquidityParams);

                        // 4. Setup Liquidity Lock
                        processState := #LiquiditySetup;
                        let lockContract : LockTypes.LockContract = {
                            contractId = null;
                            created = Time.now();
                            durationTime = launchpad.distribution.liquidity.vesting.duration;
                            durationUnit = 1;
                            lockedTime = null;
                            meta = [];
                            poolId = "";
                            poolName = "";
                            positionId = 0;
                            positionOwner = Principal.fromText(launchpad.creator);//TODO: check if this is correct
                            provider = "";
                            status = "";
                            token0 = {
                                address = launchpad.saleToken.canisterId;
                                name = launchpad.saleToken.name;
                                standard = "ICRC1";
                            };
                            token1 = {
                                address = Principal.toText(tokenId);
                                name = launchpad.saleToken.name;
                                standard = "ICRC1";
                            };
                            unlockedTime = null;
                            version = "";
                            withdrawnTime = null;
                        };
                        let lockResult = await lockService.lockLiquidity(lockContract);

                        // 5. Setup Team Vesting (Purchase Token, default ICP)
                        processState := #TeamVestingSetup;
                        let teamVesting : Types.ClaimContract = {
                            title = launchpad.projectInfo.name # " Team Token Vesting";
                            description = "Team token vesting for " # launchpad.projectInfo.name;
                            vesting = launchpad.distribution.team.vesting;
                            total = launchpad.distribution.team.total;
                            recipients = launchpad.distribution.team.recipients;
                        };
                        let teamVestingResult = await claimService.createVesting(teamVesting);

                        processState := #Completed;
                        #ok()
                    };
                };
            } catch (e) {
                processState := #Failed;
                #err("Process failed: " # Error.message(e))
            }
        };

        //TODO: add the logic to process the participants
        private func calculateParticipantTokenAmount(participant: Types.Participant, totalTokenAmount: Nat) : Nat {
            //participant commit amount
            let participantCommitAmount = participant.totalAmount;
            let percentage = participantCommitAmount / TOTAL_AMOUNT_RAISED;
            let tokenAmount = percentage * totalTokenAmount;
            tokenAmount
        };

        public func getProcessStatus() : { state: Text; details: ?Text } {
            {
                state = switch(processState) {
                    case (#NotStarted) "Not Started";
                    case (#TokenDeployment) "Deploying Token";
                    case (#VestingSetup) "Setting up Vesting";
                    case (#LiquiditySetup) "Setting up Liquidity";
                    case (#TeamVestingSetup) "Setting up Team Vesting";
                    case (#Completed) "Completed";
                    case (#Failed) "Failed";
                };
                details = null;
            }
        };
    }
}
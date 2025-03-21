import Common "../launchpad/types/Common";
import Trie "mo:base/Trie";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Text "mo:base/Text";
import BackendUtils "../utils/Backend";
import Option "mo:base/Option";
import LaunchpadContract "./LaunchpadContract";
import Cycles "mo:base/ExperimentalCycles";
import Debug "mo:base/Debug";
import Time "mo:base/Time";
import Timer "mo:base/Timer";
import Prim "mo:⛔";

actor {
    // Save launchpad details
    stable var CYCLES_FOR_INSTALL = 300_000_000_000;
    stable var MIN_CYCLES_IN_DEPLOYER = 2_000_000_000_000;
    private var timerId: Nat = 0;
    private var GOVERNANCE_CANISTER_ID: ?Principal = null;


    // Update status of all launchpads
    private func updateAllLaunchpadStatuses() : async () {
        for ((id, index) in Trie.iter(launchpads)) {
            let updatedIndex = updateLaunchpadStatus(id, index);
            if (updatedIndex.status != index.status) {
                launchpads := Trie.put(launchpads, BackendUtils.keyT(id), Text.equal, updatedIndex).0;
            };
        };
    };

    // Update status of a specific launchpad
    private func updateLaunchpadStatus(id: Text, index: LaunchpadIndex) : LaunchpadIndex {
        let currentStatus = determineStatus(index.timeline);
        if (currentStatus != index.status) {
            {
                id = index.id;
                name = index.name;
                description = index.description;
                owner = index.owner;
                status = currentStatus;
                timeline = index.timeline;
                updatedAt = Time.now();
                createdAt = index.createdAt;
            }
        } else {
            index
        }
    };

    // Define launchpad statuses
    public type LaunchpadStatus = {
        #Upcoming;  // Not started
        #Live;      // Live
        #Ended;     // Ended
        #Claim;     // In claim phase
        #Completed; // Completed
    };

    // Define launchpad index
    private type LaunchpadIndex = {
        id: Text;  // Canister ID
        name: Text;
        description: Text;
        owner: Principal;
        timeline: Common.Timeline;
        status: LaunchpadStatus;
        updatedAt: Time.Time;
        createdAt: Time.Time;
    };

    // Main collections
    private stable var launchpads : Trie.Trie<Text, LaunchpadIndex> = Trie.empty();
    private stable var userParticipations : Trie.Trie<Text, [Text]> = Trie.empty();

    // Update governance canister
    public shared({ caller }) func updateGovernanceCanister(canisterId: ?Principal) : async Result.Result<(), Text> {
        if (not _hasPermission(caller)) {
            return #err("Unauthorized");
        };
        GOVERNANCE_CANISTER_ID := canisterId;
        #ok()
    };

    //Change cycles for install and min cycles in deployer
    public shared({ caller }) func updateCyclesForInstall(cycles: Nat) : async Result.Result<(), Text> {
        if (not _hasPermission(caller)) {
            return #err("Unauthorized");
        };
        CYCLES_FOR_INSTALL := cycles;
        #ok()
    };

    public shared({ caller }) func updateMinCyclesInDeployer(cycles: Nat) : async Result.Result<(), Text> {
        if (not _hasPermission(caller)) {
            return #err("Unauthorized");
        };
        MIN_CYCLES_IN_DEPLOYER := cycles;
        #ok()
    };

    private func _hasPermission(caller: Principal): Bool {
        return Prim.isController(caller) or (switch (GOVERNANCE_CANISTER_ID) {case (?id) { Principal.equal(caller, id) }; case (_) { false };});
    };

    public query func getGovernanceId() : async Result.Result<?Principal, Text> {
        return #ok(GOVERNANCE_CANISTER_ID);
    };


    // Add new launchpad
    public shared({ caller }) func createLaunchpad(detail: Common.LaunchpadDetail) : async Result.Result<Text, Text> {
        //Prevent anyone to create launchpad
        if (Principal.isAnonymous(caller)) {
            return #err("Unauthorized");
        };

        let _cycleBalance = Cycles.balance();
        if (_cycleBalance < CYCLES_FOR_INSTALL + MIN_CYCLES_IN_DEPLOYER) {
            return #err("Not enough cycles in deployer, balance: "# debug_show(_cycleBalance) #"T");
        };

        Cycles.add<system>(CYCLES_FOR_INSTALL);
        let ContractActor = await LaunchpadContract.LaunchpadCanister();
        let launchpadId = Principal.fromActor(ContractActor);
        let launchpadIdTxt = Principal.toText(launchpadId);

        //Step 2: Installing...
        let _installResult = await ContractActor.install(detail, []);
        switch (_installResult) {
            case (#err(err)) {
                return #err(err);
            };
            case (#ok(_)) {
                // Create new index, remove logo and banner
                let index : LaunchpadIndex = {
                    id = launchpadIdTxt;
                    name = detail.projectInfo.name;
                    description = detail.projectInfo.description;
                    owner = caller;
                    timeline = detail.timeline;
                    status = #Upcoming; // Default status is upcoming
                    updatedAt = Time.now();
                    createdAt = Time.now();
                };
                launchpads := Trie.put(launchpads, BackendUtils.keyT(launchpadIdTxt), Text.equal, index).0;
                #ok(launchpadIdTxt)
            };
        };
    };

    // Helper function to determine status based on timeline
    private func determineStatus(timeline: Common.Timeline) : LaunchpadStatus {
        let now = Time.now();
        if (now < timeline.startTime) {
            #Upcoming
        } else if (now < timeline.endTime) {
            #Live
        } else if (now < timeline.claimTime) {
            #Ended
        } else if (now < timeline.listingTime) {
            #Claim
        } else {
            #Completed
        };
    };

    // Query launchpads by status
    public query func getLaunchpadsByStatus(status: LaunchpadStatus) : async [(Text, LaunchpadIndex)] {
        let now = Time.now();
        let result = Buffer.Buffer<(Text, LaunchpadIndex)>(0);
        
        for ((id, index) in Trie.iter(launchpads)) {
            if (index.status == status) {
                result.add((id, index));
            };
        };
        
        Buffer.toArray(result)
    };

    // Query all launchpads with current status
    public query func getAllLaunchpads() : async [(Text, LaunchpadIndex, LaunchpadStatus)] {
        let result = Buffer.Buffer<(Text, LaunchpadIndex, LaunchpadStatus)>(0);
        
        for ((id, index) in Trie.iter(launchpads)) {
            let currentStatus = determineStatus(index.timeline);
            result.add((id, index, currentStatus));
        };
        
        Buffer.toArray(result)
    };

    // Query launchpads where user participated
    public query func getUserParticipations(userId: Text) : async {
        participatedLaunchpads: [(Text, LaunchpadIndex, LaunchpadStatus)];
    } {
        let userLaunchpads = Option.get(Trie.get(userParticipations, BackendUtils.keyT(userId), Text.equal), []);
        let result = Buffer.Buffer<(Text, LaunchpadIndex, LaunchpadStatus)>(0);
        
        for (id in userLaunchpads.vals()) {
            switch(Trie.get(launchpads, BackendUtils.keyT(id), Text.equal)) {
                case (?index) {
                    let currentStatus = determineStatus(index.timeline);
                    result.add((id, index, currentStatus));
                };
                case null {};
            };
        };
        
        {
            participatedLaunchpads = Buffer.toArray(result);
        }
    };

    // Update user participation (called by launchpad contract)
    public shared({ caller }) func updateUserParticipation(userId: Text) : async Result.Result<(), Text> {
        let launchpadId = Principal.toText(caller);
        switch (Trie.get(launchpads, BackendUtils.keyT(launchpadId), Text.equal)) {
            case (null) {
                return #err("Launchpad not found");
            };
            case (?_) {
                let existing = Trie.get(userParticipations, BackendUtils.keyT(userId), Text.equal);
                let updatedLaunchpads = switch (existing) {
                    case (null) {[launchpadId]};
                    case (?existing) {
                        if (Array.find<Text>(existing, func(x) { x == launchpadId }) == null) {
                            Array.append(existing, [launchpadId])
                        } else {
                            existing
                        };
                    };
                };
                userParticipations := Trie.put(userParticipations, BackendUtils.keyT(userId), Text.equal, updatedLaunchpads).0;
                #ok()
            };
        };
    };

    //System timer
    timerId := Timer.recurringTimer<system>(#seconds(60), updateAllLaunchpadStatuses);
}

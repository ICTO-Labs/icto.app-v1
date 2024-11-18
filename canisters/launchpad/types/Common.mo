import Time "mo:base/Time";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Bool "mo:base/Bool";

module {
    public type Participant = {
        commit : Nat;//Total times committed
        totalAmount : Nat;//in ICP E8S
        lastDeposit: ?Time.Time;
    };

    public type Transaction = {
        participant: Text;
        amount: Nat;//in ICP E8S
        time: Time.Time;
        method: Text;//deposit, refund
        txId: ?Nat;
    };
    public type TokenInfo = {
        name : Text;
        symbol : Text;
        decimals : Nat;
        transferFee: Nat;
        metadata : ?Blob;
        logo: Text;
        canisterId: Text;
    };

    //Timeline for the launchpad
    public type Timeline = {
        createdTime: Time.Time;
        startTime: Time.Time;
        endTime: Time.Time;
        claimTime: Time.Time;
        listingTime: Time.Time;
    };

    //Launchpad parameters
    public type LaunchParams = {
        sellAmount : Nat;
        softCap : Nat;
        hardCap : Nat;
        minimumAmount : Nat;
        maximumAmount : Nat;
    };

    //Tokenomic settings
    public type Tokenomic = {
        title: Text;
        value: Nat;
    };
    
    public type AffiliateInfo = {
        refBy: Text;//Referral by address
        participant: Text;
        amount: Nat;
        time: Time.Time;
    };
    public type AffiliateStats = {
        volume: Nat;
        projectedReward: Nat;
        refCount: Nat;
    };

    //Project info
    public type ProjectInfo = {
        name: Text;
        description: Text;
        isAudited: Bool;
        isVerified: Bool;
        links: ?[Text];
        logo: Text;
        banner: ?Text;
        metadata: ?[(Text, Text)];
    };

    public type VestingInfo = {
        cliff: Nat;//Seconds
        duration: Nat;//Seconds
        unlockFrequency: Nat;//0: unlock immediately, 1: fully unlock after, others: unlock after each period
    };
    public type Recipient = {
        amount: Nat;
        address: Text;
        note: ?Text;
    };
    public type ClaimContract = {
        title: Text;
        description: Text;
        vesting: VestingInfo;
        total: Nat;//Total Amount
        recipients: [Recipient];
    };
    public type FixClaimContract = {
        title: Text;
        description: Text;
        vesting: VestingInfo;
        total: Nat;//Total Amount
    };

    public type Distribution = {
        fairlaunch: FixClaimContract;
        liquidity: FixClaimContract;
        team: ClaimContract;
        others: [ClaimContract];
    };

    public type LaunchpadDetail = {
        // cid : Text;
        projectInfo : ProjectInfo;
        timeline : Timeline;
        purchaseToken : TokenInfo;//Token used for purchase - default ICP
        saleToken: TokenInfo;//Only ICRC standard token
        launchParams : LaunchParams;
        distribution: Distribution;
        creator : Text;
        affiliate: Nat;//Percent
        fee: Nat;//Fee (percent) for the success launch
        restrictedArea: ?[Text];//Restricted area
    };

    public type LaunchpadStatus = {
        totalAmountCommitted: Nat;
        totalParticipants: Nat;
        totalTransactions: Nat;
        whitelistEnabled: Bool;
        status: Text;
        affiliate: Nat;
        cycle: Nat;
        installed: Bool;
        totalAffiliateVolume: Nat;
        affiliateRewardPool: Nat;
        refererTransaction: Nat;
    };
}
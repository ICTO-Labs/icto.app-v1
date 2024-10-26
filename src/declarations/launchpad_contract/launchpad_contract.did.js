export const idlFactory = ({ IDL }) => {
  const Result = IDL.Variant({ 'ok' : IDL.Bool, 'err' : IDL.Text });
  const AffiliateStats = IDL.Record({
    'projectedReward' : IDL.Nat,
    'volume' : IDL.Nat,
    'refCount' : IDL.Nat,
  });
  const Time = IDL.Int;
  const Participant = IDL.Record({
    'lastDeposit' : IDL.Opt(Time),
    'totalAmount' : IDL.Nat,
    'commit' : IDL.Nat,
  });
  const Transaction = IDL.Record({
    'method' : IDL.Text,
    'time' : Time,
    'txId' : IDL.Opt(IDL.Nat),
    'participant' : IDL.Text,
    'amount' : IDL.Nat,
  });
  const TokenInfo = IDL.Record({
    'decimals' : IDL.Nat,
    'metadata' : IDL.Opt(IDL.Vec(IDL.Nat8)),
    'logo' : IDL.Text,
    'name' : IDL.Text,
    'transferFee' : IDL.Nat,
    'symbol' : IDL.Text,
    'canisterId' : IDL.Text,
  });
  const ProjectInfo = IDL.Record({
    'metadata' : IDL.Opt(IDL.Vec(IDL.Tuple(IDL.Text, IDL.Text))),
    'logo' : IDL.Text,
    'name' : IDL.Text,
    'banner' : IDL.Opt(IDL.Text),
    'description' : IDL.Text,
    'isAudited' : IDL.Bool,
    'links' : IDL.Opt(IDL.Vec(IDL.Text)),
    'isVerified' : IDL.Bool,
  });
  const LaunchParams = IDL.Record({
    'softCap' : IDL.Nat,
    'sellAmount' : IDL.Nat,
    'hardCap' : IDL.Nat,
    'maximumAmount' : IDL.Nat,
    'minimumAmount' : IDL.Nat,
  });
  const VestingInfo = IDL.Record({
    'duration' : IDL.Nat,
    'unlockFrequency' : IDL.Nat,
    'cliff' : IDL.Nat,
  });
  const Recipient = IDL.Record({
    'note' : IDL.Opt(IDL.Text),
    'address' : IDL.Text,
    'amount' : IDL.Nat,
  });
  const ClaimContract = IDL.Record({
    'title' : IDL.Text,
    'vesting' : VestingInfo,
    'total' : IDL.Nat,
    'description' : IDL.Text,
    'recipients' : IDL.Vec(Recipient),
  });
  const FixClaimContract = IDL.Record({
    'title' : IDL.Text,
    'vesting' : VestingInfo,
    'total' : IDL.Nat,
    'description' : IDL.Text,
  });
  const Distribution = IDL.Record({
    'team' : ClaimContract,
    'liquidity' : FixClaimContract,
    'others' : IDL.Vec(ClaimContract),
    'fairlaunch' : FixClaimContract,
  });
  const Timeline = IDL.Record({
    'startTime' : Time,
    'endTime' : Time,
    'createdTime' : Time,
    'claimTime' : Time,
    'listingTime' : Time,
  });
  const LaunchpadDetail = IDL.Record({
    'fee' : IDL.Nat,
    'saleToken' : TokenInfo,
    'creator' : IDL.Text,
    'projectInfo' : ProjectInfo,
    'launchParams' : LaunchParams,
    'restrictedArea' : IDL.Opt(IDL.Vec(IDL.Text)),
    'purchaseToken' : TokenInfo,
    'affiliate' : IDL.Nat,
    'distribution' : Distribution,
    'timeline' : Timeline,
  });
  const LaunchpadStatus = IDL.Record({
    'status' : IDL.Text,
    'totalAmountCommitted' : IDL.Nat,
    'totalParticipants' : IDL.Nat,
    'installed' : IDL.Bool,
    'cycle' : IDL.Nat,
    'affiliateRewardPool' : IDL.Nat,
    'refererTransaction' : IDL.Nat,
    'whitelistEnabled' : IDL.Bool,
    'affiliate' : IDL.Nat,
    'totalAffiliateVolume' : IDL.Nat,
    'totalTransactions' : IDL.Nat,
  });
  const LaunchpadCanister = IDL.Service({
    'checkEligibleToCommit' : IDL.Func([], [Result], []),
    'commit' : IDL.Func([IDL.Nat, IDL.Opt(IDL.Text)], [Result], []),
    'getAffiliateStats' : IDL.Func(
        [IDL.Text],
        [IDL.Opt(AffiliateStats)],
        ['query'],
      ),
    'getParticipantInfo' : IDL.Func([IDL.Text], [Participant], []),
    'getRefundList' : IDL.Func([], [IDL.Vec(Transaction)], []),
    'getTopAffiliates' : IDL.Func(
        [IDL.Nat],
        [IDL.Vec(IDL.Tuple(IDL.Text, AffiliateStats))],
        ['query'],
      ),
    'getTransactionList' : IDL.Func([], [IDL.Vec(Transaction)], []),
    'install' : IDL.Func([LaunchpadDetail, IDL.Vec(IDL.Text)], [Result], []),
    'launchpadInfo' : IDL.Func([], [LaunchpadDetail], []),
    'reinstall' : IDL.Func([], [], []),
    'status' : IDL.Func([], [LaunchpadStatus], []),
  });
  return LaunchpadCanister;
};
export const init = ({ IDL }) => { return []; };

export const idlFactory = ({ IDL }) => {
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
  const Time = IDL.Int;
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
  const Result_2 = IDL.Variant({ 'ok' : IDL.Text, 'err' : IDL.Text });
  const LaunchpadStatus = IDL.Variant({
    'Ended' : IDL.Null,
    'Live' : IDL.Null,
    'Claim' : IDL.Null,
    'Completed' : IDL.Null,
    'Upcoming' : IDL.Null,
  });
  const LaunchpadIndex = IDL.Record({
    'id' : IDL.Text,
    'status' : LaunchpadStatus,
    'owner' : IDL.Principal,
    'name' : IDL.Text,
    'createdAt' : Time,
    'description' : IDL.Text,
    'updatedAt' : Time,
    'timeline' : Timeline,
  });
  const Result_1 = IDL.Variant({
    'ok' : IDL.Opt(IDL.Principal),
    'err' : IDL.Text,
  });
  const Result = IDL.Variant({ 'ok' : IDL.Null, 'err' : IDL.Text });
  return IDL.Service({
    'createLaunchpad' : IDL.Func([LaunchpadDetail], [Result_2], []),
    'getAllLaunchpads' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(IDL.Text, LaunchpadIndex, LaunchpadStatus))],
        ['query'],
      ),
    'getGovernanceId' : IDL.Func([], [Result_1], ['query']),
    'getLaunchpadsByStatus' : IDL.Func(
        [LaunchpadStatus],
        [IDL.Vec(IDL.Tuple(IDL.Text, LaunchpadIndex))],
        ['query'],
      ),
    'getUserParticipations' : IDL.Func(
        [IDL.Text],
        [
          IDL.Record({
            'participatedLaunchpads' : IDL.Vec(
              IDL.Tuple(IDL.Text, LaunchpadIndex, LaunchpadStatus)
            ),
          }),
        ],
        ['query'],
      ),
    'updateGovernanceCanister' : IDL.Func(
        [IDL.Opt(IDL.Principal)],
        [Result],
        [],
      ),
    'updateUserParticipation' : IDL.Func([IDL.Text], [Result], []),
  });
};
export const init = ({ IDL }) => { return []; };

export const idlFactory = ({ IDL }) => {
  const DistributionType = IDL.Variant({
    'Public' : IDL.Null,
    'Whitelist' : IDL.Null,
  });
  const Time = IDL.Int;
  const VestingType = IDL.Variant({
    'Standard' : IDL.Null,
    'Single' : IDL.Null,
  });
  const Recipient = IDL.Record({
    'note' : IDL.Opt(IDL.Text),
    'address' : IDL.Text,
    'amount' : IDL.Nat,
  });
  const TokenInfo = IDL.Record({
    'fee' : IDL.Nat,
    'decimals' : IDL.Nat,
    'name' : IDL.Text,
    'standard' : IDL.Text,
    'symbol' : IDL.Text,
    'canisterId' : IDL.Text,
  });
  const Result = IDL.Variant({ 'ok' : IDL.Bool, 'err' : IDL.Text });
  const Result_1 = IDL.Variant({ 'ok' : IDL.Nat, 'err' : IDL.Text });
  const ClaimRecord = IDL.Record({
    'txId' : IDL.Nat,
    'claimedAt' : Time,
    'amount' : IDL.Nat,
  });
  const ContractStatus = IDL.Variant({
    'CANCELED' : IDL.Null,
    'PAUSED' : IDL.Null,
    'PENDING' : IDL.Null,
    'STARTED' : IDL.Null,
    'NOT_STARTED' : IDL.Null,
    'ENDED' : IDL.Null,
  });
  const ContractData = IDL.Record({
    'startTime' : Time,
    'status' : ContractStatus,
    'distributionType' : DistributionType,
    'durationTime' : IDL.Nat,
    'durationUnit' : IDL.Nat,
    'title' : IDL.Text,
    'created' : Time,
    'lockDuration' : IDL.Nat,
    'autoTransfer' : IDL.Bool,
    'requiredScore' : IDL.Nat,
    'owner' : IDL.Principal,
    'isStarted' : IDL.Bool,
    'startNow' : IDL.Bool,
    'blockId' : IDL.Nat,
    'isPaused' : IDL.Bool,
    'totalRecipients' : IDL.Nat,
    'totalClaimedAmount' : IDL.Nat,
    'description' : IDL.Text,
    'cliffTime' : IDL.Nat,
    'cliffUnit' : IDL.Nat,
    'vestingType' : VestingType,
    'maxRecipients' : IDL.Nat,
    'isCanceled' : IDL.Bool,
    'totalAmount' : IDL.Nat,
    'allowTransfer' : IDL.Bool,
    'tokenInfo' : TokenInfo,
    'initialUnlockPercentage' : IDL.Nat,
    'unlockSchedule' : IDL.Nat,
    'tokenPerRecipient' : IDL.Nat,
    'cyclesBalance' : IDL.Nat,
    'allowCancel' : IDL.Bool,
  });
  const Recipient__1 = IDL.Record({
    'principal' : IDL.Principal,
    'note' : IDL.Opt(IDL.Text),
    'amount' : IDL.Nat,
  });
  const RecipientClaimInfo = IDL.Record({
    'claimedAmount' : IDL.Nat,
    'remainingAmount' : IDL.Nat,
    'claimInterval' : IDL.Nat,
    'recipient' : Recipient__1,
    'vestingCliff' : IDL.Nat,
    'claimHistory' : IDL.Vec(ClaimRecord),
    'lastClaimedTime' : Time,
    'vestingDuration' : IDL.Nat,
  });
  const RecipientClaim = IDL.Record({
    'claimedAmount' : IDL.Nat,
    'remainingAmount' : IDL.Nat,
    'claimInterval' : IDL.Nat,
    'recipient' : Recipient__1,
    'vestingCliff' : IDL.Nat,
    'lastClaimedTime' : Time,
    'vestingDuration' : IDL.Nat,
  });
  const Contract = IDL.Service({
    'addRecipient' : IDL.Func(
        [IDL.Principal, IDL.Nat, IDL.Nat, IDL.Nat, IDL.Nat],
        [Result],
        [],
      ),
    'cancelTimer' : IDL.Func([], [], []),
    'checkClaimable' : IDL.Func([IDL.Principal], [IDL.Nat], ['query']),
    'checkEligibility' : IDL.Func([], [Result], []),
    'claim' : IDL.Func([], [Result_1], []),
    'getClaimHistory' : IDL.Func(
        [IDL.Principal],
        [IDL.Opt(IDL.Vec(ClaimRecord))],
        ['query'],
      ),
    'getContractInfo' : IDL.Func([], [ContractData], ['query']),
    'getCounter' : IDL.Func([], [IDL.Nat], ['query']),
    'getRecipientClaimInfo' : IDL.Func(
        [IDL.Principal],
        [IDL.Opt(RecipientClaimInfo)],
        ['query'],
      ),
    'getRecipients' : IDL.Func([IDL.Nat], [IDL.Vec(RecipientClaim)], ['query']),
    'getTimePeriod' : IDL.Func([], [IDL.Nat], ['query']),
    'init' : IDL.Func([], [], []),
    'setRequiredScore' : IDL.Func([IDL.Nat], [Result], []),
    'startContract' : IDL.Func([], [Result], []),
    'transferOwnership' : IDL.Func([IDL.Principal], [Result], []),
  });
  return Contract;
};
export const init = ({ IDL }) => {
  const DistributionType = IDL.Variant({
    'Public' : IDL.Null,
    'Whitelist' : IDL.Null,
  });
  const Time = IDL.Int;
  const VestingType = IDL.Variant({
    'Standard' : IDL.Null,
    'Single' : IDL.Null,
  });
  const Recipient = IDL.Record({
    'note' : IDL.Opt(IDL.Text),
    'address' : IDL.Text,
    'amount' : IDL.Nat,
  });
  const TokenInfo = IDL.Record({
    'fee' : IDL.Nat,
    'decimals' : IDL.Nat,
    'name' : IDL.Text,
    'standard' : IDL.Text,
    'symbol' : IDL.Text,
    'canisterId' : IDL.Text,
  });
  return [
    IDL.Record({
      'startTime' : IDL.Nat,
      'distributionType' : DistributionType,
      'durationTime' : IDL.Nat,
      'durationUnit' : IDL.Nat,
      'title' : IDL.Text,
      'created' : Time,
      'autoTransfer' : IDL.Bool,
      'owner' : IDL.Principal,
      'startNow' : IDL.Bool,
      'blockId' : IDL.Nat,
      'description' : IDL.Text,
      'cliffTime' : IDL.Nat,
      'cliffUnit' : IDL.Nat,
      'vestingType' : VestingType,
      'maxRecipients' : IDL.Nat,
      'recipients' : IDL.Opt(IDL.Vec(Recipient)),
      'totalAmount' : IDL.Nat,
      'tokenInfo' : TokenInfo,
      'initialUnlockPercentage' : IDL.Nat,
      'unlockSchedule' : IDL.Nat,
      'allowCancel' : IDL.Bool,
    }),
  ];
};

export const idlFactory = ({ IDL }) => {
  const Time = IDL.Int;
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
    'claimedAt' : IDL.Nat,
    'amount' : IDL.Nat,
  });
  const ContractData = IDL.Record({
    'startTime' : IDL.Nat,
    'title' : IDL.Text,
    'created' : Time,
    'lockDuration' : IDL.Nat,
    'owner' : IDL.Principal,
    'isStarted' : IDL.Bool,
    'isPaused' : IDL.Bool,
    'totalRecipients' : IDL.Nat,
    'totalClaimedAmount' : IDL.Nat,
    'description' : IDL.Text,
    'isCanceled' : IDL.Bool,
    'totalAmount' : IDL.Nat,
    'allowTransfer' : IDL.Bool,
    'tokenInfo' : TokenInfo,
    'unlockSchedule' : IDL.Nat,
    'cyclesBalance' : IDL.Nat,
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
    'lastClaimedTime' : IDL.Nat,
    'vestingDuration' : IDL.Nat,
  });
  const RecipientClaim = IDL.Record({
    'claimedAmount' : IDL.Nat,
    'remainingAmount' : IDL.Nat,
    'claimInterval' : IDL.Nat,
    'recipient' : Recipient__1,
    'vestingCliff' : IDL.Nat,
    'lastClaimedTime' : IDL.Nat,
    'vestingDuration' : IDL.Nat,
  });
  const Contract = IDL.Service({
    'addRecipient' : IDL.Func(
        [IDL.Principal, IDL.Nat, IDL.Nat, IDL.Nat, IDL.Nat],
        [Result],
        [],
      ),
    'checkClaimable' : IDL.Func([IDL.Principal], [IDL.Nat], ['query']),
    'claim' : IDL.Func([], [Result_1], []),
    'getClaimHistory' : IDL.Func(
        [IDL.Principal],
        [IDL.Opt(IDL.Vec(ClaimRecord))],
        ['query'],
      ),
    'getContractInfo' : IDL.Func([], [ContractData], ['query']),
    'getRecipientClaimInfo' : IDL.Func(
        [IDL.Principal],
        [IDL.Opt(RecipientClaimInfo)],
        ['query'],
      ),
    'getRecipients' : IDL.Func([], [IDL.Vec(RecipientClaim)], ['query']),
    'getTimePeriod' : IDL.Func([], [IDL.Nat], ['query']),
    'startContract' : IDL.Func([], [Result], []),
    'transferOwnership' : IDL.Func([IDL.Principal], [Result], []),
  });
  return Contract;
};
export const init = ({ IDL }) => {
  const Time = IDL.Int;
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
      'startTime' : Time,
      'canChange' : IDL.Text,
      'canCancel' : IDL.Text,
      'durationTime' : IDL.Nat,
      'durationUnit' : IDL.Nat,
      'title' : IDL.Text,
      'created' : Time,
      'owner' : IDL.Principal,
      'startNow' : IDL.Bool,
      'description' : IDL.Text,
      'canView' : IDL.Text,
      'cliffTime' : IDL.Nat,
      'cliffUnit' : IDL.Nat,
      'recipients' : IDL.Vec(Recipient),
      'totalAmount' : IDL.Nat,
      'tokenInfo' : TokenInfo,
      'unlockSchedule' : IDL.Nat,
      'unlockedAmount' : IDL.Nat,
    }),
  ];
};

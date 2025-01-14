export const idlFactory = ({ IDL }) => {
  const Result = IDL.Variant({ 'ok' : IDL.Null, 'err' : IDL.Text });
  const Provider = IDL.Variant({
    'Sonic' : IDL.Null,
    'ICPEx' : IDL.Null,
    'KongSwap' : IDL.Null,
    'ICPSwap' : IDL.Null,
  });
  const TokenInfo = IDL.Record({
    'fee' : IDL.Nat,
    'decimals' : IDL.Nat8,
    'name' : IDL.Text,
    'standard' : IDL.Text,
    'symbol' : IDL.Text,
    'canisterId' : IDL.Principal,
  });
  const ProviderInfo = IDL.Variant({
    'Sonic' : IDL.Record({ 'poolType' : IDL.Text, 'lpTokenId' : IDL.Text }),
    'ICPEx' : IDL.Record({ 'poolVersion' : IDL.Text, 'poolType' : IDL.Text }),
    'KongSwap' : IDL.Record({ 'poolData' : IDL.Text }),
    'ICPSwap' : IDL.Record({
      'fee' : IDL.Nat,
      'tickUpper' : IDL.Int,
      'tickLower' : IDL.Int,
    }),
  });
  const LPInfo__1 = IDL.Record({
    'provider' : Provider,
    'token0' : TokenInfo,
    'token1' : TokenInfo,
    'providerInfo' : ProviderInfo,
    'poolName' : IDL.Text,
    'poolId' : IDL.Text,
  });
  const Result_1 = IDL.Variant({ 'ok' : IDL.Nat, 'err' : IDL.Text });
  const Time = IDL.Int;
  const LockStatus = IDL.Variant({
    'Unlocked' : IDL.Null,
    'Withdrawn' : IDL.Null,
    'Locked' : IDL.Null,
    'Created' : IDL.Null,
  });
  const Transaction = IDL.Record({
    'to' : IDL.Principal,
    'method' : IDL.Text,
    'from' : IDL.Principal,
    'time' : Time,
    'txId' : IDL.Opt(IDL.Nat),
    'positionId' : IDL.Opt(IDL.Nat),
    'amount' : IDL.Opt(IDL.Nat),
  });
  const LPInfo = IDL.Record({
    'provider' : Provider,
    'token0' : TokenInfo,
    'token1' : TokenInfo,
    'providerInfo' : ProviderInfo,
    'poolName' : IDL.Text,
    'poolId' : IDL.Text,
  });
  const LPLockContract = IDL.Record({
    'id' : IDL.Nat,
    'startTime' : Time,
    'status' : LockStatus,
    'created' : Time,
    'duration' : IDL.Nat,
    'endTime' : Time,
    'owner' : IDL.Principal,
    'lockedTime' : IDL.Opt(Time),
    'meta' : IDL.Vec(IDL.Text),
    'positionId' : IDL.Nat,
    'withdrawnTime' : IDL.Opt(Time),
    'unlockedTime' : IDL.Opt(Time),
    'transactions' : IDL.Vec(Transaction),
    'lpInfo' : LPInfo,
  });
  const LedgerMeta = IDL.Record({
    'fee' : IDL.Nat,
    'decimals' : IDL.Nat,
    'name' : IDL.Text,
    'symbol' : IDL.Text,
  });
  const PendingWithdrawal = IDL.Record({
    'to' : IDL.Principal,
    'time' : Time,
    'detail' : IDL.Text,
    'caller' : IDL.Principal,
    'amount' : IDL.Nat,
    'contractId' : IDL.Nat,
  });
  const TokenLockContract = IDL.Record({
    'id' : IDL.Nat,
    'startTime' : Time,
    'status' : LockStatus,
    'created' : Time,
    'token' : TokenInfo,
    'duration' : IDL.Nat,
    'endTime' : Time,
    'owner' : IDL.Principal,
    'lockedTime' : IDL.Opt(Time),
    'autoWithdraw' : IDL.Bool,
    'withdrawnTime' : IDL.Opt(Time),
    'unlockedTime' : IDL.Opt(Time),
    'transactions' : IDL.Vec(Transaction),
    'amount' : IDL.Nat,
  });
  const Duration = IDL.Record({
    'hours' : IDL.Nat,
    'days' : IDL.Nat,
    'minutes' : IDL.Nat,
    'seconds' : IDL.Nat,
  });
  const UnlockEvent = IDL.Record({
    'startTime' : Time,
    'lockRatio' : IDL.Float64,
    'endTime' : Time,
    'remainingTime' : Duration,
    'tokenInfo' : TokenInfo,
    'amount' : IDL.Nat,
    'contractId' : IDL.Nat,
  });
  const TokenLockService = IDL.Service({
    'addAdmin' : IDL.Func([IDL.Principal], [Result], []),
    'addSupportedLP' : IDL.Func([IDL.Text, LPInfo__1], [Result], []),
    'addSupportedToken' : IDL.Func([IDL.Text], [Result], []),
    'createLPLock' : IDL.Func(
        [IDL.Text, IDL.Nat, IDL.Nat, IDL.Vec(IDL.Text)],
        [Result_1],
        [],
      ),
    'createTokenLock' : IDL.Func(
        [IDL.Principal, IDL.Nat, IDL.Nat, IDL.Bool],
        [Result_1],
        [],
      ),
    'getLPLockDetails' : IDL.Func(
        [IDL.Nat],
        [IDL.Opt(LPLockContract)],
        ['query'],
      ),
    'getLPLocks' : IDL.Func([IDL.Text], [IDL.Vec(LPLockContract)], ['query']),
    'getLedgerMeta' : IDL.Func([IDL.Principal], [LedgerMeta], []),
    'getPendingWithdrawals' : IDL.Func([], [IDL.Vec(PendingWithdrawal)], []),
    'getSupportedTokens' : IDL.Func([], [IDL.Vec(IDL.Text)], ['query']),
    'getTokenLockDetails' : IDL.Func(
        [IDL.Nat],
        [IDL.Opt(TokenLockContract)],
        ['query'],
      ),
    'getTokenLocks' : IDL.Func(
        [IDL.Principal],
        [IDL.Vec(TokenLockContract)],
        ['query'],
      ),
    'getTokenUpcomingUnlocks' : IDL.Func(
        [IDL.Principal],
        [IDL.Opt(UnlockEvent)],
        ['query'],
      ),
    'getTotalValueLocked' : IDL.Func([IDL.Principal], [IDL.Nat], ['query']),
    'isSupportedStandards' : IDL.Func([IDL.Principal], [IDL.Bool], []),
    'removeAdmin' : IDL.Func([IDL.Principal], [Result], []),
    'removeSupportedToken' : IDL.Func([IDL.Text], [Result], []),
    'resolvePendingWithdrawal' : IDL.Func([IDL.Nat], [Result], []),
    'withdrawLP' : IDL.Func([IDL.Nat], [Result], []),
    'withdrawToken' : IDL.Func([IDL.Nat], [Result], []),
  });
  return TokenLockService;
};
export const init = ({ IDL }) => { return []; };

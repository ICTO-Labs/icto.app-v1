export const idlFactory = ({ IDL }) => {
  const Time = IDL.Int;
  const TokenInfo = IDL.Record({
    'name' : IDL.Text,
    'address' : IDL.Text,
    'standard' : IDL.Text,
  });
  const LockContract = IDL.Record({
    'status' : IDL.Text,
    'durationTime' : IDL.Nat,
    'durationUnit' : IDL.Nat,
    'created' : Time,
    'provider' : IDL.Text,
    'lockedTime' : IDL.Opt(Time),
    'meta' : IDL.Vec(IDL.Text),
    'positionId' : IDL.Nat,
    'version' : IDL.Text,
    'token0' : TokenInfo,
    'token1' : TokenInfo,
    'positionOwner' : IDL.Principal,
    'unlockedTime' : IDL.Opt(Time),
    'poolName' : IDL.Text,
    'contractId' : IDL.Opt(IDL.Text),
    'poolId' : IDL.Text,
  });
  const Result = IDL.Variant({ 'ok' : IDL.Bool, 'err' : IDL.Text });
  const TransferRecord = IDL.Record({
    'to' : IDL.Principal,
    'method' : IDL.Text,
    'from' : IDL.Principal,
    'time' : Time,
    'positionId' : IDL.Nat,
  });
  const Contract = IDL.Service({
    'cycleBalance' : IDL.Func([], [IDL.Nat], ['query']),
    'fallback_send' : IDL.Func([IDL.Principal, IDL.Nat], [Result], []),
    'getContract' : IDL.Func([], [LockContract], ['query']),
    'getDeployer' : IDL.Func([], [IDL.Principal], ['query']),
    'getInitContract' : IDL.Func([], [LockContract], ['query']),
    'getLockedPosition' : IDL.Func([], [IDL.Nat], ['query']),
    'getTransactions' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(IDL.Principal, TransferRecord))],
        [],
      ),
    'getVersion' : IDL.Func([], [IDL.Text], ['query']),
    'increaseDuration' : IDL.Func([IDL.Nat, IDL.Nat], [Result], []),
    'verify' : IDL.Func([], [Result], []),
    'withdraw' : IDL.Func([], [Result], []),
  });
  return Contract;
};
export const init = ({ IDL }) => {
  const Time = IDL.Int;
  const TokenInfo = IDL.Record({
    'name' : IDL.Text,
    'address' : IDL.Text,
    'standard' : IDL.Text,
  });
  const LockContract = IDL.Record({
    'status' : IDL.Text,
    'durationTime' : IDL.Nat,
    'durationUnit' : IDL.Nat,
    'created' : Time,
    'provider' : IDL.Text,
    'lockedTime' : IDL.Opt(Time),
    'meta' : IDL.Vec(IDL.Text),
    'positionId' : IDL.Nat,
    'version' : IDL.Text,
    'token0' : TokenInfo,
    'token1' : TokenInfo,
    'positionOwner' : IDL.Principal,
    'unlockedTime' : IDL.Opt(Time),
    'poolName' : IDL.Text,
    'contractId' : IDL.Opt(IDL.Text),
    'poolId' : IDL.Text,
  });
  return [LockContract];
};

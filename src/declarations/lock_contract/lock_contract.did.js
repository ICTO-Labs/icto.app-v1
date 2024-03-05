export const idlFactory = ({ IDL }) => {
  const Time = IDL.Int;
  const LockContract = IDL.Record({
    'status' : IDL.Text,
    'durationTime' : IDL.Nat,
    'durationUnit' : IDL.Nat,
    'created' : Time,
    'provider' : IDL.Text,
    'lockedTime' : IDL.Opt(Time),
    'meta' : IDL.Vec(IDL.Text),
    'positionId' : IDL.Nat,
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
    'checkTransaction' : IDL.Func([IDL.Principal, IDL.Nat], [Result], []),
    'claim' : IDL.Func([], [Result], []),
    'cycleBalance' : IDL.Func([], [IDL.Nat], ['query']),
    'getContract' : IDL.Func([], [LockContract], ['query']),
    'getDeployer' : IDL.Func([], [IDL.Principal], ['query']),
    'getInitContract' : IDL.Func([], [LockContract], ['query']),
    'getLockedPosition' : IDL.Func([], [IDL.Nat], ['query']),
    'getTransactions' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(IDL.Principal, TransferRecord))],
        [],
      ),
    'send' : IDL.Func([IDL.Principal, IDL.Nat], [Result], []),
  });
  return Contract;
};
export const init = ({ IDL }) => {
  const Time = IDL.Int;
  const LockContract = IDL.Record({
    'status' : IDL.Text,
    'durationTime' : IDL.Nat,
    'durationUnit' : IDL.Nat,
    'created' : Time,
    'provider' : IDL.Text,
    'lockedTime' : IDL.Opt(Time),
    'meta' : IDL.Vec(IDL.Text),
    'positionId' : IDL.Nat,
    'positionOwner' : IDL.Principal,
    'unlockedTime' : IDL.Opt(Time),
    'poolName' : IDL.Text,
    'contractId' : IDL.Opt(IDL.Text),
    'poolId' : IDL.Text,
  });
  return [LockContract];
};

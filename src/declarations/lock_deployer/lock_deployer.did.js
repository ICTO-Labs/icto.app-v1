export const idlFactory = ({ IDL }) => {
  const TokenInfo = IDL.Record({
    'name' : IDL.Text,
    'address' : IDL.Text,
    'standard' : IDL.Text,
  });
  const LockContractInit = IDL.Record({
    'durationTime' : IDL.Nat,
    'durationUnit' : IDL.Nat,
    'provider' : IDL.Text,
    'meta' : IDL.Vec(IDL.Text),
    'positionId' : IDL.Nat,
    'token0' : TokenInfo,
    'token1' : TokenInfo,
    'poolName' : IDL.Text,
    'poolId' : IDL.Text,
  });
  const Result = IDL.Variant({ 'ok' : IDL.Text, 'err' : IDL.Text });
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
    'version' : IDL.Text,
    'token0' : TokenInfo,
    'token1' : TokenInfo,
    'positionOwner' : IDL.Principal,
    'withdrawnTime' : IDL.Opt(Time),
    'unlockedTime' : IDL.Opt(Time),
    'poolName' : IDL.Text,
    'contractId' : IDL.Opt(IDL.Text),
    'poolId' : IDL.Text,
  });
  const _anon_class_34_1 = IDL.Service({
    'addAdmin' : IDL.Func([IDL.Text], [], []),
    'cancelContract' : IDL.Func([IDL.Principal], [], []),
    'createContract' : IDL.Func([LockContractInit], [Result], []),
    'cycleBalance' : IDL.Func([], [IDL.Nat], ['query']),
    'getAllAdmins' : IDL.Func([], [IDL.Vec(IDL.Text)], ['query']),
    'getAllContracts' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(IDL.Text, LockContract))],
        ['query'],
      ),
    'getContract' : IDL.Func([IDL.Text], [IDL.Opt(LockContract)], ['query']),
    'getContracts' : IDL.Func([IDL.Nat], [IDL.Vec(LockContract)], ['query']),
    'getOwner' : IDL.Func([IDL.Text], [IDL.Opt(IDL.Text)], ['query']),
    'getTotalContract' : IDL.Func([], [IDL.Nat], ['query']),
    'getUserContracts' : IDL.Func(
        [IDL.Text, IDL.Nat],
        [IDL.Vec(LockContract)],
        ['query'],
      ),
    'getUserTotalTokens' : IDL.Func([IDL.Text], [IDL.Nat], ['query']),
    'removeAdmin' : IDL.Func([IDL.Text], [], []),
    'updateContractStatus' : IDL.Func([IDL.Text, IDL.Text], [], []),
    'updateInitCycles' : IDL.Func([IDL.Nat], [], []),
    'updateMinDeployerCycles' : IDL.Func([IDL.Nat], [], []),
  });
  return _anon_class_34_1;
};
export const init = ({ IDL }) => { return []; };

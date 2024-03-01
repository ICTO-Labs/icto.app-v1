export const idlFactory = ({ IDL }) => {
  const LockContractInit = IDL.Record({
    'durationTime' : IDL.Nat,
    'durationUnit' : IDL.Nat,
    'provider' : IDL.Text,
    'meta' : IDL.Vec(IDL.Text),
    'positionId' : IDL.Nat,
    'poolName' : IDL.Text,
    'poolId' : IDL.Text,
  });
  const Time = IDL.Int;
  const LockContract = IDL.Record({
    'status' : IDL.Variant({ 'locked' : IDL.Null, 'unlocked' : IDL.Null }),
    'durationTime' : IDL.Nat,
    'durationUnit' : IDL.Nat,
    'created' : Time,
    'provider' : IDL.Text,
    'meta' : IDL.Vec(IDL.Text),
    'positionId' : IDL.Nat,
    'positionOwner' : IDL.Principal,
    'poolName' : IDL.Text,
    'poolId' : IDL.Text,
  });
  return IDL.Service({
    'addAdmin' : IDL.Func([IDL.Text], [], []),
    'createContract' : IDL.Func([LockContractInit], [IDL.Text], []),
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
    'updateInitCycles' : IDL.Func([IDL.Nat], [], []),
  });
};
export const init = ({ IDL }) => { return []; };

export const idlFactory = ({ IDL }) => {
  const canister_id = IDL.Principal;
  const CanisterSettings = IDL.Record({
    'freezing_threshold' : IDL.Nat,
    'controllers' : IDL.Vec(IDL.Principal),
    'memory_allocation' : IDL.Nat,
    'compute_allocation' : IDL.Nat,
  });
  const CanisterStatus = IDL.Record({
    'status' : IDL.Variant({
      'stopped' : IDL.Null,
      'stopping' : IDL.Null,
      'running' : IDL.Null,
    }),
    'freezing_threshold' : IDL.Nat,
    'memory_size' : IDL.Nat,
    'cycles' : IDL.Nat,
    'settings' : CanisterSettings,
    'module_hash' : IDL.Opt(IDL.Vec(IDL.Nat8)),
  });
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
  const ContractData = IDL.Record({
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
  });
  const Result = IDL.Variant({ 'ok' : IDL.Principal, 'err' : IDL.Text });
  return IDL.Service({
    'addAdmin' : IDL.Func([IDL.Text], [], []),
    'addController' : IDL.Func([canister_id, IDL.Vec(IDL.Principal)], [], []),
    'cancelContract' : IDL.Func([IDL.Principal], [], []),
    'canister_status' : IDL.Func([canister_id], [CanisterStatus], []),
    'createContract' : IDL.Func([ContractData], [Result], []),
    'getAdmins' : IDL.Func([], [IDL.Vec(IDL.Text)], ['query']),
    'removeAdmin' : IDL.Func([IDL.Text], [], []),
    'updateIndexingCanister' : IDL.Func([IDL.Text], [], []),
    'whoami' : IDL.Func([], [IDL.Principal], []),
  });
};
export const init = ({ IDL }) => { return []; };

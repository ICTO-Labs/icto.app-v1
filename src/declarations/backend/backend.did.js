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
    'title' : IDL.Opt(IDL.Text),
    'note' : IDL.Opt(IDL.Text),
    'address' : IDL.Text,
    'amount' : IDL.Nat,
  });
  const ContractData = IDL.Record({
    'startTime' : Time,
    'canChange' : IDL.Text,
    'canCancel' : IDL.Text,
    'durationTime' : IDL.Nat,
    'durationUnit' : IDL.Nat,
    'tokenId' : IDL.Text,
    'tokenStandard' : IDL.Text,
    'startNow' : IDL.Bool,
    'name' : IDL.Text,
    'canView' : IDL.Text,
    'recipients' : IDL.Vec(Recipient),
    'totalAmount' : IDL.Nat,
    'tokenName' : IDL.Text,
    'unlockSchedule' : IDL.Nat,
  });
  const TimerId = IDL.Nat;
  return IDL.Service({
    'cancel' : IDL.Func([], [], []),
    'cancelContract' : IDL.Func([IDL.Principal], [], []),
    'canister_status' : IDL.Func([canister_id], [CanisterStatus], []),
    'createContract' : IDL.Func([ContractData], [IDL.Text], []),
    'getValue' : IDL.Func([], [IDL.Nat], ['query']),
    'get_cron_id' : IDL.Func([], [TimerId], ['query']),
    'increment' : IDL.Func([], [], []),
    'listContract' : IDL.Func([], [IDL.Vec(IDL.Text)], ['query']),
    'whoami' : IDL.Func([], [IDL.Principal], []),
  });
};
export const init = ({ IDL }) => { return []; };

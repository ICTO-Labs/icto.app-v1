export default ({ IDL }) => {
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
    'owner' : IDL.Principal,
    'tokenStandard' : IDL.Text,
    'startNow' : IDL.Bool,
    'name' : IDL.Text,
    'description' : IDL.Text,
    'canView' : IDL.Text,
    'tokenSymbol' : IDL.Text,
    'recipients' : IDL.Vec(Recipient),
    'totalAmount' : IDL.Nat,
    'tokenName' : IDL.Text,
    'unlockSchedule' : IDL.Nat,
    'unlockedAmount' : IDL.Nat,
  });
  const TransferHistory = IDL.Record({
    'to' : IDL.Text,
    'time' : Time,
    'txId' : IDL.Opt(IDL.Nat),
    'amount' : IDL.Nat,
  });
  return IDL.Service({
    'cancel' : IDL.Func([], [], []),
    'get' : IDL.Func([], [ContractData], ['query']),
    'getBalance' : IDL.Func([], [IDL.Nat], []),
    'history' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(IDL.Nat, TransferHistory))],
        ['query'],
      ),
    'report' : IDL.Func([], [IDL.Text], []),
    'reset' : IDL.Func([], [], ['oneway']),
    'stats' : IDL.Func([], [IDL.Vec(IDL.Tuple(IDL.Text, IDL.Nat))], ['query']),
    'whoami' : IDL.Func([], [IDL.Principal], []),
  });
  };
  export const init = ({ IDL }) => { return []; };
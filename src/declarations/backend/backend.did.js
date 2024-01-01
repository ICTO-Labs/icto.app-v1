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
  const Recipient__1 = IDL.Record({
    'title' : IDL.Opt(IDL.Text),
    'note' : IDL.Opt(IDL.Text),
    'address' : IDL.Text,
    'amount' : IDL.Nat,
  });
  const ContractData__1 = IDL.Record({
    'startTime' : Time,
    'canChange' : IDL.Text,
    'canCancel' : IDL.Text,
    'durationTime' : IDL.Nat,
    'durationUnit' : IDL.Nat,
    'created' : Time,
    'tokenId' : IDL.Text,
    'owner' : IDL.Principal,
    'tokenStandard' : IDL.Text,
    'startNow' : IDL.Bool,
    'name' : IDL.Text,
    'description' : IDL.Text,
    'canView' : IDL.Text,
    'tokenSymbol' : IDL.Text,
    'recipients' : IDL.Vec(Recipient__1),
    'totalAmount' : IDL.Nat,
    'tokenName' : IDL.Text,
    'unlockSchedule' : IDL.Nat,
    'unlockedAmount' : IDL.Nat,
  });
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
    'created' : Time,
    'tokenId' : IDL.Text,
    'tokenStandard' : IDL.Text,
    'startNow' : IDL.Bool,
    'name' : IDL.Text,
    'createdBy' : IDL.Text,
    'description' : IDL.Text,
    'canView' : IDL.Text,
    'recipients' : IDL.Vec(Recipient),
    'totalAmount' : IDL.Nat,
    'tokenName' : IDL.Text,
    'unlockSchedule' : IDL.Nat,
    'contractId' : IDL.Text,
  });
  const TimerId = IDL.Nat;
  const Subaccount = IDL.Vec(IDL.Nat8);
  const Account = IDL.Record({
    'owner' : IDL.Principal,
    'subaccount' : IDL.Opt(Subaccount),
  });
  const Tokens = IDL.Nat;
  const Memo = IDL.Vec(IDL.Nat8);
  const Timestamp = IDL.Nat64;
  const TransferFromArg = IDL.Record({
    'to' : Account,
    'fee' : IDL.Opt(Tokens),
    'spender_subaccount' : IDL.Opt(Subaccount),
    'from' : Account,
    'memo' : IDL.Opt(Memo),
    'created_at_time' : IDL.Opt(Timestamp),
    'amount' : Tokens,
  });
  const TxIndex = IDL.Nat;
  const TransferFromError = IDL.Variant({
    'GenericError' : IDL.Record({
      'message' : IDL.Text,
      'error_code' : IDL.Nat,
    }),
    'TemporarilyUnavailable' : IDL.Null,
    'InsufficientAllowance' : IDL.Record({ 'allowance' : IDL.Nat }),
    'BadBurn' : IDL.Record({ 'min_burn_amount' : IDL.Nat }),
    'Duplicate' : IDL.Record({ 'duplicate_of' : IDL.Nat }),
    'BadFee' : IDL.Record({ 'expected_fee' : IDL.Nat }),
    'CreatedInFuture' : IDL.Record({ 'ledger_time' : IDL.Nat64 }),
    'TooOld' : IDL.Null,
    'InsufficientFunds' : IDL.Record({ 'balance' : IDL.Nat }),
  });
  const TransferFromResult = IDL.Variant({
    'ok' : TxIndex,
    'err' : TransferFromError,
  });
  return IDL.Service({
    'cancel' : IDL.Func([], [], []),
    'cancelContract' : IDL.Func([IDL.Principal], [], []),
    'canister_status' : IDL.Func([canister_id], [CanisterStatus], []),
    'createContract' : IDL.Func([ContractData__1], [IDL.Text], []),
    'getContracts' : IDL.Func([IDL.Nat], [IDL.Vec(ContractData)], ['query']),
    'getValue' : IDL.Func([], [IDL.Nat], ['query']),
    'get_cron_id' : IDL.Func([], [TimerId], ['query']),
    'increment' : IDL.Func([], [], []),
    'listContract' : IDL.Func([], [IDL.Vec(IDL.Text)], ['query']),
    'transfer_from' : IDL.Func(
        [IDL.Text, TransferFromArg],
        [TransferFromResult],
        [],
      ),
    'whoami' : IDL.Func([], [IDL.Principal], []),
  });
};
export const init = ({ IDL }) => { return []; };

export const idlFactory = ({ IDL }) => {
  const Result_3 = IDL.Variant({ 'ok' : IDL.Bool, 'err' : IDL.Text });
  const Result_2 = IDL.Variant({ 'ok' : IDL.Text, 'err' : IDL.Text });
  const Token = IDL.Record({
    'logo' : IDL.Text,
    'name' : IDL.Text,
    'wasm_version' : IDL.Text,
    'canister' : IDL.Text,
    'symbol' : IDL.Text,
  });
  const Subaccount = IDL.Vec(IDL.Nat8);
  const Account = IDL.Record({
    'owner' : IDL.Principal,
    'subaccount' : IDL.Opt(Subaccount),
  });
  const InitArgsRequested = IDL.Record({
    'token_symbol' : IDL.Text,
    'transfer_fee' : IDL.Nat,
    'minting_account' : Account,
    'logo' : IDL.Text,
    'initial_balances' : IDL.Vec(IDL.Tuple(Account, IDL.Nat)),
    'fee_collector_account' : IDL.Opt(Account),
    'token_name' : IDL.Text,
  });
  const Result_1 = IDL.Variant({ 'ok' : IDL.Principal, 'err' : IDL.Text });
  const Result = IDL.Variant({ 'ok' : IDL.Nat, 'err' : IDL.Text });
  const Self = IDL.Service({
    'addAdmin' : IDL.Func([IDL.Text], [], []),
    'addToWhiteList' : IDL.Func([IDL.Principal], [Result_3], []),
    'addWasm' : IDL.Func([IDL.Vec(IDL.Nat8)], [Result_2], []),
    'balance' : IDL.Func([], [IDL.Nat], []),
    'clearChunks' : IDL.Func([], [], []),
    'cycleBalance' : IDL.Func([], [IDL.Nat], ['query']),
    'getAllAdmins' : IDL.Func([], [IDL.Vec(IDL.Text)], ['query']),
    'getCurrentWasmVersion' : IDL.Func([], [IDL.Text], ['query']),
    'getOwner' : IDL.Func([IDL.Text], [IDL.Opt(IDL.Text)], ['query']),
    'getTokenDetails' : IDL.Func([IDL.Text], [IDL.Opt(Token)], ['query']),
    'getTokens' : IDL.Func([IDL.Nat], [IDL.Vec(Token)], ['query']),
    'getTotalTokens' : IDL.Func([], [IDL.Nat], ['query']),
    'getUserTokens' : IDL.Func(
        [IDL.Text, IDL.Nat],
        [IDL.Vec(Token)],
        ['query'],
      ),
    'getUserTotalTokens' : IDL.Func([IDL.Text], [IDL.Nat], ['query']),
    'get_lastest_version' : IDL.Func([], [Result_2], []),
    'install' : IDL.Func(
        [InitArgsRequested, IDL.Opt(IDL.Principal)],
        [Result_1],
        [],
      ),
    'removeAdmin' : IDL.Func([IDL.Text], [], []),
    'transfer' : IDL.Func([IDL.Nat, IDL.Principal], [Result], []),
    'updateCreationFee' : IDL.Func([IDL.Nat], [], []),
    'updateInitCycles' : IDL.Func([IDL.Nat], [], []),
    'updateMinCycles' : IDL.Func([IDL.Nat], [], []),
    'uploadChunk' : IDL.Func([IDL.Vec(IDL.Nat8)], [IDL.Nat], []),
  });
  return Self;
};
export const init = ({ IDL }) => { return []; };

export const idlFactory = ({ IDL }) => {
  const Result = IDL.Variant({ 'ok' : IDL.Bool, 'err' : IDL.Text });
  const TokenData = IDL.Record({
    'lockContracts' : IDL.Opt(IDL.Vec(IDL.Tuple(IDL.Text, IDL.Principal))),
    'description' : IDL.Opt(IDL.Text),
    'links' : IDL.Opt(IDL.Vec(IDL.Text)),
    'tokenProvider' : IDL.Opt(IDL.Text),
    'launchpadId' : IDL.Opt(IDL.Principal),
  });
  const Result_3 = IDL.Variant({ 'ok' : IDL.Text, 'err' : IDL.Text });
  const LedgerMeta = IDL.Record({
    'fee' : IDL.Nat,
    'decimals' : IDL.Nat,
    'logo' : IDL.Text,
    'name' : IDL.Text,
    'symbol' : IDL.Text,
  });
  const TokenInfo = IDL.Record({
    'moduleHash' : IDL.Text,
    'owner' : IDL.Principal,
    'logo' : IDL.Text,
    'name' : IDL.Text,
    'createdAt' : IDL.Int,
    'lockContracts' : IDL.Opt(IDL.Vec(IDL.Tuple(IDL.Text, IDL.Principal))),
    'description' : IDL.Opt(IDL.Text),
    'links' : IDL.Opt(IDL.Vec(IDL.Text)),
    'tokenProvider' : IDL.Opt(IDL.Text),
    'updatedAt' : IDL.Int,
    'launchpadId' : IDL.Opt(IDL.Principal),
    'symbol' : IDL.Text,
    'canisterId' : IDL.Principal,
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
  const Result_2 = IDL.Variant({ 'ok' : IDL.Principal, 'err' : IDL.Text });
  const Result_1 = IDL.Variant({ 'ok' : IDL.Nat, 'err' : IDL.Text });
  const Self = IDL.Service({
    'addAdmin' : IDL.Func([IDL.Text], [], []),
    'addToWhiteList' : IDL.Func([IDL.Principal], [Result], []),
    'addToken' : IDL.Func([IDL.Principal, TokenData], [Result], []),
    'addWasm' : IDL.Func([IDL.Vec(IDL.Nat8)], [Result_3], []),
    'balance' : IDL.Func([], [IDL.Nat], []),
    'clearChunks' : IDL.Func([], [], []),
    'cycleBalance' : IDL.Func([], [IDL.Nat], ['query']),
    'getAllAdmins' : IDL.Func([], [IDL.Vec(IDL.Text)], ['query']),
    'getCurrentWasmVersion' : IDL.Func([], [IDL.Text], ['query']),
    'getLedgerMeta' : IDL.Func([IDL.Principal], [LedgerMeta], []),
    'getOwner' : IDL.Func([IDL.Text], [IDL.Opt(IDL.Text)], ['query']),
    'getTokenDetails' : IDL.Func([IDL.Text], [IDL.Opt(TokenInfo)], ['query']),
    'getTokens' : IDL.Func([IDL.Nat], [IDL.Vec(TokenInfo)], ['query']),
    'getTotalTokens' : IDL.Func([], [IDL.Nat], ['query']),
    'getUserTokens' : IDL.Func(
        [IDL.Text, IDL.Nat],
        [IDL.Vec(TokenInfo)],
        ['query'],
      ),
    'getUserTotalTokens' : IDL.Func([IDL.Text], [IDL.Nat], ['query']),
    'get_lastest_version' : IDL.Func([], [Result_3], []),
    'install' : IDL.Func(
        [InitArgsRequested, IDL.Opt(IDL.Principal), TokenData],
        [Result_2],
        [],
      ),
    'isSupportedStandards' : IDL.Func([IDL.Principal], [IDL.Bool], []),
    'removeAdmin' : IDL.Func([IDL.Text], [], []),
    'removeToken' : IDL.Func([IDL.Principal], [Result], []),
    'transfer' : IDL.Func([IDL.Nat, IDL.Principal], [Result_1], []),
    'updateAllowCustomToken' : IDL.Func([IDL.Bool], [], []),
    'updateCreationFee' : IDL.Func([IDL.Nat], [], []),
    'updateInitCycles' : IDL.Func([IDL.Nat], [], []),
    'updateMinCycles' : IDL.Func([IDL.Nat], [], []),
    'updateTokenData' : IDL.Func([IDL.Text, TokenInfo], [Result], []),
    'uploadChunk' : IDL.Func([IDL.Vec(IDL.Nat8)], [IDL.Nat], []),
  });
  return Self;
};
export const init = ({ IDL }) => { return []; };

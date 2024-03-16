import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export interface Account {
  'owner' : Principal,
  'subaccount' : [] | [Subaccount],
}
export interface InitArgsRequested {
  'token_symbol' : string,
  'transfer_fee' : bigint,
  'minting_account' : Account,
  'logo' : string,
  'initial_balances' : Array<[Account, bigint]>,
  'fee_collector_account' : [] | [Account],
  'token_name' : string,
}
export type Result = { 'ok' : Principal } |
  { 'err' : string };
export type Result_1 = { 'ok' : string } |
  { 'err' : string };
export interface Self {
  'addAdmin' : ActorMethod<[string], undefined>,
  'balance' : ActorMethod<[], bigint>,
  'cycleBalance' : ActorMethod<[], bigint>,
  'getAllAdmins' : ActorMethod<[], Array<string>>,
  'getCurrentWasmVersion' : ActorMethod<[], string>,
  'getOwner' : ActorMethod<[string], [] | [string]>,
  'getTokenDetails' : ActorMethod<[string], [] | [Token]>,
  'getTokens' : ActorMethod<[bigint], Array<Token>>,
  'getTotalTokens' : ActorMethod<[], bigint>,
  'getUserTokens' : ActorMethod<[string, bigint], Array<Token>>,
  'getUserTotalTokens' : ActorMethod<[string], bigint>,
  'get_lastest_version' : ActorMethod<[], Result_1>,
  'install' : ActorMethod<[InitArgsRequested], Result>,
  'removeAdmin' : ActorMethod<[string], undefined>,
  'updateCreationFee' : ActorMethod<[bigint], undefined>,
  'updateInitCycles' : ActorMethod<[bigint], undefined>,
  'updateMinCycles' : ActorMethod<[bigint], undefined>,
}
export type Subaccount = Uint8Array | number[];
export interface Token {
  'logo' : string,
  'name' : string,
  'wasm_version' : string,
  'canister' : string,
  'symbol' : string,
}
export interface _SERVICE extends Self {}

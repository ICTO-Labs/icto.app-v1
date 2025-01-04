import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

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
export type Result = { 'ok' : bigint } |
  { 'err' : string };
export type Result_1 = { 'ok' : Principal } |
  { 'err' : string };
export type Result_2 = { 'ok' : string } |
  { 'err' : string };
export type Result_3 = { 'ok' : boolean } |
  { 'err' : string };
export interface Self {
  'addAdmin' : ActorMethod<[string], undefined>,
  'addToWhiteList' : ActorMethod<[Principal], Result_3>,
  'addWasm' : ActorMethod<[Uint8Array | number[]], Result_2>,
  'balance' : ActorMethod<[], bigint>,
  'clearChunks' : ActorMethod<[], undefined>,
  'cycleBalance' : ActorMethod<[], bigint>,
  'getAllAdmins' : ActorMethod<[], Array<string>>,
  'getCurrentWasmVersion' : ActorMethod<[], string>,
  'getOwner' : ActorMethod<[string], [] | [string]>,
  'getTokenDetails' : ActorMethod<[string], [] | [Token]>,
  'getTokens' : ActorMethod<[bigint], Array<Token>>,
  'getTotalTokens' : ActorMethod<[], bigint>,
  'getUserTokens' : ActorMethod<[string, bigint], Array<Token>>,
  'getUserTotalTokens' : ActorMethod<[string], bigint>,
  'get_lastest_version' : ActorMethod<[], Result_2>,
  'install' : ActorMethod<[InitArgsRequested, [] | [Principal]], Result_1>,
  'removeAdmin' : ActorMethod<[string], undefined>,
  'transfer' : ActorMethod<[bigint, Principal], Result>,
  'updateCreationFee' : ActorMethod<[bigint], undefined>,
  'updateInitCycles' : ActorMethod<[bigint], undefined>,
  'updateMinCycles' : ActorMethod<[bigint], undefined>,
  'uploadChunk' : ActorMethod<[Uint8Array | number[]], bigint>,
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
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];

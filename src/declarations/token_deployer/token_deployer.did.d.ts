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
export interface LedgerMeta {
  'fee' : bigint,
  'decimals' : bigint,
  'logo' : string,
  'name' : string,
  'symbol' : string,
}
export type Result = { 'ok' : boolean } |
  { 'err' : string };
export type Result_1 = { 'ok' : bigint } |
  { 'err' : string };
export type Result_2 = { 'ok' : Principal } |
  { 'err' : string };
export type Result_3 = { 'ok' : string } |
  { 'err' : string };
export interface Self {
  'addAdmin' : ActorMethod<[string], undefined>,
  'addToWhiteList' : ActorMethod<[Principal], Result>,
  'addToken' : ActorMethod<[Principal, TokenData], Result>,
  'addWasm' : ActorMethod<[Uint8Array | number[]], Result_3>,
  'balance' : ActorMethod<[], bigint>,
  'clearChunks' : ActorMethod<[], undefined>,
  'cycleBalance' : ActorMethod<[], bigint>,
  'getAllAdmins' : ActorMethod<[], Array<string>>,
  'getCurrentWasmVersion' : ActorMethod<[], string>,
  'getLedgerMeta' : ActorMethod<[Principal], LedgerMeta>,
  'getOwner' : ActorMethod<[string], [] | [string]>,
  'getTokenDetails' : ActorMethod<[string], [] | [TokenInfo]>,
  'getTokens' : ActorMethod<[bigint], Array<TokenInfo>>,
  'getTotalTokens' : ActorMethod<[], bigint>,
  'getUserTokens' : ActorMethod<[string, bigint], Array<TokenInfo>>,
  'getUserTotalTokens' : ActorMethod<[string], bigint>,
  'get_lastest_version' : ActorMethod<[], Result_3>,
  'install' : ActorMethod<
    [InitArgsRequested, [] | [Principal], TokenData],
    Result_2
  >,
  'isSupportedStandards' : ActorMethod<[Principal], boolean>,
  'removeAdmin' : ActorMethod<[string], undefined>,
  'removeToken' : ActorMethod<[Principal], Result>,
  'transfer' : ActorMethod<[bigint, Principal], Result_1>,
  'updateAllowCustomToken' : ActorMethod<[boolean], undefined>,
  'updateCreationFee' : ActorMethod<[bigint], undefined>,
  'updateInitCycles' : ActorMethod<[bigint], undefined>,
  'updateMinCycles' : ActorMethod<[bigint], undefined>,
  'updateTokenData' : ActorMethod<[string, TokenInfo], Result>,
  'uploadChunk' : ActorMethod<[Uint8Array | number[]], bigint>,
}
export type Subaccount = Uint8Array | number[];
export interface TokenData {
  'lockContracts' : [] | [Array<[string, Principal]>],
  'description' : [] | [string],
  'links' : [] | [Array<string>],
  'tokenProvider' : [] | [string],
  'launchpadId' : [] | [Principal],
}
export interface TokenInfo {
  'moduleHash' : string,
  'owner' : Principal,
  'logo' : string,
  'name' : string,
  'createdAt' : bigint,
  'lockContracts' : [] | [Array<[string, Principal]>],
  'description' : [] | [string],
  'links' : [] | [Array<string>],
  'tokenProvider' : [] | [string],
  'updatedAt' : bigint,
  'launchpadId' : [] | [Principal],
  'symbol' : string,
  'canisterId' : Principal,
}
export interface _SERVICE extends Self {}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];

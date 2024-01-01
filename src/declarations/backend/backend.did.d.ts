import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export interface Account {
  'owner' : Principal,
  'subaccount' : [] | [Subaccount],
}
export interface CanisterSettings {
  'freezing_threshold' : bigint,
  'controllers' : Array<Principal>,
  'memory_allocation' : bigint,
  'compute_allocation' : bigint,
}
export interface CanisterStatus {
  'status' : { 'stopped' : null } |
    { 'stopping' : null } |
    { 'running' : null },
  'freezing_threshold' : bigint,
  'memory_size' : bigint,
  'cycles' : bigint,
  'settings' : CanisterSettings,
  'module_hash' : [] | [Uint8Array | number[]],
}
export interface ContractData {
  'startTime' : Time,
  'canChange' : string,
  'canCancel' : string,
  'durationTime' : bigint,
  'durationUnit' : bigint,
  'created' : Time,
  'tokenId' : string,
  'tokenStandard' : string,
  'startNow' : boolean,
  'name' : string,
  'canView' : string,
  'recipients' : Array<Recipient>,
  'totalAmount' : bigint,
  'tokenName' : string,
  'unlockSchedule' : bigint,
}
export interface ContractData__1 {
  'startTime' : Time,
  'canChange' : string,
  'canCancel' : string,
  'durationTime' : bigint,
  'durationUnit' : bigint,
  'created' : Time,
  'tokenId' : string,
  'owner' : Principal,
  'tokenStandard' : string,
  'startNow' : boolean,
  'name' : string,
  'description' : string,
  'canView' : string,
  'tokenSymbol' : string,
  'recipients' : Array<Recipient__1>,
  'totalAmount' : bigint,
  'tokenName' : string,
  'unlockSchedule' : bigint,
  'unlockedAmount' : bigint,
}
export type Memo = Uint8Array | number[];
export interface Recipient {
  'title' : [] | [string],
  'note' : [] | [string],
  'address' : string,
  'amount' : bigint,
}
export interface Recipient__1 {
  'title' : [] | [string],
  'note' : [] | [string],
  'address' : string,
  'amount' : bigint,
}
export type Subaccount = Uint8Array | number[];
export type Time = bigint;
export type TimerId = bigint;
export type Timestamp = bigint;
export type Tokens = bigint;
export interface TransferFromArg {
  'to' : Account,
  'fee' : [] | [Tokens],
  'spender_subaccount' : [] | [Subaccount],
  'from' : Account,
  'memo' : [] | [Memo],
  'created_at_time' : [] | [Timestamp],
  'amount' : Tokens,
}
export type TransferFromError = {
    'GenericError' : { 'message' : string, 'error_code' : bigint }
  } |
  { 'TemporarilyUnavailable' : null } |
  { 'InsufficientAllowance' : { 'allowance' : bigint } } |
  { 'BadBurn' : { 'min_burn_amount' : bigint } } |
  { 'Duplicate' : { 'duplicate_of' : bigint } } |
  { 'BadFee' : { 'expected_fee' : bigint } } |
  { 'CreatedInFuture' : { 'ledger_time' : bigint } } |
  { 'TooOld' : null } |
  { 'InsufficientFunds' : { 'balance' : bigint } };
export type TransferFromResult = { 'ok' : TxIndex } |
  { 'err' : TransferFromError };
export type TxIndex = bigint;
export type canister_id = Principal;
export interface _SERVICE {
  'cancel' : ActorMethod<[], undefined>,
  'cancelContract' : ActorMethod<[Principal], undefined>,
  'canister_status' : ActorMethod<[canister_id], CanisterStatus>,
  'createContract' : ActorMethod<[ContractData__1], string>,
  'getContracts' : ActorMethod<[bigint], Array<ContractData>>,
  'getValue' : ActorMethod<[], bigint>,
  'get_cron_id' : ActorMethod<[], TimerId>,
  'increment' : ActorMethod<[], undefined>,
  'listContract' : ActorMethod<[], Array<string>>,
  'transfer_from' : ActorMethod<[string, TransferFromArg], TransferFromResult>,
  'whoami' : ActorMethod<[], Principal>,
}

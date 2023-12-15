import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

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
export interface Recipient {
  'title' : [] | [string],
  'note' : [] | [string],
  'address' : string,
  'amount' : bigint,
}
export type Time = bigint;
export type TimerId = bigint;
export type canister_id = Principal;
export interface _SERVICE {
  'cancel' : ActorMethod<[], undefined>,
  'cancelContract' : ActorMethod<[Principal], undefined>,
  'canister_status' : ActorMethod<[canister_id], CanisterStatus>,
  'createContract' : ActorMethod<[ContractData], string>,
  'getValue' : ActorMethod<[], bigint>,
  'get_cron_id' : ActorMethod<[], TimerId>,
  'increment' : ActorMethod<[], undefined>,
  'listContract' : ActorMethod<[], Array<string>>,
  'whoami' : ActorMethod<[], Principal>,
}

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
  'title' : string,
  'created' : Time,
  'owner' : Principal,
  'startNow' : boolean,
  'description' : string,
  'canView' : string,
  'cliffTime' : bigint,
  'cliffUnit' : bigint,
  'recipients' : Array<Recipient>,
  'totalAmount' : bigint,
  'tokenInfo' : TokenInfo,
  'unlockSchedule' : bigint,
  'unlockedAmount' : bigint,
}
export interface Recipient {
  'note' : [] | [string],
  'address' : string,
  'amount' : bigint,
}
export type Time = bigint;
export interface TokenInfo {
  'decimals' : bigint,
  'fees' : bigint,
  'name' : string,
  'standard' : string,
  'symbol' : string,
  'canisterId' : string,
}
export type canister_id = Principal;
export interface _SERVICE {
  'addAdmin' : ActorMethod<[string], undefined>,
  'addController' : ActorMethod<[canister_id, Array<Principal>], undefined>,
  'cancelContract' : ActorMethod<[Principal], undefined>,
  'canister_status' : ActorMethod<[canister_id], CanisterStatus>,
  'createContract' : ActorMethod<[ContractData], string>,
  'getAdmins' : ActorMethod<[], Array<string>>,
  'removeAdmin' : ActorMethod<[string], undefined>,
  'updateIndexingCanister' : ActorMethod<[string], undefined>,
  'whoami' : ActorMethod<[], Principal>,
}

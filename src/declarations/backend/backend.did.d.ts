import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

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
  'startTime' : bigint,
  'distributionType' : DistributionType__1,
  'durationTime' : bigint,
  'durationUnit' : bigint,
  'title' : string,
  'created' : Time,
  'autoTransfer' : boolean,
  'owner' : Principal,
  'startNow' : boolean,
  'blockId' : bigint,
  'description' : string,
  'cliffTime' : bigint,
  'cliffUnit' : bigint,
  'vestingType' : VestingType,
  'maxRecipients' : bigint,
  'recipients' : [] | [Array<Recipient>],
  'totalAmount' : bigint,
  'tokenInfo' : TokenInfo,
  'initialUnlockPercentage' : bigint,
  'unlockSchedule' : bigint,
  'allowCancel' : boolean,
}
export interface ContractMetadata {
  'id' : string,
  'distributionType' : DistributionType,
  'owner' : string,
  'createdAt' : bigint,
}
export type DistributionType = { 'Public' : null } |
  { 'Whitelist' : null };
export type DistributionType__1 = { 'Public' : null } |
  { 'Whitelist' : null };
export interface Recipient {
  'note' : [] | [string],
  'address' : string,
  'amount' : bigint,
}
export type Result = { 'ok' : Principal } |
  { 'err' : string };
export type Time = bigint;
export interface TokenInfo {
  'fee' : bigint,
  'decimals' : bigint,
  'name' : string,
  'standard' : string,
  'symbol' : string,
  'canisterId' : string,
}
export type VestingType = { 'Standard' : null } |
  { 'Single' : null };
export type canister_id = Principal;
export interface _SERVICE {
  'addAdmin' : ActorMethod<[string], undefined>,
  'addController' : ActorMethod<[canister_id, Array<Principal>], undefined>,
  'cancelContract' : ActorMethod<[Principal], undefined>,
  'canister_status' : ActorMethod<[canister_id], CanisterStatus>,
  'createContract' : ActorMethod<[ContractData], Result>,
  'getAdmins' : ActorMethod<[], Array<string>>,
  'getAllContracts' : ActorMethod<[], Array<ContractMetadata>>,
  'getContractMetadata' : ActorMethod<[string], [] | [ContractMetadata]>,
  'getContractsByWallet' : ActorMethod<
    [],
    { 'privateContracts' : Array<string>, 'publicContracts' : Array<string> }
  >,
  'getMyContracts' : ActorMethod<[], Array<ContractMetadata>>,
  'getPrivateContracts' : ActorMethod<[string], Array<string>>,
  'removeAdmin' : ActorMethod<[string], undefined>,
  'whoami' : ActorMethod<[], Principal>,
}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];

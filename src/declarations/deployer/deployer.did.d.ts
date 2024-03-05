import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export interface LockContract {
  'status' : string,
  'durationTime' : bigint,
  'durationUnit' : bigint,
  'created' : Time,
  'provider' : string,
  'lockedTime' : [] | [Time],
  'meta' : Array<string>,
  'positionId' : bigint,
  'positionOwner' : Principal,
  'unlockedTime' : [] | [Time],
  'poolName' : string,
  'contractId' : [] | [string],
  'poolId' : string,
}
export interface LockContractInit {
  'durationTime' : bigint,
  'durationUnit' : bigint,
  'provider' : string,
  'meta' : Array<string>,
  'positionId' : bigint,
  'poolName' : string,
  'poolId' : string,
}
export type Time = bigint;
export interface anon_class_33_1 {
  'addAdmin' : ActorMethod<[string], undefined>,
  'cancelContract' : ActorMethod<[Principal], undefined>,
  'createContract' : ActorMethod<[LockContractInit], string>,
  'cycleBalance' : ActorMethod<[], bigint>,
  'getAllAdmins' : ActorMethod<[], Array<string>>,
  'getAllContracts' : ActorMethod<[], Array<[string, LockContract]>>,
  'getContract' : ActorMethod<[string], [] | [LockContract]>,
  'getContracts' : ActorMethod<[bigint], Array<LockContract>>,
  'getOwner' : ActorMethod<[string], [] | [string]>,
  'getTotalContract' : ActorMethod<[], bigint>,
  'getUserContracts' : ActorMethod<[string, bigint], Array<LockContract>>,
  'getUserTotalTokens' : ActorMethod<[string], bigint>,
  'removeAdmin' : ActorMethod<[string], undefined>,
  'updateContractStatus' : ActorMethod<[string, string], undefined>,
  'updateInitCycles' : ActorMethod<[bigint], undefined>,
}
export interface _SERVICE extends anon_class_33_1 {}

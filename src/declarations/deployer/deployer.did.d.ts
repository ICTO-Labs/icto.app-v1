import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export interface LockContract {
  'status' : { 'locked' : null } |
    { 'unlocked' : null },
  'durationTime' : bigint,
  'durationUnit' : bigint,
  'created' : Time,
  'provider' : string,
  'meta' : Array<string>,
  'positionId' : bigint,
  'positionOwner' : Principal,
  'poolName' : string,
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
export interface _SERVICE {
  'addAdmin' : ActorMethod<[string], undefined>,
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
  'updateInitCycles' : ActorMethod<[bigint], undefined>,
}

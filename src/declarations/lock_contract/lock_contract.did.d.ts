import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export interface Contract {
  'checkTransaction' : ActorMethod<[Principal, bigint], Result>,
  'claim' : ActorMethod<[], Result>,
  'cycleBalance' : ActorMethod<[], bigint>,
  'getContract' : ActorMethod<[], LockContract>,
  'getDeployer' : ActorMethod<[], Principal>,
  'getInitContract' : ActorMethod<[], LockContract>,
  'getLockedPosition' : ActorMethod<[], bigint>,
  'getTransactions' : ActorMethod<[], Array<[Principal, TransferRecord]>>,
  'send' : ActorMethod<[Principal, bigint], Result>,
}
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
export type Result = { 'ok' : boolean } |
  { 'err' : string };
export type Time = bigint;
export interface TransferRecord {
  'to' : Principal,
  'method' : string,
  'from' : Principal,
  'time' : Time,
  'positionId' : bigint,
}
export interface _SERVICE extends Contract {}

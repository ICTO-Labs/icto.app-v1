import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export interface Contract {
  'checkOvertime' : ActorMethod<[], undefined>,
  'cycleBalance' : ActorMethod<[], bigint>,
  'fallback_send' : ActorMethod<[Principal, bigint], Result>,
  'getContract' : ActorMethod<[], LockContract>,
  'getDeployer' : ActorMethod<[], Principal>,
  'getInitContract' : ActorMethod<[], LockContract>,
  'getLockedPosition' : ActorMethod<[], bigint>,
  'getTransactions' : ActorMethod<[], Array<[string, TransferRecord]>>,
  'getVersion' : ActorMethod<[], string>,
  'increaseDuration' : ActorMethod<[bigint, bigint], Result>,
  'verify' : ActorMethod<[], Result>,
  'withdraw' : ActorMethod<[], Result>,
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
  'version' : string,
  'token0' : TokenInfo,
  'token1' : TokenInfo,
  'positionOwner' : Principal,
  'withdrawnTime' : [] | [Time],
  'unlockedTime' : [] | [Time],
  'poolName' : string,
  'contractId' : [] | [string],
  'poolId' : string,
}
export type Result = { 'ok' : boolean } |
  { 'err' : string };
export type Time = bigint;
export interface TokenInfo {
  'name' : string,
  'address' : string,
  'standard' : string,
}
export interface TransferRecord {
  'to' : string,
  'method' : string,
  'from' : string,
  'time' : Time,
  'positionId' : bigint,
}
export interface _SERVICE extends Contract {}

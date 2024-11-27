import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export interface ClaimRecord {
  'txId' : bigint,
  'claimedAt' : Time,
  'amount' : bigint,
}
export interface Contract {
  'addRecipient' : ActorMethod<
    [Principal, bigint, bigint, bigint, bigint],
    Result
  >,
  'cancelTimer' : ActorMethod<[], undefined>,
  'checkClaimable' : ActorMethod<[Principal], bigint>,
  'checkEligibility' : ActorMethod<[], Result>,
  'claim' : ActorMethod<[], Result_1>,
  'getClaimHistory' : ActorMethod<[Principal], [] | [Array<ClaimRecord>]>,
  'getContractInfo' : ActorMethod<[], ContractData>,
  'getCounter' : ActorMethod<[], bigint>,
  'getRecipientClaimInfo' : ActorMethod<[Principal], [] | [RecipientClaimInfo]>,
  'getRecipients' : ActorMethod<[bigint], Array<RecipientClaim>>,
  'getTimePeriod' : ActorMethod<[], bigint>,
  'init' : ActorMethod<[], undefined>,
  'setRequiredScore' : ActorMethod<[bigint], Result>,
  'startContract' : ActorMethod<[], Result>,
  'transferOwnership' : ActorMethod<[Principal], Result>,
}
export interface ContractData {
  'startTime' : Time,
  'status' : ContractStatus,
  'distributionType' : DistributionType,
  'durationTime' : bigint,
  'durationUnit' : bigint,
  'title' : string,
  'created' : Time,
  'lockDuration' : bigint,
  'autoTransfer' : boolean,
  'requiredScore' : bigint,
  'owner' : Principal,
  'isStarted' : boolean,
  'startNow' : boolean,
  'blockId' : bigint,
  'isPaused' : boolean,
  'totalRecipients' : bigint,
  'totalClaimedAmount' : bigint,
  'description' : string,
  'cliffTime' : bigint,
  'cliffUnit' : bigint,
  'vestingType' : VestingType,
  'maxRecipients' : bigint,
  'isCanceled' : boolean,
  'totalAmount' : bigint,
  'allowTransfer' : boolean,
  'tokenInfo' : TokenInfo,
  'initialUnlockPercentage' : bigint,
  'unlockSchedule' : bigint,
  'tokenPerRecipient' : bigint,
  'cyclesBalance' : bigint,
  'allowCancel' : boolean,
}
export type ContractStatus = { 'CANCELED' : null } |
  { 'PAUSED' : null } |
  { 'PENDING' : null } |
  { 'STARTED' : null } |
  { 'NOT_STARTED' : null } |
  { 'ENDED' : null };
export type DistributionType = { 'Public' : null } |
  { 'Whitelist' : null };
export interface Recipient {
  'note' : [] | [string],
  'address' : string,
  'amount' : bigint,
}
export interface RecipientClaim {
  'claimedAmount' : bigint,
  'remainingAmount' : bigint,
  'claimInterval' : bigint,
  'recipient' : Recipient__1,
  'vestingCliff' : bigint,
  'lastClaimedTime' : Time,
  'vestingDuration' : bigint,
}
export interface RecipientClaimInfo {
  'claimedAmount' : bigint,
  'remainingAmount' : bigint,
  'claimInterval' : bigint,
  'recipient' : Recipient__1,
  'vestingCliff' : bigint,
  'claimHistory' : Array<ClaimRecord>,
  'lastClaimedTime' : Time,
  'vestingDuration' : bigint,
}
export interface Recipient__1 {
  'principal' : Principal,
  'note' : [] | [string],
  'amount' : bigint,
}
export type Result = { 'ok' : boolean } |
  { 'err' : string };
export type Result_1 = { 'ok' : bigint } |
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
export interface _SERVICE extends Contract {}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];

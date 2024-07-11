import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export interface ClaimContract {
  'title' : string,
  'vesting' : VestingInfo,
  'total' : bigint,
  'description' : string,
  'recipients' : Array<Recipient>,
}
export interface Distribution {
  'team' : ClaimContract,
  'liquidity' : bigint,
  'others' : Array<ClaimContract>,
  'fairlaunch' : bigint,
}
export interface LaunchParams {
  'softCap' : bigint,
  'sellAmount' : bigint,
  'hardCap' : bigint,
  'maximumAmount' : bigint,
  'minimumAmount' : bigint,
}
export interface LaunchpadCanister {
  'commit' : ActorMethod<[bigint], Result>,
  'getParticipantInfo' : ActorMethod<[string], Participant>,
  'getRefundList' : ActorMethod<[], Array<Transaction>>,
  'getTransactionList' : ActorMethod<[], Array<Transaction>>,
  'install' : ActorMethod<[LaunchpadDetail, Array<string>], Result>,
  'launchpadInfo' : ActorMethod<[], LaunchpadDetail>,
  'reinstall' : ActorMethod<[], undefined>,
  'status' : ActorMethod<[], LaunchpadStatus>,
}
export interface LaunchpadDetail {
  'fee' : bigint,
  'saleToken' : [] | [TokenInfo],
  'vesting' : VestingInfo,
  'creator' : string,
  'tokenomics' : Array<Tokenomic>,
  'projectInfo' : ProjectInfo,
  'launchParams' : LaunchParams,
  'restrictedArea' : [] | [Array<string>],
  'purchaseToken' : [] | [TokenInfo],
  'affiliate' : bigint,
  'distribution' : Distribution,
  'timeline' : Timeline,
}
export interface LaunchpadStatus {
  'status' : string,
  'totalAmountCommitted' : bigint,
  'totalParticipants' : bigint,
  'installed' : boolean,
  'cycle' : bigint,
  'whitelistEnabled' : boolean,
  'affiliate' : bigint,
  'totalTransactions' : bigint,
}
export interface Participant {
  'lastDeposit' : [] | [Time],
  'totalAmount' : bigint,
  'commit' : bigint,
}
export interface ProjectInfo {
  'metadata' : [] | [Array<[string, string]>],
  'logo' : string,
  'name' : string,
  'banner' : [] | [string],
  'description' : string,
  'isAudited' : boolean,
  'links' : [] | [Array<string>],
  'isVerified' : boolean,
}
export interface Recipient {
  'note' : [] | [string],
  'address' : string,
  'amount' : bigint,
}
export type Result = { 'ok' : boolean } |
  { 'err' : string };
export type Time = bigint;
export interface Timeline {
  'startTime' : Time,
  'endTime' : Time,
  'createdTime' : Time,
  'claimTime' : Time,
  'listingTime' : Time,
}
export interface TokenInfo {
  'decimals' : bigint,
  'metadata' : [] | [Uint8Array | number[]],
  'logo' : string,
  'name' : string,
  'transferFee' : bigint,
  'symbol' : string,
  'canisterId' : string,
}
export interface Tokenomic { 'title' : string, 'value' : bigint }
export interface Transaction {
  'method' : string,
  'time' : Time,
  'txId' : [] | [bigint],
  'participant' : string,
  'amount' : bigint,
}
export interface VestingInfo {
  'duration' : bigint,
  'unlockFrequency' : bigint,
  'cliff' : bigint,
}
export interface _SERVICE extends LaunchpadCanister {}

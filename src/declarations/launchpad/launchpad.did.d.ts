import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export interface ClaimContract {
  'title' : string,
  'vesting' : VestingInfo,
  'total' : bigint,
  'description' : string,
  'recipients' : Array<Recipient>,
}
export interface Distribution {
  'team' : ClaimContract,
  'liquidity' : FixClaimContract,
  'others' : Array<ClaimContract>,
  'fairlaunch' : FixClaimContract,
}
export interface FixClaimContract {
  'title' : string,
  'vesting' : VestingInfo,
  'total' : bigint,
  'description' : string,
}
export interface LaunchParams {
  'softCap' : bigint,
  'sellAmount' : bigint,
  'hardCap' : bigint,
  'maximumAmount' : bigint,
  'minimumAmount' : bigint,
}
export interface LaunchpadDetail {
  'fee' : bigint,
  'saleToken' : TokenInfo,
  'creator' : string,
  'projectInfo' : ProjectInfo,
  'launchParams' : LaunchParams,
  'restrictedArea' : [] | [Array<string>],
  'purchaseToken' : TokenInfo,
  'affiliate' : bigint,
  'distribution' : Distribution,
  'timeline' : Timeline,
}
export interface LaunchpadIndex {
  'id' : string,
  'status' : LaunchpadStatus,
  'owner' : Principal,
  'name' : string,
  'createdAt' : Time,
  'description' : string,
  'updatedAt' : Time,
  'timeline' : Timeline,
}
export type LaunchpadStatus = { 'Ended' : null } |
  { 'Live' : null } |
  { 'Claim' : null } |
  { 'Completed' : null } |
  { 'Upcoming' : null };
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
export type Result = { 'ok' : null } |
  { 'err' : string };
export type Result_1 = { 'ok' : [] | [Principal] } |
  { 'err' : string };
export type Result_2 = { 'ok' : string } |
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
export interface VestingInfo {
  'duration' : bigint,
  'unlockFrequency' : bigint,
  'cliff' : bigint,
}
export interface _SERVICE {
  'createLaunchpad' : ActorMethod<[LaunchpadDetail], Result_2>,
  'getAllLaunchpads' : ActorMethod<
    [],
    Array<[string, LaunchpadIndex, LaunchpadStatus]>
  >,
  'getGovernanceId' : ActorMethod<[], Result_1>,
  'getLaunchpadsByStatus' : ActorMethod<
    [LaunchpadStatus],
    Array<[string, LaunchpadIndex]>
  >,
  'getUserParticipations' : ActorMethod<
    [string],
    {
      'participatedLaunchpads' : Array<
        [string, LaunchpadIndex, LaunchpadStatus]
      >,
    }
  >,
  'updateGovernanceCanister' : ActorMethod<[[] | [Principal]], Result>,
  'updateUserParticipation' : ActorMethod<[string], Result>,
}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];

import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export interface HttpRequest {
  'url' : string,
  'method' : string,
  'body' : Uint8Array | number[],
  'headers' : Array<headerField>,
}
export interface HttpResponse {
  'body' : Uint8Array | number[],
  'headers' : Array<headerField>,
  'status_code' : number,
}
export type Result = { 'ok' : null } |
  { 'err' : string };
export interface Token {
  'name' : string,
  'cover' : string,
  'description' : string,
  'canister' : string,
  'symbol' : string,
}
export type headerField = [string, string];
export interface _SERVICE {
  'addAdmin' : ActorMethod<[string], undefined>,
  'createTokenCanister' : ActorMethod<
    [string, string, string, bigint, string, number, bigint],
    string
  >,
  'cycleBalance' : ActorMethod<[], bigint>,
  'getAllAdmins' : ActorMethod<[], Array<string>>,
  'getAllTokens' : ActorMethod<[], Array<[string, string]>>,
  'getOwner' : ActorMethod<[string], [] | [string]>,
  'getTokenDetails' : ActorMethod<[string], [] | [Token]>,
  'getTokens' : ActorMethod<[bigint], Array<Token>>,
  'getTotalTokens' : ActorMethod<[], bigint>,
  'getUserTokens' : ActorMethod<[string, bigint], Array<Token>>,
  'getUserTotalTokens' : ActorMethod<[string], bigint>,
  'http_request' : ActorMethod<[HttpRequest], HttpResponse>,
  'removeAdmin' : ActorMethod<[string], undefined>,
  'updateInitCycles' : ActorMethod<[bigint], undefined>,
  'updateTokenCover' : ActorMethod<[string, string], Result>,
}

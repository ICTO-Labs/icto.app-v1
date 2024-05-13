import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export interface anon_class_13_1 {
  'addAdmin' : ActorMethod<[string], undefined>,
  'addUserContract' : ActorMethod<[string, string], undefined>,
  'cycleBalance' : ActorMethod<[], bigint>,
  'getAllAdmins' : ActorMethod<[], Array<string>>,
  'getContracts' : ActorMethod<[bigint], undefined>,
  'getUserContracts' : ActorMethod<[string], Array<string>>,
  'removeAdmin' : ActorMethod<[string], undefined>,
}
export interface _SERVICE extends anon_class_13_1 {}

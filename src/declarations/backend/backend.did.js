export const idlFactory = ({ IDL }) => {
  const canister_id = IDL.Principal;
  const CanisterSettings = IDL.Record({
    'freezing_threshold' : IDL.Nat,
    'controllers' : IDL.Vec(IDL.Principal),
    'memory_allocation' : IDL.Nat,
    'compute_allocation' : IDL.Nat,
  });
  const CanisterStatus = IDL.Record({
    'status' : IDL.Variant({
      'stopped' : IDL.Null,
      'stopping' : IDL.Null,
      'running' : IDL.Null,
    }),
    'freezing_threshold' : IDL.Nat,
    'memory_size' : IDL.Nat,
    'cycles' : IDL.Nat,
    'settings' : CanisterSettings,
    'module_hash' : IDL.Opt(IDL.Vec(IDL.Nat8)),
  });
  const DistributionType__1 = IDL.Variant({
    'Public' : IDL.Null,
    'Whitelist' : IDL.Null,
  });
  const Time = IDL.Int;
  const VestingType = IDL.Variant({
    'Standard' : IDL.Null,
    'Single' : IDL.Null,
  });
  const Recipient = IDL.Record({
    'note' : IDL.Opt(IDL.Text),
    'address' : IDL.Text,
    'amount' : IDL.Nat,
  });
  const TokenInfo = IDL.Record({
    'fee' : IDL.Nat,
    'decimals' : IDL.Nat,
    'name' : IDL.Text,
    'standard' : IDL.Text,
    'symbol' : IDL.Text,
    'canisterId' : IDL.Text,
  });
  const ContractData = IDL.Record({
    'startTime' : IDL.Nat,
    'distributionType' : DistributionType__1,
    'durationTime' : IDL.Nat,
    'durationUnit' : IDL.Nat,
    'title' : IDL.Text,
    'created' : Time,
    'autoTransfer' : IDL.Bool,
    'owner' : IDL.Principal,
    'startNow' : IDL.Bool,
    'blockId' : IDL.Nat,
    'description' : IDL.Text,
    'cliffTime' : IDL.Nat,
    'cliffUnit' : IDL.Nat,
    'vestingType' : VestingType,
    'maxRecipients' : IDL.Nat,
    'recipients' : IDL.Opt(IDL.Vec(Recipient)),
    'totalAmount' : IDL.Nat,
    'tokenInfo' : TokenInfo,
    'initialUnlockPercentage' : IDL.Nat,
    'unlockSchedule' : IDL.Nat,
    'allowCancel' : IDL.Bool,
  });
  const Result = IDL.Variant({ 'ok' : IDL.Principal, 'err' : IDL.Text });
  const DistributionType = IDL.Variant({
    'Public' : IDL.Null,
    'Whitelist' : IDL.Null,
  });
  const ContractMetadata = IDL.Record({
    'id' : IDL.Text,
    'distributionType' : DistributionType,
    'owner' : IDL.Text,
    'createdAt' : IDL.Int,
  });
  return IDL.Service({
    'addAdmin' : IDL.Func([IDL.Text], [], []),
    'addController' : IDL.Func([canister_id, IDL.Vec(IDL.Principal)], [], []),
    'cancelContract' : IDL.Func([IDL.Principal], [], []),
    'canister_status' : IDL.Func([canister_id], [CanisterStatus], []),
    'createContract' : IDL.Func([ContractData], [Result], []),
    'getAdmins' : IDL.Func([], [IDL.Vec(IDL.Text)], ['query']),
    'getAllContracts' : IDL.Func([], [IDL.Vec(ContractMetadata)], ['query']),
    'getContractMetadata' : IDL.Func(
        [IDL.Text],
        [IDL.Opt(ContractMetadata)],
        ['query'],
      ),
    'getContractsByWallet' : IDL.Func(
        [],
        [
          IDL.Record({
            'privateContracts' : IDL.Vec(IDL.Text),
            'publicContracts' : IDL.Vec(IDL.Text),
          }),
        ],
        ['query'],
      ),
    'getMyContracts' : IDL.Func([], [IDL.Vec(ContractMetadata)], []),
    'getPrivateContracts' : IDL.Func(
        [IDL.Text],
        [IDL.Vec(IDL.Text)],
        ['query'],
      ),
    'removeAdmin' : IDL.Func([IDL.Text], [], []),
    'whoami' : IDL.Func([], [IDL.Principal], []),
  });
};
export const init = ({ IDL }) => { return []; };

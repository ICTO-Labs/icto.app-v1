export const idlFactory = ({ IDL }) => {
  const anon_class_13_1 = IDL.Service({
    'addAdmin' : IDL.Func([IDL.Text], [], []),
    'addUserContract' : IDL.Func([IDL.Text, IDL.Text], [], []),
    'cycleBalance' : IDL.Func([], [IDL.Nat], ['query']),
    'getAllAdmins' : IDL.Func([], [IDL.Vec(IDL.Text)], ['query']),
    'getContracts' : IDL.Func([IDL.Nat], [], []),
    'getUserContracts' : IDL.Func([IDL.Text], [IDL.Vec(IDL.Text)], ['query']),
    'removeAdmin' : IDL.Func([IDL.Text], [], []),
  });
  return anon_class_13_1;
};
export const init = ({ IDL }) => { return []; };

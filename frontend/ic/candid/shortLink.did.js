export default ({ IDL }) => {
const Time = IDL.Int;
const ShortLink = IDL.Record({
    'title' : IDL.Text,
    'imagePreview' : IDL.Text,
    'owner' : IDL.Principal,
    'createdAt' : Time,
    'path' : IDL.Text,
    'targetUrl' : IDL.Text,
    'keywords' : IDL.Vec(IDL.Text),
    'updatedAt' : Time,
    'clickCount' : IDL.Nat,
    'canisterId' : IDL.Text,
});
return IDL.Service({
    'createLink' : IDL.Func(
        [
        IDL.Text,
        IDL.Text,
        IDL.Text,
        IDL.Opt(IDL.Text),
        IDL.Opt(IDL.Vec(IDL.Text)),
        IDL.Opt(IDL.Text),
        ],
        [IDL.Bool],
        [],
    ),
    'deleteLink' : IDL.Func([IDL.Text], [IDL.Bool], []),
    'getLink' : IDL.Func([IDL.Text], [IDL.Opt(ShortLink)], ['query']),
    'getLinkByCanisterId' : IDL.Func(
        [IDL.Text, IDL.Text],
        [IDL.Opt(IDL.Vec(IDL.Tuple(IDL.Text, ShortLink)))],
        [],
    ),
    'getUserLinks' : IDL.Func(
        [IDL.Principal],
        [IDL.Vec(IDL.Tuple(IDL.Text, ShortLink))],
        ['query'],
    ),
    'incrementClickCount' : IDL.Func([IDL.Text], [], []),
    'redirect' : IDL.Func([IDL.Text], [IDL.Opt(IDL.Text)], ['query']),
    'updateLink' : IDL.Func(
        [
        IDL.Text,
        IDL.Opt(IDL.Text),
        IDL.Opt(IDL.Text),
        IDL.Opt(IDL.Text),
        IDL.Opt(IDL.Vec(IDL.Text)),
        IDL.Opt(IDL.Text),
        ],
        [IDL.Bool],
        [],
    ),
});
};
export const init = ({ IDL }) => { return []; };
import Trie "mo:base/Trie";
import Text "mo:base/Text";

module {
    public func _isAdmin(adminList : [Text], p : Text) : (Bool) {
        for (i in adminList.vals()) {
            if (i == p) {
                return true;
            };
        };
        return false;
    };

    public func keyT(x : Text) : Trie.Key<Text> {
        return { hash = Text.hash(x); key = x };
    };
    public func key(x : Nat32) : Trie.Key<Nat32> {
        return { hash = x; key = x };
    };
}
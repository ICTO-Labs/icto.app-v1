module {
    public type CanisterSettings = {
        freezing_threshold  : Nat;
        controllers         : [Principal];
        memory_allocation   : Nat;
        compute_allocation  : Nat;
    };
    public type CanisterStatus = {
        status              : { #stopped; #stopping; #running };
        freezing_threshold  : Nat;
        memory_size         : Nat;
        cycles              : Nat;
        settings            : CanisterSettings;
        module_hash         : ?[Nat8];
        // idle_cycles_burned_per_second : Float;
    };
}
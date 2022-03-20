
# rule balanced-token-seq { <balancedrule>+ }
our class BalancedTokenSeq { 
    has IBalancedrule @.balancedrules is required;

    has $.text;

    method gist{
        say "need write gist!";
        ddt self;
        exit;
    }
}


# rule balancedrule:sym<parens> { 
#   <.left-paren> 
#   <balanced-token-seq> 
#   <.right-paren> 
# }
our class Balancedrule::Parens does IBalancedrule {
    has BalancedTokenSeq $.balanced-token-seq is required;

    has $.text;

    method gist{
        say "need write gist!";
        ddt self;
        exit;
    }
}

# rule balancedrule:sym<brackets> { 
#   <.left-bracket> 
#   <balanced-token-seq> 
#   <.right-bracket> 
# }
our class Balancedrule::Brackets does IBalancedrule {
    has BalancedTokenSeq $.balanced-token-seq is required;

    has $.text;

    method gist{
        say "need write gist!";
        ddt self;
        exit;
    }
}

# rule balancedrule:sym<braces> { 
#   <.left-brace> 
#   <balanced-token-seq> 
#   <.right-brace> 
# } 
our class Balancedrule::Braces does IBalancedrule {
    has BalancedTokenSeq $.balanced-token-seq is required;

    has $.text;

    method gist{
        say "need write gist!";
        ddt self;
        exit;
    }
}

our role Balanced::Actions {

    # rule balanced-token-seq { <balancedrule>+ } 
    method balanced-token-seq($/) {
        make $<balancedrule>>>.made
    }

    # rule balancedrule:sym<parens> { <.left-paren> <balanced-token-seq> <.right-paren> }
    method balancedrule:sym<parens>($/) {
        make $<balanced-token-seq>.made
    }

    # rule balancedrule:sym<brackets> { <.left-bracket> <balanced-token-seq> <.right-bracket> }
    method balancedrule:sym<brackets>($/) {
        make $<balanced-token-seq>.made
    }

    # rule balancedrule:sym<braces> { <.left-brace> <balanced-token-seq> <.right-brace> } 
    method balancedrule:sym<braces>($/) {
        make $<balanced-token-seq>.made
    }
}


# token literal:sym<ptr> { <pointer-literal> }
our class PointerLiteral does ILiteral {

    has $.text;

    method gist {
        say "need write gist!";
        ddt self;
        exit;
    }
}

our role PointerLiteral::Actions {

    # token pointer-literal { <nullptr> } 
    method pointer-literal($/) {
        make PointerLiteral.new
    }

}

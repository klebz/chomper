our class ConstDefault {
    has $.expr;
}

our class ConstDefault::Rules {

    proto rule maybe-const_default { * }

    rule maybe-const_default:sym<a> {
        '=' <expr>
    }

    rule maybe-const_default:sym<b> {

    }
}

our class ConstDefault::Actions {

    method maybe-const_default:sym<a>($/) {
        make ConstDefault.new(
            expr =>  $<expr>.made,
        )
    }

    method maybe-const_default:sym<b>($/) {
        MkNone<140324429464512>
    }
}

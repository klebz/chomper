our class ForLifetimes::Rules {

    proto rule maybe-for_lifetimes { * }

    rule maybe-for_lifetimes:sym<a> {
        <FOR> '<' <lifetimes> '>'
    }

    rule maybe-for_lifetimes:sym<b> {
        # %prec FORTYPE 
    }
}

our class ForLifetimes::Actions {

    method maybe-for_lifetimes:sym<a>($/) {
        MkNone<140569789206720>
    }

    method maybe-for_lifetimes:sym<b>($/) {
        MkNone<140569789206752>
    }
}
use grust-model;

our role MutOrConst::Rules {

    rule maybe-mut          { <kw-mut>? }
    rule maybe-mut-or-const { [<kw-mut> | <kw-const>]? }
}

our role MutOrConst::Actions {

    method maybe-mut($/) { 
        if $/<kw-mut>:exists {
            make MutMutable.new 
        } else {
            make MutImmutable.new 
        }
    }

    method maybe-mut-or-const($/) { 
        if $/<kw-mut>:exists {
            make MutMutable.new 
        } else {
            make MutImmutable.new 
        }
    }
}

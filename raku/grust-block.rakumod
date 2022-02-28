use grust-model;

our role InnerAttrsAndBlock::Rules {

    rule inner-attrs-and-block {
        '{' <maybe-inner-attrs> <maybe-stmts> '}'
    }
}

our role InnerAttrsAndBlock::Actions {

    method inner-attrs-and-block($/) {
        make ExprBlock.new(
            maybe-inner-attrs =>  $<maybe-inner-attrs>.made,
            maybe-stmts       =>  $<maybe-stmts>.made,
        )
    }
}

#---------------------------------

our role Block::Rules {

    rule block {
        '{' <maybe-stmts> '}'
    }
}

our role Block::Actions {

    method block($/) {
        make ExprBlock.new(
            maybe-stmts =>  $<maybe-stmts>.made,
        )
    }
}

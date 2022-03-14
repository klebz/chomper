our class ImplTraitType {
    has $.type-param-bounds;

    has $.text;

    submethod TWEAK {
        say self.gist;
    }

    method gist {
        say "need to write gist!";
        say $.text;
        ddt self;
        exit;
    }
}

our class ImplTraitTypeOneBound {
    has $.trait-bound;

    has $.text;

    submethod TWEAK {
        say self.gist;
    }

    method gist {
        say "need to write gist!";
        say $.text;
        ddt self;
        exit;
    }
}

our role ImplTraitType::Rules {

    rule impl-trait-type {
        <kw-impl>
        <type-param-bounds>
    }

    rule impl-trait-type-one-bound {
        <kw-impl>
        <trait-bound>
    }
}

our role ImplTraitType::Actions {

    method impl-trait-type($/) {
        make ImplTraitType.new(
            type-param-bounds => $<type-param-bounds>.made
        )
    }

    method impl-trait-type-one-bound($/) {
        make ImplTraitTypeOneBound.new(
            trait-bound => $<trait-bound>.made
        )
    }
}
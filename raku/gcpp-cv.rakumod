
# rule cvqualifierseq { <cv-qualifier>+ }
our class Cvqualifierseq { 
    has ICvQualifier @.cv-qualifiers;

    has $.text;

    method gist{
        say "need write gist!";
        ddt self;
        exit;
    }
}

# rule cv-qualifier:sym<const> { <const> }
our class CvQualifier::Const does ICvQualifier {

    has $.text;

    method gist{
        say "need write gist!";
        ddt self;
        exit;
    }
}

# rule cv-qualifier:sym<volatile> { <volatile> }
our class CvQualifier::Volatile does ICvQualifier {

    has $.text;

    method gist{
        say "need write gist!";
        ddt self;
        exit;
    }
}

our role CV::Actions {

    # rule cvqualifierseq { <cv-qualifier>+ } 
    method cvqualifierseq($/) {
        make $<cv-qualifier>>>.made
    }

    # rule cv-qualifier:sym<const> { <const> }
    method cv-qualifier:sym<const>($/) {
        make CvQualifier::Const.new
    }

    # rule cv-qualifier:sym<volatile> { <volatile> } 
    method cv-qualifier:sym<volatile>($/) {
        make CvQualifier::Volatile.new
    }
}

our role CV::Rules {

    rule cvqualifierseq {
        <cv-qualifier>+
    }

    proto rule cv-qualifier { * }
    rule cv-qualifier:sym<const>    { <const> }
    rule cv-qualifier:sym<volatile> { <volatile> }
}

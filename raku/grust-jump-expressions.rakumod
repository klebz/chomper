our class ContinueExpression {
    has $.maybe-lifetime-or-label;

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

our class BreakExpression {
    has $.maybe-lifetime-or-label;
    has $.maybe-expression;

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

our class ReturnExpression {
    has $.maybe-expression;

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

our role JumpExpression::Rules {

    rule continue-expression {
        <kw-continue>
        <lifetime-or-label>?
    }

    rule break-expression {
        <kw-break> 
        <lifetime-or-label>?
        <expression>?
    }

    rule return-expression {
        <kw-return> <expression>? 
    }
}

our role JumpExpression::Actions {

    method continue-expression($/) {
        <kw-continue>
        <lifetime-or-label>?
    }

    method break-expression($/) {
        <kw-break> 
        <lifetime-or-label>?
        <expression>?
    }

    method return-expression($/) {
        <kw-return> <expression>? 
    }
}
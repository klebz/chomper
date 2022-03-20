our class IdentifierStart::Nondigit 
does IIdentifierStart {

    has Nondigit $.nondigit is required;

    has $.text;

    method gist {
        say "need write gist!";
        ddt self;
        exit;
    }
}

our class IdentifierStart::Ucn 
does IIdentifierStart {

    has Universalcharactername $.universalcharactername is required;

    has $.text;

    method gist {
        say "need write gist!";
        ddt self;
        exit;
    }
}

our class IdentifierContinue::Digit 
does IIdentifierContinue {

    has Digit $.digit is required;

    has $.text;

    method gist {
        say "need write gist!";
        ddt self;
        exit;
    }
}

our class IdentifierContinue::Nondigit 
does IIdentifierContinue {

    has Nondigit $.nondigit is required;

    has $.text;

    method gist {
        say "need write gist!";
        ddt self;
        exit;
    }
}

our class IdentifierContinue::Ucn 
does IIdentifierContinue {

    has Universalcharactername $.universalcharactername is required;

    has $.text;

    method gist {
        say "need write gist!";
        ddt self;
        exit;
    }
}

our class Identifier 
does ITheTypeId
does ITemplateArgument
does ISimpleTypeSpecifier
does IConstantExpression
does IDeclSpecifier
does IPointerMemberExpression
does INoPointerDeclarator
does IForRangeInitializer
does IMultiplicativeExpression
does IInitDeclarator
does IUnqualifiedId
does IIdExpression
does IPostfixExpressionBody
does IPostfixExpressionTail
does IPostListHead
does IDeclarator
does IDeclSpecifierSeq
does INoPointerDeclaratorBase
does ITheTypeName { 
    has Str $.value is required; 
}

our class Nondigit {
    has Str $.value is required; 

    has $.text;

    method gist {

        say "need write gist!";
        ddt self;
        exit;
    }
}

our role Identifier::Actions {

    # token identifier-start:sym<nondigit> { <nondigit> }
    method identifier-start:sym<nondigit>($/) {
        make $<nondigit>.made
    }

    # token identifier-start:sym<ucn> { <universalcharactername> } 
    method identifier-start:sym<ucn>($/) {
        make $<universalcharactername>.made
    }

    # token identifier-continue:sym<digit> { <digit> }
    method identifier-continue:sym<digit>($/) {
        make $<digit>.made
    }

    # token identifier-continue:sym<nondigit> { <nondigit> }
    method identifier-continue:sym<nondigit>($/) {
        make $<nondigit>.made
    }

    # token identifier-continue:sym<ucn> { <universalcharactername> }
    method identifier-continue:sym<ucn>($/) {
        make $<universalcharactername>.made
    }

    # token identifier { <identifier-start> <identifier-continue>* }
    method identifier($/) {
        make Identifier.new(
            value => ~$/,
        )
    }

    # token nondigit { <[ a .. z A .. Z _]> }
    method nondigit($/) {
        make Nondigit.new(
            value => ~$/,
        )
    }

    # token digit { <[ 0 .. 9 ]> }
    method digit($/) {
        make Digit.new(
            value => ~$/,
        )
    }
}

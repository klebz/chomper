unit module Chomper::Cpp::GcppChar;

use Data::Dump::Tree;

use Chomper::Cpp::GcppRoles;
use Chomper::Cpp::GcppHex;

class UniversalCharacterName is export {
    has HexQuad $.first is required;
    has HexQuad $.second;

    has $.text;

    method name {
        'UniversalCharacterName'
    }

    method gist(:$treemark=False) {
        if $.second {
            "\\U" ~ $.first.gist(:$treemark) ~ $.second.gist(:$treemark)
        } else {
            "\\u" ~ $.first.gist(:$treemark)
        }
    }
}

class BasicCchar does ICchar is export {
    has Str $.value is required;

    has $.text;

    method name {
        'BasicCchar'
    }

    method gist(:$treemark=False) {

        $.value
    }
}

class EscapeCchar does ICchar is export {
    has IEscapeSequence $.escapesequence is required;

    has $.text;

    method name {
        'EscapeCchar'
    }

    method gist(:$treemark=False) {
        $.escapesequence.gist(:$treemark)
    }
}

class UniversalCchar does ICchar is export {
    has UniversalCharacterName $.universalcharactername is required;

    has $.text;

    method name {
        'UniversalCchar'
    }

    method gist(:$treemark=False) {
        $.universalcharactername.gist(:$treemark)
    }
}

class BasicSchar does ISchar is export {
    has Str $.value is required;

    has $.text;

    method name {
        'BasicSchar'
    }

    method gist(:$treemark=False) {
        $.value.gist(:$treemark)
    }
}

class EscapeSchar does ISchar is export {
    has IEscapeSequence $.escapesequence is required;

    has $.text;

    method name {
        'EscapeSchar'
    }

    method gist(:$treemark=False) {
        $.escapesequence.gist(:$treemark)
    }
}

class UcnSchar does ISchar is export {
    has UniversalCharacterName $.universalcharactername is required;

    has $.text;

    method name {
        'UcnSchar'
    }

    method gist(:$treemark=False) {
        $.universalcharactername.gist(:$treemark)
    }
}

class CharacterLiteralPrefixU    does ICharacterLiteralPrefix is export { 

    has $.text;

    method name {
        'CharacterLiteralPrefixU'
    }

    method gist(:$treemark=False) {
        'u'
    }
}

class CharacterLiteralPrefixBigU does ICharacterLiteralPrefix is export { 

    has $.text;

    method name {
        'CharacterLiteralPrefixBigU'
    }

    method gist(:$treemark=False) {
        'U'
    }
}

class CharacterLiteralPrefixL    does ICharacterLiteralPrefix is export { 

    has $.text;

    method name {
        'CharacterLiteralPrefixL'
    }

    method gist(:$treemark=False) {
        'L'
    }
}

#-------------------------------
# token literal:sym<char> { <character-literal> }
class CharacterLiteral 
does ILiteral
does IInitializerClause is export {
    has ICharacterLiteralPrefix $.character-literal-prefix;
    has ICchar                  @.cchar;

    has $.text;

    method name {
        'CharacterLiteral'
    }

    method gist(:$treemark=False) {

        if $treemark {
            return "L";
        }

        my $builder = "";

        if $.character-literal-prefix {
            $builder ~= $.character-literal-prefix.gist(:$treemark);
        }

        $builder = "'";

        for @.cchar {
            $builder ~= $_.gist(:$treemark);
        }

        $builder ~ "'"
    }
}

package CharacterLiteralGrammar is export {

    our role Actions {

        # token character-literal-prefix:sym<u> { 'u' }
        method character-literal-prefix:sym<u>($/) {
            make 'u'
        }

        # token character-literal-prefix:sym<U> { 'U' }
        method character-literal-prefix:sym<U>($/) {
            make 'U'
        }

        # token character-literal-prefix:sym<L> { 'L' }
        method character-literal-prefix:sym<L>($/) {
            make 'L'
        }

        # token character-literal { <character-literal-prefix>? '\'' <cchar>+ '\'' } 
        method character-literal($/) {
            make CharacterLiteral.new(
                character-literal-prefix => $<character-literal-prefix>.made,
                cchar                    => $<cchar>>>.made,
                text                     => ~$/,
            )
        }

        # token universalcharactername:sym<one> { '\\u' <hexquad> }
        method universalcharactername:sym<one>($/) {
            make UniversalCharacterName.new(
                first => $<first>.made,
                text  => ~$/,
            )
        }

        # token universalcharactername:sym<two> { '\\U' <hexquad> <hexquad> } 
        method universalcharactername:sym<two>($/) {
            make UniversalCharacterName.new(
                first  => $<first>.made,
                second => $<second>.made,
                text   => ~$/,
            )
        }

        # token cchar:sym<basic> { <-[ \' \\ \r \n ]> }
        method cchar:sym<basic>($/) {
            make BasicCchar.new(
                value => ~$/,
            )
        }

        # token cchar:sym<escape> { <escapesequence> }
        method cchar:sym<escape>($/) {
            make $<escapesequence>.made
        }

        # token cchar:sym<universal> { <universalcharactername> } 
        method cchar:sym<universal>($/) {
            make $<universalcharactername>.made
        }

        # token schar:sym<basic> { <-[ " \\ \r \n ]> }
        method schar:sym<basic>($/) {
            make BasicSchar.new(
                value => ~$/,
            )
        }

        # token schar:sym<escape> { <escapesequence> }
        method schar:sym<escape>($/) {
            make $<escapesequence>.made
        }

        # token schar:sym<ucn> { <universalcharactername> }
        method schar:sym<ucn>($/) {
            make $<universalcharactername>.made
        }
    }

    our role Rules {

        proto token character-literal-prefix { * }
        token character-literal-prefix:sym<u> { 'u' }
        token character-literal-prefix:sym<U> { 'U' }
        token character-literal-prefix:sym<L> { 'L' }

        token character-literal {
            <character-literal-prefix>? '\'' <cchar>+ '\''
        }

        proto token cchar { * }
        token cchar:sym<basic>     { <-[ \' \\ \r \n ]> }
        token cchar:sym<escape>    { <escapesequence> }
        token cchar:sym<universal> { <universalcharactername> }

        proto token universalcharactername { * }
        token universalcharactername:sym<one> { '\\u' <hexquad> }
        token universalcharactername:sym<two> { '\\U' <hexquad> <hexquad> }

        proto token schar { * }
        token schar:sym<basic>  { <-[ " \\ \r \n ]> }
        token schar:sym<escape> { <escapesequence> }
        token schar:sym<ucn>    { <universalcharactername> }
    }
}

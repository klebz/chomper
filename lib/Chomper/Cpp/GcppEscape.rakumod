unit module Chomper::Cpp::GcppEscape;

use Data::Dump::Tree;

use Chomper::Cpp::GcppRoles;
use Chomper::Cpp::GcppHex;
use Chomper::Cpp::GcppOct;

package EscapeSequence is export {

    our class Simple does IEscapeSequence {
        has ISimpleEscapeSequence $.simpleescapesequence is required;

        has $.text;

        method name {
            'EscapeSequence::Simple'
        }

        method gist(:$treemark=False) {
            $.simpleescapesequence.gist(:$treemark)
        }
    }

    our class Octal does IEscapeSequence {
        has OctalEscapeSequence $.octalescapesequence is required;

        has $.text;

        method name {
            'EscapeSequence::Octal'
        }

        method gist(:$treemark=False) {
            $.octalescapesequence.gist(:$treemark)
        }
    }

    our class Hex does IEscapeSequence {
        has HexadecimalEscapeSequence $.hexadecimalescapesequence is required;

        has $.text;

        method name {
            'EscapeSequence::Hex'
        }

        method gist(:$treemark=False) {
            $.hexadecimalescapesequence.gist(:$treemark)
        }
    }
}

package SimpleEscapeSequence is export {

    our class Slash does ISimpleEscapeSequence { 
        has $.text;

        method name {
            'SimpleEscapeSequence::Slash'
        }

        method gist(:$treemark=False) {
            '\\\''
        }
    }

    our class Quote does ISimpleEscapeSequence { 
        has $.text;

        method name {
            'SimpleEscapeSequence::Quote'
        }

        method gist(:$treemark=False) {
            '\\"'
        }
    }

    our class Question does ISimpleEscapeSequence { 
        has $.text;

        method name {
            'SimpleEscapeSequence::Question'
        }

        method gist(:$treemark=False) {
            '\\?'
        }
    }

    our class DoubleSlash does ISimpleEscapeSequence { 
        has $.text;

        method name {
            'SimpleEscapeSequence::DoubleSlash'
        }

        method gist(:$treemark=False) {
            '\\\\'
        }
    }

    our class A does ISimpleEscapeSequence { 
        has $.text;

        method name {
            'SimpleEscapeSequence::A'
        }

        method gist(:$treemark=False) {
            '\\a'
        }
    }

    our class B does ISimpleEscapeSequence { 
        has $.text;

        method name {
            'SimpleEscapeSequence::B'
        }

        method gist(:$treemark=False) {
            '\\b'
        }
    }

    our class F does ISimpleEscapeSequence { 
        has $.text;

        method name {
            'SimpleEscapeSequence::F'
        }

        method gist(:$treemark=False) {
            '\\f'
        }
    }

    our class N does ISimpleEscapeSequence { 
        has $.text;

        method name {
            'SimpleEscapeSequence::N'
        }

        method gist(:$treemark=False) {
            '\\n'
        }
    }

    our class R does ISimpleEscapeSequence { 
        has $.text;

        method name {
            'SimpleEscapeSequence::R'
        }

        method gist(:$treemark=False) {
            '\\r'
        }
    }

    our class T does ISimpleEscapeSequence { 
        has $.text;

        method name {
            'SimpleEscapeSequence::T'
        }

        method gist(:$treemark=False) {
            '\\t'
        }
    }

    our class V does ISimpleEscapeSequence { 
        has $.text;

        method name {
            'SimpleEscapeSequence::V'
        }

        method gist(:$treemark=False) {
            '\\v'
        }
    }

    our class RnN does ISimpleEscapeSequence { 
        has $.text;

        method name {
            'SimpleEscapeSequence::RnN'
        }

        method gist(:$treemark=False) {
            '\\\n'
        }
    }
}

package EscapeGrammar is export {

    our role Actions {

        # token escapesequence:sym<simple> { <simpleescapesequence> }
        method escapesequence:sym<simple>($/) {
            make $<simpleescapesequence>.made
        }

        # token escapesequence:sym<octal> { <octalescapesequence> }
        method escapesequence:sym<octal>($/) {
            make $<octalescapesequence>.made
        }

        # token escapesequence:sym<hex> { <hexadecimalescapesequence> } 
        method escapesequence:sym<hex>($/) {
            make $<hexadecimalescapesequence>.made
        }

        # token simpleescapesequence:sym<slash> { '\\\'' }
        method simpleescapesequence:sym<slash>($/) {
            make SimpleEscapeSequence::Slash.new
        }

        # token simpleescapesequence:sym<quote> { '\\"' }
        method simpleescapesequence:sym<quote>($/) {
            make SimpleEscapeSequence::Quote.new
        }

        # token simpleescapesequence:sym<question> { '\\?' }
        method simpleescapesequence:sym<question>($/) {
            make SimpleEscapeSequence::Question.new
        }

        # token simpleescapesequence:sym<double-slash> { '\\\\' }
        method simpleescapesequence:sym<double-slash>($/) {
            make SimpleEscapeSequence::DoubleSlash.new
        }

        # token simpleescapesequence:sym<a> { '\\a' }
        method simpleescapesequence:sym<a>($/) {
            make SimpleEscapeSequence::A.new
        }

        # token simpleescapesequence:sym<b> { '\\b' }
        method simpleescapesequence:sym<b>($/) {
            make SimpleEscapeSequence::B.new
        }

        # token simpleescapesequence:sym<f> { '\\f' }
        method simpleescapesequence:sym<f>($/) {
            make SimpleEscapeSequence::F.new
        }

        # token simpleescapesequence:sym<n> { '\\n' }
        method simpleescapesequence:sym<n>($/) {
            make SimpleEscapeSequence::N.new
        }

        # token simpleescapesequence:sym<r> { '\\r' }
        method simpleescapesequence:sym<r>($/) {
            make SimpleEscapeSequence::R.new
        }

        # token simpleescapesequence:sym<t> { '\\t' }
        method simpleescapesequence:sym<t>($/) {
            make SimpleEscapeSequence::T.new
        }

        # token simpleescapesequence:sym<v> { '\\v' }
        method simpleescapesequence:sym<v>($/) {
            make SimpleEscapeSequence::V.new
        }

        # token simpleescapesequence:sym<rn-n> { '\\' [ || '\r' '\n'? || '\n' ] } 
        method simpleescapesequence:sym<rn-n>($/) {
            make SimpleEscapeSequence::RnN.new
        }

        # token octalescapesequence { '\\' [<octaldigit> ** 1..3] }
        method octalescapesequence($/) {
            make OctalEscapeSequence.new(
                digits => $<octaldigit>>>.made,
                text   => ~$/,
            )
        }

        # token hexadecimalescapesequence { '\\x' <hexadecimaldigit>+ }
        method hexadecimalescapesequence($/) {
            make HexadecimalEscapeSequence.new(
                digits => $<hexadecimaldigit>>>.made,
                text   => ~$/,
            )
        }
    }

    our role Rules {

        proto token escapesequence { * }
        token escapesequence:sym<simple> { <simpleescapesequence> }
        token escapesequence:sym<octal>  { <octalescapesequence> }
        token escapesequence:sym<hex>    { <hexadecimalescapesequence> }

        proto token simpleescapesequence { * }
        token simpleescapesequence:sym<slash>        { '\\\'' }
        token simpleescapesequence:sym<quote>        { '\\"' }
        token simpleescapesequence:sym<question>     { '\\?' }
        token simpleescapesequence:sym<double-slash> { '\\\\' }
        token simpleescapesequence:sym<a>            { '\\a' }
        token simpleescapesequence:sym<b>            { '\\b' }
        token simpleescapesequence:sym<f>            { '\\f' }
        token simpleescapesequence:sym<n>            { '\\n' }
        token simpleescapesequence:sym<r>            { '\\r' }
        token simpleescapesequence:sym<t>            { '\\t' }
        token simpleescapesequence:sym<v>            { '\\v' }
        token simpleescapesequence:sym<rn-n> {
            '\\'
            [   
                ||  '\r' '\n'?
                ||  '\n'
            ]
        }

        token octalescapesequence {
            '\\' [<octaldigit> ** 1..3]
        }

        token hexadecimalescapesequence {
            '\\x' <hexadecimaldigit>+
        }
    }
}

unit module Chomper::Rust::GrustIdentifiers;

use Data::Dump::Tree;

use Chomper::Rust::GrustStrictKeywords;
use Chomper::Rust::GrustReservedKeywords;

class IdentifierOrKeyword is export {
    has Str $.value;

    has $.text;

    method gist {
        $.value
    }
}

class Identifier is export {
    has Str $.value;

    method gist {
        $.value.chomp
    }
}

sub is-not-crate-self-super-or-Self($token) is export {
    $token !~~ /crate | self | super | Self/
}

sub is-not-strict-or-reserved-keyword($token) is export {
    my $strict   = $StrictKeywords::strict-keyword;
    my $reserved = $ReservedKeywords::reserved-keyword;

    [
        $token !~~ /^^ $strict $$/,
        $token !~~ /^^ $reserved $$/
    ].all
}

package IdentifiersGrammar is export {

    our role Rules {

        proto token identifier-or-keyword { * }
        token identifier-or-keyword:sym<a> { <xid-start> <xid-continue>* }
        token identifier-or-keyword:sym<b> { _ <xid-continue>* }

        token raw-identifier {
            "r#" 
            (<identifier-or-keyword>) <?{is-not-crate-self-super-or-Self($0)}>
        }

        token non-keyword-identifier {
            (<identifier-or-keyword>) <?{is-not-strict-or-reserved-keyword($0)}>
        }

        proto token identifier { * }
        token identifier:sym<a> { <non-keyword-identifier> }
        token identifier:sym<b> { <raw-identifier> }

        #---------------------
        proto rule identifier-or-underscore { * }

        rule identifier-or-underscore:sym<identifier> {
            <identifier>
        }

        rule identifier-or-underscore:sym<underscore> {
            <tok-underscore>
        }
    }

    our role Actions {

        method identifier-or-keyword:sym<a>($/) { make ~$/ }
        method identifier-or-keyword:sym<b>($/) { make ~$/ }

        method raw-identifier($/) {
            make ~$/
        }

        method non-keyword-identifier($/) {
            make ~$/
        }

        method identifier:sym<a>($/) { 
            make Identifier.new(
                value => ~$/ 
            )
        }

        method identifier:sym<b>($/) { 
            make Identifier.new(
                value =>~$/ 
            )
        }

        #---------------------
        method identifier-or-underscore:sym<identifier>($/) { make ~$/ }
        method identifier-or-underscore:sym<underscore>($/) { make ~$/ }
    }
}

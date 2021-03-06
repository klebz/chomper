unit module Chomper::Cpp::GcppTypeId;

use Data::Dump::Tree;

use Chomper::Cpp::GcppRoles;
use Chomper::Cpp::GcppIdent;
use Chomper::Cpp::GcppTemplate;

# rule the-type-id { 
#   <type-specifier-seq> 
#   <abstract-declarator>? 
# }
class TheTypeId 
does ITheTypeId 
does ITemplateArgument is export { 

    has $.type-specifier-seq is required;
    has IAbstractDeclarator $.abstract-declarator;
    
    has $.text;

    method name {
        'TheTypeId'
    }

    method gist(:$treemark=False) {

        my $builder = $.type-specifier-seq>>.gist(:$treemark).join(" ");

        if $.abstract-declarator {
            $builder ~= " " ~ $.abstract-declarator.gist(:$treemark);
        }

        $builder
    }
}

# rule type-id-list { 
#   <the-type-id> 
#   <ellipsis>? 
#   [ <.comma> <the-type-id> <ellipsis>? ]* 
# }
class TypeIdList is export { 
    has ITheTypeId @.the-type-ids is required;

    has $.text;

    method name {
        'TypeIdList'
    }

    method gist(:$treemark=False) {
        @.the-type-ids>>.gist(:$treemark).join(", ")
    }
}

package TypeNameSpecifier is export {

    # rule type-name-specifier:sym<ident> { 
    #   <typename_> 
    #   <nested-name-specifier> 
    #   <identifier> 
    # }
    our class Ident 
    does IDeclSpecifierSeq
    does ITypeNameSpecifier {
        has INestedNameSpecifier $.nested-name-specifier is required;
        has Identifier $.identifier is required;
        has $.text;

        method name {
            'TypeNameSpecifier::Ident'
        }

        method gist(:$treemark=False) {
            "typename " 
            ~ $.nested-name-specifier.gist(:$treemark) 
            ~ " " 
            ~ $.identifier.gist(:$treemark)
        }
    }

    # rule type-name-specifier:sym<template> { 
    #   <typename_> 
    #   <nested-name-specifier> 
    #   <template>? 
    #   <simple-template-id> 
    # }
    our class Template does ITypeNameSpecifier {
        has INestedNameSpecifier $.nested-name-specifier is required;
        has Bool                $.has-template          is required;
        has SimpleTemplateId    $.simple-template-id    is required;

        has $.text;

        method name {
            'TypeNameSpecifier::Template'
        }

        method gist(:$treemark=False) {

            my $builder = "typename "
            ~ $.nested-name-specifier.gist(:$treemark)
            ~ " ";

            if $.has-template {
                $builder ~= "template ";
            }

            $builder ~ $.simple-template-id.gist(:$treemark)
        }
    }
}

package TypeIdGrammar is export {

    our role Actions {

        # rule the-type-id { <type-specifier-seq> <abstract-declarator>? } 
        method the-type-id($/) {

            my $tail = $<abstract-declarator>.made;
            my $body = $<type-specifier-seq>.made;

            if $tail {
                make TheTypeId.new(
                    type-specifier-seq  => $body,
                    abstract-declarator => $tail,
                    text                => ~$/,
                )
            } else {
                make TheTypeId.new(
                    type-specifier-seq  => $body,
                    abstract-declarator => Nil,
                    text                => ~$/,
                )
            }
        }

        # rule type-id-list { <the-type-id> <ellipsis>? [ <.comma> <the-type-id> <ellipsis>? ]* } 
        method type-id-list($/) {
            make $<the-type-id>>>.made
        }
    }

    our role Rules {

        rule type-id-of-the-type-id {
            <typeid_>
        }

        rule type-id-list {
             <the-type-id> <ellipsis>? [ <comma> <the-type-id> <ellipsis>? ]*
        }

        rule the-type-id {
            <type-specifier-seq> <abstract-declarator>?
        }
    }
}

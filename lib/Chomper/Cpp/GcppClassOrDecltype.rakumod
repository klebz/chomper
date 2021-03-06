unit module Chomper::Cpp::GcppClassOrDecltype;

use Data::Dump::Tree;

use Chomper::Cpp::GcppRoles;
use Chomper::Cpp::GcppDecltype;

package ClassOrDeclType is export {

    # rule class-or-decl-type:sym<class> { 
    #   <nested-name-specifier>? 
    #   <class-name> 
    # }
    our class Class_ does IClassOrDeclType {
        has INestedNameSpecifier $.nested-name-specifier;
        has IClassName           $.class-name is required;
        has $.text;

        method name {
            'ClassOrDeclType::Class'
        }

        method gist(:$treemark=False) {

            my $builder = "";

            if $.nested-name-specifier {
                $builder ~= $.nested-name-specifier.gist(:$treemark);
            }

            $builder ~ $.class-name.gist(:$treemark)
        }
    }

    # rule class-or-decl-type:sym<decltype> { 
    #   <decltype-specifier> 
    # }
    our class Decltype does IClassOrDeclType {
        has DecltypeSpecifier $.decltype-specifier is required;
        has $.text;

        method name {
            'ClassOrDeclType::Decltype'
        }

        method gist(:$treemark=False) {
            $.decltype-specifier.gist(:$treemark)
        }
    }
}

package ClassOrDeclTypeGrammar is export {

    our role Actions {

        # rule class-or-decl-type:sym<class> { <nested-name-specifier>? <class-name> }
        method class-or-decl-type:sym<class>($/) {

            my $prefix = $<nested-name-specifier>.made;
            my $base   = $<class-name>.made;

            if $prefix {
                make ClassOrDeclType::Class_.new(
                    nested-name-specifier => $prefix,
                    class-name            => $base,
                )

            } else {

                make $base
            }
        }

        # rule class-or-decl-type:sym<decltype> { <decltype-specifier> } 
        method class-or-decl-type:sym<decltype>($/) {
            make $<decltype-specifier>.made
        }
    }

    our role Rules {

        proto rule class-or-decl-type { * }
        rule class-or-decl-type:sym<class>    { <nested-name-specifier>?  <class-name> }
        rule class-or-decl-type:sym<decltype> { <decltype-specifier> }
    }
}

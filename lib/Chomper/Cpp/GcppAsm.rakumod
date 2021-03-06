unit module Chomper::Cpp::GcppAsm;

use Data::Dump::Tree;

use Chomper::Cpp::GcppRoles;
use Chomper::Cpp::GcppStr;

# rule asm-definition { 
#   <asm> 
#   <.left-paren> 
#   <string-literal> 
#   <.right-paren> 
#   <.semi> 
# } #--------------------
class AsmDefinition is export { 
    has IComment      $.comment;
    has StringLiteral $.string-literal is required;

    has $.text;

    method name {
        'AsmDefinition'
    }

    method gist(:$treemark=False) {
        "asm(" ~ $.string-literal.gist(:$treemark) ~ ");"
    }
}

package AsmGrammar is export {

    our role Actions {

        # rule asm-definition { <asm> <.left-paren> <string-literal> <.right-paren> <.semi> } 
        method asm-definition($/) {
            make AsmDefinition.new(
                comment        => $<semi>.made,
                string-literal => $<string-literal>.made,
                text           => ~$/,
            )
        }
    }

    our role Rules {

        rule asm-definition {
            <asm>
            <left-paren>
            <string-literal>
            <right-paren>
            <semi>
        }
    }
}

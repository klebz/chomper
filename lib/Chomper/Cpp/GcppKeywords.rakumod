unit module Chomper::Cpp::GcppKeywords;

use Data::Dump::Tree;

use Chomper::Cpp::GcppRoles;

our role Keyword::Rules {
    token alignas          { 'alignas'          } 
    token alignof          { 'alignof'          } 
    token asm              { 'asm'              } 
    token auto             { 'auto'             } 
    token bool_            { 'bool'             } 
    token break_           { 'break'            } 
    token case             { 'case'             } 
    token catch            { 'catch'            } 
    token char_            { 'char'             } 
    token char16           { 'char16_t'         } 
    token char32           { 'char32_t'         } 
    token class_           { 'class'            } 
    token const            { 'const'            } 
    token constexpr        { 'constexpr'        } 
    token const_cast       { 'const_cast'       } 
    token continue_        { 'continue'         } 
    token decltype         { 'decltype'         } 
    token default_         { 'default'          } 
    token delete           { 'delete'           } 
    token do_              { 'do'               } 
    token double           { 'double'           } 
    token dynamic_cast     { 'dynamic_cast'     } 
    token else_            { 'else'             } 
    token enum_            { 'enum'             } 
    token explicit         { 'explicit'         } 
    token export           { 'export'           } 
    token extern           { 'extern'           } 
    token false_           { 'false'            } 
    token final            { 'final'            } 
    token float            { 'float'            } 
    token for_             { 'for'              } 
    token friend           { 'friend'           } 
    token goto_            { 'goto'             } 
    token if_              { 'if'               } 
    token inline           { 'inline'           } 
    token int_             { 'int'              } 
    token long_            { 'long'             } 
    token mutable          { 'mutable'          } 
    token namespace        { 'namespace'        } 
    token new_             { 'new'              } 
    token noexcept         { 'noexcept'         } 
    token nullptr          { 'nullptr'          } 
    token operator         { 'operator'         } 
    token override         { 'override'         } 
    token private          { 'private'          } 
    token protected        { 'protected'        } 
    token public           { 'public'           } 
    token register         { 'register'         } 
    token reinterpret_cast { 'reinterpret_cast' } 
    token return_          { 'return'           } 
    token short            { 'short'            } 
    token signed           { 'signed'           } 
    token sizeof           { 'sizeof'           } 
    token static           { 'static'           } 
    token static_assert    { 'static_assert'    } 
    token static_cast      { 'static_cast'      } 
    token struct           { 'struct'           } 
    token switch           { 'switch'           } 
    token template         { 'template'         } 
    token this             { 'this'             } 
    token thread_local     { 'thread_local'     } 
    token throw            { 'throw'            } 
    token true_            { 'true'             } 
    token try_             { 'try'              } 
    token typedef          { 'typedef'          } 
    token typeid_          { 'typeid'           } 
    token typename_        { 'typename'         } 
    token union            { 'union'            } 
    token unsigned         { 'unsigned'         } 
    token using            { 'using'            } 
    token virtual          { 'virtual'          } 
    token void_            { 'void'             } 
    token volatile         { 'volatile'         } 
    token wchar            { 'wchar_t'          } 
    token while_           { 'while'            } 
}
use Chomper::Cpp;
use Chomper::Rust;
use Chomper::ToRustIdent;
use Chomper::TranslateIo;
use Data::Dump::Tree;

proto sub to-rust-type($x) is export { * }

sub to-rust-generic-args($x where Cpp::TemplateArgumentList) {

    my @args = do for $x.template-arguments {
        to-rust-type($_)
    };

    Rust::GenericArgs.new(
        args => @args,
    )
}

multi sub to-rust-type($x where Cpp::SimpleTemplateId) {  

    my Rust::Identifier $template-name = to-rust-type($x.template-name);

    my $rust-generic-args = to-rust-generic-args($x.template-arguments);

    Rust::TypePath.new(
        type-path-segments => [
            Rust::TypePathSegment.new(
                path-ident-segment => $template-name,
                maybe-type-path-segment-suffix => Rust::TypePathSegmentSuffixGeneric.new(
                    generic-args => $rust-generic-args,
                ),
            )
        ]
    )
}

multi sub to-rust-type($x where Cpp::Identifier) {  

    my %typemap = %(
        "vector"        => "Vec",
        "int"           => "i32",
        "unsigned char" => "u8",
        "Tensor"        => "Tensor",
    );

    Rust::Identifier.new(
        value => %typemap{to-rust-ident($x).value}
    )
}

multi sub to-rust-type($x where Cpp::TypeSpecifier) {  
    to-rust-type($x.value)
}

multi sub to-rust-type(Array $x) {  

    my %typemap = %(
        "unsigned char" => "u8",
    );

    my $name = $x.List>>.gist.join(" ");

    Rust::Identifier.new(
        value => %typemap{$name}
    )
}

multi sub to-rust-type($x where Cpp::SimpleTypeSpecifier::Bool_) {  
    Rust::Identifier.new(
        value => "bool"
    )
}

multi sub to-rust-type($x where Cpp::TrailingTypeSpecifier::CvQualifier) {  

    #in rust, the CvQualifier is not part of the
    #type

    to-rust-type($x.simple-type-specifier)
}

multi sub to-rust-type($x where Cpp::FullTypeName) {  

    #should we drop the nested name specifier?
    #
    #i do here because i dont think using
    #namespaces is good

    to-rust-type($x.the-type-name)
}

multi sub to-rust-type($x) {  
    ddt $x;
    die "need to write method for type: " ~ $x.WHAT.^name;
}

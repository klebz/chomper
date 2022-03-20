# rule storage-class-specifier:sym<extern> { <.extern> }
our class StorageClassSpecifier::Extern does IStorageClassSpecifier { 

    has $.text;

    method gist{
        say "need write gist!";
        ddt self;
        exit;
    }
}

# rule storage-class-specifier:sym<mutable> { <.mutable> }
our class StorageClassSpecifier::Mutable does IStorageClassSpecifier { 

    has $.text;

    method gist{
        say "need write gist!";
        ddt self;
        exit;
    }
}

# rule storage-class-specifier:sym<register> { <.register> }
our class StorageClassSpecifier::Register does IStorageClassSpecifier { 

    has $.text;

    method gist{
        say "need write gist!";
        ddt self;
        exit;
    }
}

# rule storage-class-specifier:sym<static> { <.static> }
our class StorageClassSpecifier::Static does IStorageClassSpecifier { 

    has $.text;

    method gist{
        say "need write gist!";
        ddt self;
        exit;
    }
}

# rule storage-class-specifier:sym<thread_local> { <.thread_local> }
our class StorageClassSpecifier::Thread_local does IStorageClassSpecifier { 

    has $.text;

    method gist{
        say "need write gist!";
        ddt self;
        exit;
    }
}

our role StorageClass::Actions {

    # rule storage-class-specifier:sym<register> { <.register> }
    method storage-class-specifier:sym<register>($/) {
        make StorageClassSpecifier::Register.new
    }

    # rule storage-class-specifier:sym<static> { <.static> }
    method storage-class-specifier:sym<static>($/) {
        make StorageClassSpecifier::Static.new
    }

    # rule storage-class-specifier:sym<thread_local> { <.thread_local> }
    method storage-class-specifier:sym<thread_local>($/) {
        make StorageClassSpecifier::Thread_local.new
    }

    # rule storage-class-specifier:sym<extern> { <.extern> }
    method storage-class-specifier:sym<extern>($/) {
        make StorageClassSpecifier::Extern.new
    }

    # rule storage-class-specifier:sym<mutable> { <.mutable> } 
    method storage-class-specifier:sym<mutable>($/) {
        make StorageClassSpecifier::Mutable.new
    }
}

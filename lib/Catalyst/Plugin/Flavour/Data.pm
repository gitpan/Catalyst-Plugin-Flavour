package Catalyst::Plugin::Flavour::Data;
use strict;
use warnings;
use base qw/Class::Accessor::Fast/;

use overload (
    q{""} => sub { shift->flavour },
);

__PACKAGE__->mk_accessors(qw/fn flavour year month day/);

*yr = \&year;
*mo = \&month;
*da = \&day;

1;

package Catalyst::Plugin::Flavour;
use strict;
use base qw/Class::Accessor::Fast/;
use NEXT;

use Catalyst::Plugin::Flavour::Data;

our $VERSION = '0.029_01';

__PACKAGE__->mk_accessors(qw/flavour/);

# add accessors to Catalyst::Request
{
    package Catalyst::Request;
    use base qw/Class::Accessor::Fast/;

    __PACKAGE__->mk_accessors(qw/real_uri/);
    *rpath = \&real_path;
    *ruri  = \&real_uri;

    sub real_path { shift->real_uri->path };
}

=head1 NAME

Catalyst::Plugin::Flavour - Catalyst plugin for request flavours.

=head1 SYNOPSIS

    use Catalyst qw/Flavour/;
    
    __PACKAGE__->config(
        flavour => {
            flavours        => [qw/html rss json/],
            default_flavour => 'html',
        }
    );

=head1 DESCRIPTION

This plugin allows you to handle request flavours like Blosxom.

When top level path token in request match your flavour, that is stored in $c->flavour and deleted $c->path while $c->prepare_path.
So you can handle several flavours same controllers.

=head1 EXTENDED METHODS

=head2 prepare_path

=cut

sub prepare_path {
    my $c = shift;
    $c->NEXT::prepare_path(@_);

    $c->flavour( Catalyst::Plugin::Flavour::Data->new );
    $c->req->real_uri( $c->req->uri->clone );

    my @path = split m!/+!, $c->req->path;
    shift @path unless @path and  $path[0];

    my $config = $c->config->{flavour};

    if ($config->{flavours} or $config->{flavours_except}) {
        my $flavours = {
            map { $_ => 1 }
                @{ $config->{flavours} || $config->{flavours_except} || [] }
        };

        my $flavour = $path[0];
        if ($config->{flavours} && $flavours->{$flavour}
                or $config->{flavours_except} && !$flavours->{$flavour}) {
            shift @path;
            $c->flavour->flavour($flavour);
        }
        $c->flavour->flavour( $c->config->{flavour}->{default_flavour} || 'html' )
            unless $c->flavour;

    }
    elsif ( my ( $fn, $flavour ) = $path[-1] =~ /(.*)\.(.*?)$/ ) {

        $c->flavour->flavour($flavour);
        if ( $fn eq 'index' ) {
            pop @path;
        }
        else {
            $path[-1] =~ s/\.$flavour$//;
        }
    }

    unless ( defined $config->{date_flavour} and !$config->{date_flavour} ) {
        for my $param (qw/year month day/) {
            last unless $path[0];

            if (   $param eq 'year' && $path[0] =~ /^\d{4}$/
                or $path[0] =~ /^\d?\d$/ )
            {
                $c->flavour->$param( shift @path );
            }
            else {
                last;
            }
        }
    }

    my $path = '/' . join '/', @path;
    $c->req->uri->path( $path );
    $c->req->path( $path );

    $c;
}

=head1 SEE ALSO

L<Catalyst>

http://www.blosxom.com/

=head1 AUTHOR

Daisuke Murase E<lt>typester@cpan.orgE<gt>

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut

1;

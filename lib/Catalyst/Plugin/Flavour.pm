package Catalyst::Plugin::Flavour;
use strict;
use base qw/Class::Accessor::Fast/;
use NEXT;

our $VERSION = '0.02';

__PACKAGE__->mk_accessors(qw/flavour/);

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

    my $path = $c->req->uri->path;
    my ($flavour) = $path =~ m!^/([^/]*)!;

    my $flavours
        = { map { $_ => 1 } @{ $c->config->{flavour}->{flavours} || [] } };

    if ( $flavour and $flavours->{$flavour} ) {
        $path =~ s!^/$flavour/?!!;
        $c->req->uri->path("$path/");
        $c->req->path("$path/");

        $c->flavour($flavour);
    }
    $c->flavour( $c->config->{flavour}->{default_flavour} || 'html' )
        unless $c->flavour;

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

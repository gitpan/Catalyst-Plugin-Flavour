package Catalyst::Plugin::Flavour;
use strict;
use base qw/Class::Accessor::Fast/;
use NEXT;

our $VERSION = '0.01';

__PACKAGE__->mk_accessors(qw/flavour/);

=head1 NAME

Catalyst::Plugin::Flavour - Catalyst plugin for request flavours.

=head1 SYNOPSIS

    use Catalyst qw/Flavour/;
    
    __PACKAGE__->config(
        flavours        => [qw/html rss json/],
        default_flavour => 'html',
    );

=head1 DESCRIPTION

This plugin allows you to handle request flavours like Blosxom.

When top level path token in request match your flavour, that is stored in $c->flavour and deleted $c->path while $c->prepare_action.
So you can handle several flavours same controllers.

=head1 NOTICE

This plugin re-map $c->req->path in prepare_action chain, therefore there may be some plugin work incorrectly.

=head1 EXTENDED METHODS

=head2 prepare_action

=cut

sub prepare_action {
    my $c = shift;

    my $path_store = $c->req->path;
    my $swap       = 0;

    if ( my $path = $c->req->path ) {

        my ($flavour) = $path =~ m!^([^/]+)!;

        for ( @{ $c->config->{flavours} } ) {
            $swap++ if $flavour eq $_;
        }

        if ($swap) {
            $c->flavour($flavour);

            $path =~ s!^$flavour/+!!;
            $c->req->path($path);
        }
    }

    $c->NEXT::prepare_action(@_);

    $c->req->path($path_store) if $swap;
    $c->flavour( $c->config->{default_flavour} || 'html' ) unless $c->flavour;

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

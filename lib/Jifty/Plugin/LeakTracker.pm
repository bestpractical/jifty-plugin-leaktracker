package Jifty::Plugin::LeakTracker;
use strict;
use warnings;
use base 'Jifty::Plugin';

BEGIN {
    if (!$INC{"Devel/Events/Generator/Objects.pm"}) {
        Jifty->log->error("Devel::Events::Generator::Objects must be compiled very early so that it can override 'bless' in time. Usually this means you must run your Jifty application with: perl -MDevel::Events::Generator::Objects bin/jifty");
    }
}

use Devel::Events::Handler::ObjectTracker;
use Devel::Events::Generator::Objects;
use Devel::Size 'total_size';
use Template::Declare::Tags;

our $VERSION = 0.01;

sub inspect_before_request {
    my $self = shift;

    my $tracker = Devel::Events::Handler::ObjectTracker->new;
    my $generator = Devel::Events::Generator::Objects->new(handler => $tracker);
    $generator->enable;

    return [$tracker, $generator];
}

sub inspect_after_request {
    my $self = shift;
    my ($tracker, $generator) = @{ $_[0] };

    $generator->disable;

    my $leaked = $tracker->live_objects;
    my @leaks = keys %$leaked;

    # XXX: Devel::Size seems to segfault Jifty at END time
    my $size = total_size([ @leaks ]) - total_size([]);

    return {
        size  => $size,
        leaks => \@leaks,
    },
}

sub inspect_render_summary {
    my $self  = shift;
    my $leaks = shift;

    return "Leaked $leaks->{size} bytes";
}

sub inspect_render_analysis {
    my $self = shift;
    my $leaks = shift;

    ul {
        for (@{ $leaks->{leaks} }) {
            li { $_ }
        }
    }
}

1;

__END__

=head1 NAME

Jifty::Plugin::LeakTracker - Leak tracker plugin

=head1 DESCRIPTION

Memory leak detection and reporting for your Jifty app

=head1 USAGE

Add the following to your site_config.yml

 framework:
   Plugins:
     - LeakTracker: {}

=head1 SEE ALSO

L<Jifty::Plugin::Gladiator>

=head1 COPYRIGHT AND LICENSE

Copyright 2007-2009 Best Practical Solutions

This is free software and may be modified and distributed under the same terms as Perl itself.

=cut


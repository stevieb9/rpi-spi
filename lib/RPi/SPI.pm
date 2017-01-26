package RPi::SPI;

use strict;
use warnings;

use WiringPi::API qw(:wiringPi);

our $VERSION = '2.36.3';

sub new {
    my ($class, $channel, $speed) = @_;

    my $self = bless {}, $class;

    $self->_channel($channel);
    $self->_channel($speed);

    if (wiringPiSPISetup($self->_channel, $self->_speed) < 0){
        die "couldn't establish communication on the SPI bus\n";
    }

    return $self;
}
sub rw {
    my ($self, $buf, $len) = @_;
    my @read_buf = spiDataRW($self->_channel, $buf, $len);
    return @read_buf;
}
sub _channel {
    my ($self, $chan) = @_;
    $self->{channel} = $chan if defined $chan;
    return $self->{channel};
}
sub _speed {
    my ($self, $speed) = @_;
    $self->{speed} = $speed if defined $speed;
    return $self->{speed} || 1000000;
}

1;
__END__

=head1 NAME

RPi::SPI - Communicate with devices over the Serial Peripheral Interface (SPI)
bus on Raspberry Pi

=head1 SYNOPSIS

    my $channel = 0;

    my $spi = RPi::SPI->new($channel);

    my $buf = [0x01, 0x02];
    my $len = 2;

    my @read_buf = $spi->rw($buf, $len);

    # write occurs, then a read, and the read buffer overwrites the
    # write TX buffer, and we return an array of that data

    print "$_\n" for @read_buf;

    # read-only

    $buf = [0, 0, 0]; # three dummy bytes to signify a read of three bytes

    my @read_bytes = $spi->rw($buf, 2);

=head1 DESCRIPTION

This distribution provides you the ability to communicate with devices attached
to the channels on the Serial Peripheral Interface (SPI) bus. Although it was
designed for the Raspberry Pi, that's not a hard requirement, and it should work
on any Unix-type system that has support for SPI.

=head1 METHODS

=head2 new

Instantiates a new L<RPi::SPI> instance, prepares a specific SPI bus channel for
use, then returns the object.

Parameters:

    $channel

The SPI bus channel to initialize.

Mandatory: Integer, C<0> for C</dev/spidev0.0> or C<1> for C</dev/spidev0.1>.

    $speed

Optional, Integer. The data rate to communicate on the bus using. Defaults to
C<1000000> (1MHz).

Dies if we can't open the SPI bus.

=head2 rw

Writes specified data to the bus on the channel specified in C<new()>, then
after completion, does a read of the bus and re-populates the write buffer with
the freshly read data, and returns it as an array.

Parameters:

    $buf

Mandatory: Array reference where each element is an unsigned char (0-255). This
array is the write buffer; the data we'll be sending to the SPI bus.

    $len

Mandatory: Integer, the number of array elements in the C<$buf> parameter sent
in above.

Return: The write buffer, after being re-populated with the read data, as a Perl
array.

Dies if we can't open the SPI bus.

=head1 AUTHOR

Steve Bertrand, C<< <steveb at cpan.org> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2017 Steve Bertrand.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/> for more information.

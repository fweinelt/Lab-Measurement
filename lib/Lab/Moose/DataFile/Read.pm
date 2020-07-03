package Lab::Moose::DataFile::Read;

#ABSTRACT: Read a gnuplot-style 2D data file

use v5.20;

use warnings;
use strict;
use MooseX::Params::Validate 'validated_list';
use Moose::Util::TypeConstraints 'enum';
use List::Util qw//;
use PDL;

#use PDL::Core qw/pdl cat dog/;
use Fcntl 'SEEK_SET';
use Carp;
use Exporter 'import';
use Data::Dumper;

our @EXPORT = qw/read_gnuplot_format/;

=head1 SYNOPSIS

 use Lab::Moose::DataFile::Read;
 
 # Read gnuplot ASCII datafile and return each column as a 1D PDL
 my @columns = read_gnuplot_format(
     type => 'columns',
     file => 'data.dat',
     num_columns => 2,
 );

 # Read block structured 3D gnuplot ASCII datafile and return
 # 2D PDL for each parameter (column)
 my @pixel_maps = read_gnuplot_format(
     type => 'maps',
     file => '3d_data.dat',
     num_columns => 3,
 );

 # Read 3D gnuplot ASCII datafile and return 3D PDL with dimensions
 # [column, line, block]
 my $pdl = read_gnuplot_format(
    type => 'bare',
    file => '3d_data.dat',
    num_columns => 3,
 );
 
=head1 Functions

=head2 read_gnuplot_format

 Exported by default. Allowed parameters:

=over

=item * type

Either C<'columns'>,  C<'maps'>, or C<'bare'>.

=item * file

=item * fh

Provide an open file handle instead of a filename.

=item * num_columns (mandatory)

Number of columns in the datafile. Used for a consistency check.

=back

=cut

# produce 2D PDL for each block. Cat them into a 3d PDL
sub get_blocks {
    my ( $fh, $num_columns ) = validated_list(
        \@_,
        fh          => { isa => 'FileHandle', optional => 1 },
        num_columns => { isa => 'Int' },
    );

    my @blocks;
    my @rows;
    while ( my $line = <$fh> ) {
        if ( $line =~ /^#/ ) {
            next;
        }
        if ( $line =~ /^\s*$/ ) {

            # Finish block. Need check for number of rows if we have
            # multiple subsequent blank lines
            if ( @rows > 0 ) {

                # Give \@rows, not @rows to get a 2D piddle if we
                # only have a single row.
                push @blocks, pdl( \@rows );
                @rows = ();
            }
            next;
        }

        # awk splitting behaviour
        my @nums = split( ' ', $line );
        if ( @nums != $num_columns ) {
            die "num cols not $num_columns";
        }
        push @rows, [@nums];
    }
    if ( @rows > 0 ) {
        push @blocks, pdl( \@rows );
    }

    # bring blocks to same number of rows: reshape and add NaNs.
    my $max_rows = List::Util::max( map { ( $_->dims )[1] } @blocks );

    for my $block (@blocks) {
        my $rows = ( $block->dims() )[1];
        if ( $rows < $max_rows ) {
            $block->reshape( $num_columns, $max_rows );
            $block->slice(":,${rows}:-1") .= "NaN";
        }
    }

    return PDL::cat(@blocks);
}

sub read_gnuplot_format {
    my ( $type, $fh, $file, $num_columns ) = validated_list(
        \@_,
        type => { isa => enum( [qw/columns maps bare/] ) },
        fh          => { isa => 'FileHandle', optional => 1 },
        file        => { isa => 'Str',        optional => 1 },
        num_columns => { isa => 'Int' },
    );

    if ( !( $fh || $file ) ) {
        croak "read_2d_gnuplot_format needs either 'fh' or 'file' argument";
    }

    if ( !$fh ) {
        open $fh, '<', $file
            or croak "cannot open file $file: $!";
    }

    # Rewind filehandle.
    seek $fh, 0, SEEK_SET
        or croak "cannot seek: $!";

    my $blocks = get_blocks( fh => $fh, num_columns => $num_columns );

    # $blocks is 3D PDL with following dims
    # 0st dim: column
    # 1st dim: row (in block)
    # 2nd dim: block

    if ( $type eq 'bare' ) {
        return $blocks;
    }
    elsif ( $type eq 'columns' ) {

        # merge blocks
        my $result = $blocks->clump( 1, 2 );

        # switch row/column dimensions
        $result = $result->xchg( 0, 1 );

        # return one pdl for each column
        return dog($result);
    }
    elsif ( $type eq 'maps' ) {

        # 3D gnuplot data file (two x values, three y value):
        # x11 y11 z11
        # x12 y12 z12
        # x13 y13 z13
        #
        # x21 y21 z21
        # x22 y22 z22
        # x23 y23 z23
        #
        # x-cordinate changes with each block: x11, x12 and x13 will be equal
        # in most cases (exception: sweep of B-field or temperature where
        # they will be almost equal.
        #
        # Parse into three 2x3 piddles for x, y and z data
        # (first piddle dim (x) goes to the right):

        # x11 x21
        # x12 x22
        # x13 x23

        # y11 y21
        # y12 y22
        # y13 y23

        # and same for z
        my $result = $blocks->xchg( 0, 2 );
        return dog($result);
    }
}

1;

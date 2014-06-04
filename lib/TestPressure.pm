#!/usr/bin/env perl

use strict;
use warnings;

BEGIN {
    use FindBin;
    use lib "$FindBin::Bin/lib";
}

use Getopt::Long qw(:config no_auto_abbrev);
use List::Util qw(first);
use POSIX qw(setlocale LC_NUMERIC);
use Slic3r;
use Time::HiRes qw(gettimeofday tv_interval);
$|++;


use Slic3r::GCode::Reader;
use Slic3r::GCode::PressureManagement;
use Slic3r::Line;

open (IN,  'in.gcode');
open (OUT, '>out.gcode');

my $pressure_filter = Slic3r::GCode::PressureManagement->new(
    pressure => 100, 
    retract_speed => 60000, 
    unretract_speed => 3000);
print OUT $pressure_filter->process(join( "\n", <IN> ));

close IN;
close OUT;


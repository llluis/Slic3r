package Slic3r::GCode::PressureManagement;
use Moo;

has 'pressure'        => (is => 'ro', required => 1);
has 'retract_speed'   => (is => 'rw', required => 1);
has 'unretract_speed' => (is => 'rw', required => 1);
has 'relative'        => (is => 'rw');
has 'last_F'          => (is => 'rw', default => sub {0});
has 'amnt'            => (is => 'rw', default => sub {0}); #holds how much extra filament is currently loaded into the system
has 'reader'          => (is => 'rw', default => sub { Slic3r::GCode::Reader->new });

sub add_e {
    my ($line, $E, $comment) = @_;

    # replaces only the E argument, if present, with the specified value
    $line =~ s/\sE(\S*)\s/sprintf(" E%.5f ", $E)/ge;
    return $line . $comment . "\n";
}

sub process_layer {
    my $self = shift;
    my ($gcode) = @_;

    # aux variables to hold information during the loop
    my $new_gcode = "";
    my $adv = 0;

    # parse each line
    $self->reader->parse($gcode, sub {
        my ($reader, $cmd, $args, $info) = @_;

        # filter out odd commands
        if ($cmd =~ /^G[01]$/) {

            # speeds
            my $F = $args->{F} // $reader->F;
            my $v1 = $self->last_F/60;
            my $v2 = $F/60;

            # aux variables
            my $dist_E = $info->{"dist_E"};
            my $comm = "";
            my $retract_amnt = 0;

            # Check if we have an extruder movement only (retract/unretract)
            if ((exists $args->{E}) && (!(exists $args->{X} || exists $args->{Y} || exists $args->{Z}))) {
                if ($dist_E > 0) {
                    #unretract
                    $retract_amnt = $self->amnt;
                } else {
                    #retract
                    $retract_amnt = -$self->amnt;
                }
            } else {
                # verify speed change (excludes movements)
                if (($v1 != $v2) && (exists $args->{E})) {

                    # workaround bug #2033
                    if ($self->relative) {
                        $dist_E = $info->{"new_E"};
                    }

                    # E_per_mm
                    my $e = $dist_E / $info->{dist_XY};

                    # Advance algorithm
                    my $last_amnt = $self->amnt;
                    $self->amnt($e * $v2**2 * ($self->pressure/10000));
                    $adv = $self->amnt - $last_amnt; 
                    $comm = " + pressure advance";
                    $self->last_F($F);
                }
            }

            # insert the gcode line, summing up the advance amount
            $new_gcode .= add_e(
                $info->{raw}, 
                ($info->{"new_E"} // 0) + $adv + $retract_amnt,
                $info->{comment} ? $comm : "" );

            # only insert the first comment and the first line in case of relative distances
            $comm = "";
            if ($self->relative) {
                $adv = 0;
            }
        } else {
            # nothing to change, copy the raw line
            $new_gcode .= $info->{raw} . "\n";

            # when the absolute distance is reset, reset the advance amount to the added to the E argument
            if ($cmd =~ /^G92$/) {
                $adv = 0;
            }
        }
    });

    # we are done
    return $new_gcode;
}

1;

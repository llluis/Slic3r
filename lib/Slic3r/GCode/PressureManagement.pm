=pod
    # Pressure management post-processing filter
    my $pressure_filter = $self->gcodegen->extruder->pressure_multiplier == 99
        ? Slic3r::GCode::PressureManagement->new(extruder => $self->gcodegen->extruder, config => $self->print->config)
        : undef;
        
    # apply pressure management if enabled
    $gcode = $self->pressure_management->process_layer($gcode)
        if defined $self->pressure_management;
=cut

package Slic3r::GCode::PressureManagement;
use Moo;

extends 'Slic3r::GCode::Reader';
has 'config'        => (is => 'ro', required => 1);
has 'extruder'      => (is => 'ro', required => 1);
has 'last_F'        => (is => 'rw', default => sub {0} );
has 'last_amnt'     => (is => 'rw', default => sub {0} );
has 'amnt'          => (is => 'rw', default => sub {0} );

sub e_only {
    my ($self, $args) = @_;

    # Check if we have a extruder movement only (retract/unretract)
    if ((exists $args->{E}) && (!(exists $args->{X} || exists $args->{Y} || exists $args->{Z}))) {
        return 1;
    } else {
        return 0;
    }
}

sub process_layer {
    my $self = shift;
    my ($gcode) = @_;

    my $new_gcode = "";
    $self->parse($gcode, sub {
        my ($reader, $cmd, $args, $info) = @_;

        # Advance algorithm to compensate pressure during speed change
        if ($self->extruder->pressure_multiplier == 0) {
            my $F = $args->{F} // $reader->F; 
            my $v1 = $self->last_F/60;
            my $v2 = $F/60;

            # Verify change
            if (($v1 != $v2) && ($self->e_only($args) == 0) && exists $args->{E}) {

                my $e = 0;
                if ($self->config->use_relative_e_distances) {
                    $e = $info->{new_E} / $info->{dist_XY};
                } else {
                    $e = $info->{dist_E} / $info->{dist_XY};
                }

                # Advance algorithm
                $self->amnt($e * $v2**2 * 0.01); #($self->extruder->pressure_multiplier/10000)); #holds how much extra filament is currently loaded into the system
                my $adv = $self->amnt - $self->last_amnt;

                $new_gcode .= sprintf "G1 %s%.5f F%.3f",
                    $self->config->get_extrusion_axis,
                    $adv,
                    (($self->extruder->unretract_speed > 0) &&  ($adv > 0) ) ?
                        $self->extruder->unretract_speed_mm_min :
                        $self->extruder->retract_speed_mm_min;
                $new_gcode .= " ; pressure advance"
                    if $self->config->gcode_comments;
                $new_gcode .= "\n";

                $self->last_amnt($self->amnt);
                $self->last_F($F);
            }
        }

        $new_gcode .= $info->{raw} . "\n";
    });
    
    return $new_gcode;
}

1;

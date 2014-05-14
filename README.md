Fork from Slic3r stable branch (1.0.0RC3), including recent updates from alexrj.

Changes discussed in issue <a href='https://github.com/alexrj/Slic3r/issues/1677'>#1677</a>.

[![Build Status](https://travis-ci.org/llluis/Slic3r.png?branch=stable)](https://travis-ci.org/llluis/Slic3r)

<b>Features implemented:</b>
* Pressure control
   * The main goal is to create a pressure control mechanism for bowden setups, controlling the different pressure in the tube based on the extrusion speed. This way, the filament will be extruded or retracted a specified amount during speed changes to compensate the different pressure required, maintaining the correct extrusion flow.
   * Use the same logic as per Matt Roberts Advance Algorithm (the pressure is proportional to speed^2)
   * Triggered every speed change
   * A new extruder parameter let you define the advance constant (a value of 1 means 100%)
      * This parameter adjusts how much the algorithm will extrude or retract filament
   * When the advance occurs next to a unretraction (retraction compensation), the retraction value will be adjusted
* Speed dependant retraction (proportional) and minimum retraction length
   * You can define the speed at which the retraction length entered will be used. During retracts, a proportional retraction length will be used based on the current print speed
   * You can define a minimum retraction length which will be used every retraction
* Unretract speed (including dynamic speed)
   * Use a different unretraction speed from retraction (slower, for instance, to allow the melting in the hotend)
   * Setting the unretract speed to 1 will cause a dynamic unretract speed setting, using the extrusion speed of the subsequent segment. For instance, if after a retraction a segment will be extruded at 20mm/s, the unretract will be at 20mm/s also
   * Zero will disable the feature and the retract speed will be used
* Wait after unretract
   * Outputs a G4 dwell after unretract
* Changed acceleration gcode from Marlin M204 to Repetier-Firmware M201
* Bridge over infill threshold
   * Allows the user to disable the bridge over infill feature based on the infill being used. If the infill density is higher than the threshold, the feature will be disabled and no bridge settings will be used.
* Flow ratio control for perimeters and infill (experimental)
   * Let you specify different flow ratios for perimeters, solid infill and top solid infill
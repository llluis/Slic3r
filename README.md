Fork from Slic3r stable branch (1.0.0RC2)
Changes discussed in issue #1677.

Features implemented:
* Pressure control
   * I tried to use the same logic as per Matt Roberts Advance Algorithm
   * Triggered every speed change
   * A new extruder parameter let you define the advance constant
   * When the advance occurs next to a unretraction, the retraction value will be adjusted
* Speed dependant retraction (proportional) and minimum retraction length
   * You can define the speed at which the retraction length entered will be used. During retracts, a proportional retraction length will be used based on the current print speed
   * You can define a minimum retraction length which will be used every retraction
* Unretract speed
   * Use a different unretraction speed from retraction (slower, for instance, to allow the melting in the hotend)
* Wait after unretract
   * Outputs a G4 dwell after unretract
* Changed acceleration gcode from Marlin M204 to Repetier-Firmware M201
* Flow ratio control for perimeters and infill
   * Let you specify different flow ratios for perimeters, solid infill and top solid infill
Fork from Slic3r master branch (1.1.0), including recent updates from alexrj.

Changes discussed in issue <a href='https://github.com/alexrj/Slic3r/issues/1677'>#1677</a> and pull request <a href='https://github.com/alexrj/Slic3r/pull/2018'>208</a>.

[![Build Status](https://travis-ci.org/llluis/Slic3r.png?branch=master)](https://travis-ci.org/llluis/Slic3r)

<b>Features implemented:</b>
* Pressure control
   * The main goal is to create a pressure control mechanism for bowden setups, controlling the different pressure in the tube based on the extrusion speed. This way, the filament will be pushed or pulled a specified amount during speed changes to compensate the different pressure required, maintaining the correct extrusion flow.
   * Use the same logic as per Matt Roberts Advance Algorithm (the pressure is proportional to speed^2)
   * Triggered every speed change
   * A new extruder parameter let you define the advance constant
      * 0% disables the feature
	  * 100% will push or pull 100% of the amount calculated by the algorithm.
	  * Use this to adjust the extra amount of filament that the algorithm will insert in your gcode.
   * When the advance occurs next to a unretraction (retraction compensation), the retraction value will be adjusted
* Unretract speed
   * Use a different unretraction speed from retraction (slower, for instance, to allow the melting in the hotend)
   * Zero will disable the feature and the retract speed will be used

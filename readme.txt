Skill scripts for aligning and distibutioin objects in Allegro PCB Editor.
Apply for object: Group, Component, Pin, Via, Text
!!! This script replace standart Allegro feature: in Place Mode select objects, then Right click -> Align components

Features
+ horizontally and vertically aligning  (snap to Origin, Body, Pin1)
+ snap to grid
+ aligning by object boundary (Top, Bottom, Left, Right)
+ distibution between utmost left/right (top/bottom) object, auto calculating step
+ distibution with fixed step, from utmost left (bottom) object
+ distibution using object boundary, instead of distibution by object's origin.
+ skip fixed objects
+ align by user pick (by selecting object or point)
+ stretch CLine
- hotkey for each action
+ store script settings in design or separated file (dependent on "STORE_PLACE" variable in align.il)

Issues:
- havn't undo. How create undo?
+ realised oops functionality, but not undo.

Install and use:
- place form file to %formpath% (e.g. "." ".../share/local/pcb/forms" ".../share/pcb/text/forms")
- place bitmap files to %bmppath% (e.g. "." ".../share/local/pcb/icons" ".../share/pcb/text/icons")
- load script files (3 pieces *.il) to Editor.
  Print in allegro command line for each file: 
    skill load ".../align_*.il"
  For sripts autoload place loading commands in .../pcbenv/allegro.ilinit file:
    load( ".../align_*.il" )
- run the script from allegro command line: align, or from menu Edit->Align (Alt+e+a)
- select objects, on form press button with required action (form situated in Options panel)
For detailed information about working with sripts refer to "Allegro User Guide: SKILL Reference".
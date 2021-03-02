Skill scripts for aligning and distibutioin objects in Allegro PCB Editor.
Apply for object: Group, Component, Pin, Via, Text
!!! This script replace standart Allegro feature: "Place Mode, Select, Right click -> Align components"

Features
+ horizontally and vertically aligning  (snap to Origin, Body, Pin1)
+ snap to grid
+ aligning by object boundary (Top, Bottom, Left, Right)
+ distibution between utmost left/right (top/bottom) object, auto calculating step
+ distibution with fxed step, from utmost left object
+ distibution using object boundary, instead of distibution by object's origin.
+ fixed property control
- stretch CLine

Issues:
- havn't undo. How create undo?
+ realised oops functionality, but not undo.

Install and use:
- place form files to %formpath% ("." ".../share/local/pcb/forms" ".../share/pcb/text/forms")
- place bitmap files to %bmppath% ("." ".../share/local/pcb/icons" ".../share/pcb/text/icons")
- load script files (3 pieces *.il) to Editor
- run the script from allegro command line: align, or from menu Edit->Align (Alt+e+a)
- select objects, on form press button with required action (form situated in Options panel)
Author:
Evgeniy Kapustin, kap.e.v "atata" tut "dot" by
Copyright: Evgeniy Kapustin, 2011
$Revision: 62:89a17f0237c8 $

Purpose:
Cadence SKILL script for aligning and distibutioin objects in Allegro PCB Editor or Allegro Package Designer.
Apply for objects: Group, Component, Pin, Via, Text.
!!! This script replace standart Allegro feature: in Place Mode select objects, then Right click -> Align components

Features:
+ snap to Origin, Body Center
+ snap to any Pin
+ horizontally and vertically aligning
+ snap to grid
+ aligning by object boundary (Top, Bottom, Left, Right)
+ distibution between utmost left/right (top/bottom) object, auto calculating step
+ distibution with fixed step, from utmost left (bottom) object
+ distibution using object boundary, instead of distibution by object's origin.
+ skip fixed objects
+ align by user pick (by selecting object or point)
+ stretch CLine
+ hotkey for each action
+ store script settings

Tested:
Windows XP SP3, APE 16.3-16.5, APD 16.3-16.5

Issues:
- havn't undo. How create undo?
+ realised oops functionality, but not undo.

Installation and usage:
- place form file to %formpath% (e.g. "." ".../share/local/pcb/forms" ".../share/pcb/text/forms")
- place bitmap files to %bmppath% (e.g. "." ".../share/local/pcb/icons" ".../share/pcb/text/icons")
- load script files (3 pieces *.il) to Editor.
  Print in allegro command line for each file: 
    skill load ".../align*.il"
  For sripts autoload place loading commands in .../pcbenv/allegro.ilinit file:
    load( ".../align*.il" )
- run the script from allegro command line: align, or from menu Edit->Align (Alt+e+a)
- select objects, on form press button with required action (form situated in Options panel)
For detailed information about working with sripts refer to "Allegro User Guide: SKILL Reference".

DISCLAIMER:
No any warranties. This program is free software and is available AS-IS.
There is no formal support.

Modification and Distribution:
You may redistribute and/or modify this software. In this case every improvement and enhancement should be submitted to the author.
This software can not be commercialized without the written consent of the author.
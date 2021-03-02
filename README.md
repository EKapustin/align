Skill scripts for aligning and distibutioin objects in Allegro PCB Editor.
Apply for object: Group, Component, Pin, Via, Text

Features
+ horizontally and vertically aligning  (snap to Origin, Body, Pin1)
+ snap to grid
+ aligning by object boundary (Top, Bottom, Left, Right)
+ distibution between utmost left/right (top/bottom) object, auto calculating step
+ distibution with fxed step, from utmost left object
- distibution using object boundary, instead of distibution by object's origin.

Issues:
- fix snap to grid. How get grid values?
- main programm cycle always wait for object select (axlSelect() function), this provide some problem, how redesign this?
- havn't undo. How easily create undo?
- if we running sript, then choose some standart tool, sript don't finish. If we exit from script
  we have already selected standart tool... Bad behaviour. How fix it?

Install and use:
- place form and picture files to %formpath%
- load script files (3 pieces *.il) to Editor
- run the script from allegro command line: align, or from menu Edit->Align (Alt+e+a)
- select objects, on form press button with required action (form situated in Options panel)
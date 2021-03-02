Author: Evgeniy Kapustin, kap.e.v "atata" tut "dot" by
Copyright: Evgeniy Kapustin, 2012
Project home: https://bitbucket.org/Kapustin/align
$Revision: 88:fba8ebcec9d7 $

Purpose:
Cadence SKILL script for aligning and distibution objects in Allegro PCB Editor or Allegro Package Designer.
Apply for objects: Group, Component, Pin, Via, Text.

Features:
+ snap to Origin, Body Center
+ snap to any Pin
+ horizontally and vertically aligning
+ snap to grid (only for v15.7+)
+ aligning by object boundary (Top, Bottom, Left, Right)
+ distibution between utmost left/right (top/bottom) object, auto calculating step
+ distibution with fixed step, from utmost left (bottom) object
+ distibution using object boundary, instead of distibution by object's origin.
+ skip fixed objects
+ align by user pick (by selecting object or point)
+ stretch CLine
+ hotkey for each action (only for v16.3+)
  w, a, s, d - Top, Left, Bottom, Right
  q, z - CenterH, CenterV
  e, c - DistributeH, DistributeV
  r, v - PickH, PickV
+ store script settings
+ store filter 

Tested:
- Windows XP SP3, APE 16.3-16.5, APD 16.3-16.5
- Windows 7 SP1 x64, APE 16.5-16.6, APD 16.5-16.6
- APE 15.x-16.2 - without "Align" menu item.

Issues:
- havn't undo. How create undo?
+ realised oops functionality, but not undo.

Installation and usage:
- launch install.bat, all files will be copied to appropriate folders, and registered for autoloading.
- run the script from allegro command line: aln, or from menu Edit->Align (Alt+e+a)
- select objects, on form press button with required action (form situated in Options panel)

DISCLAIMER:
No any warranties. This program is free software and is available AS-IS.
There is no formal support.

Modification and Distribution:
You may redistribute and/or modify this software. In this case every improvement and enhancement should be submitted to the author.
This software can not be commercialized without the written consent of the author.
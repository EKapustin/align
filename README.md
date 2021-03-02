Author: Evgeniy Kapustin, e "atata" kapustin "dot" by
Copyright: Evgeniy Kapustin, 2012
Project home: https://github.com/EKapustin/align

# Align

Cadence SKILL script for aligning and distributing objects in Allegro PCB Editor or Allegro Package Designer.
Can be used for the following objects: Group, Component, Pin, Via, Text.

## Features:
+ snap to Origin, Body Center
+ snap to any Pin
+ horizontally and vertically aligning
+ snap to grid (only for v15.7+)
+ aligning by object boundary (Top, Bottom, Left, Right)
+ distributing between utmost left/right (top/bottom) object, auto calculating step
+ distributing with fixed step, from utmost left (bottom) object
+ distributing using object boundary, instead of distibution by object's origin.
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

## Tested:
- Windows XP SP3, APE 16.3-16.5, APD 16.3-16.5
- Windows 7 SP1 x64, APE 16.5-16.6, APD 16.5-16.6
- APE 15.x-16.2 - without "Align" menu item.

## Issues:
- havn't undo. How create undo?
+ realised oops functionality, but not undo.

## Installation and usage:
- launch install.bat, all files will be copied to appropriate folders, and registered for autoloading.
- run the script from allegro command line: aln, or from menu Edit->Align (Alt+e+a)
- select objects, on form press button with required action (form situated in Options panel)

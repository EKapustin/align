Author: Evgeniy Kapustin, e "atata" kapustin "dot" by   
Copyright: Evgeniy Kapustin, 2012   
Project home: https://github.com/EKapustin/align  

# Align

: Cadence SKILL script for aligning and distributing objects in Allegro PCB Editor or Allegro Package Designer.
Can be used for the following objects: Group, Component, Pin, Via, Text.

## Features:
- [x] snap to Origin, Body Center
- [x] snap to any Pin
- [x] horizontally and vertically aligning
- [x] snap to grid (only for v15.7+)
- [x] aligning by object boundary (Top, Bottom, Left, Right)
- [x] distributing between utmost left/right (top/bottom) object, auto calculating step
- [x] distributing with fixed step, from utmost left (bottom) object
- [x] distributing using object boundary, instead of distibution by object's origin.
- [x] skip fixed objects
- [x] align by user pick (by selecting object or point)
- [x] stretch CLine
- [x] hotkey for each action (only for v16.3+)
 - w, a, s, d - Top, Left, Bottom, Right
 - q, z - CenterH, CenterV
 - e, c - DistributeH, DistributeV
 - r, v - PickH, PickV
- [x] store script settings
- [x] store filter 

## Tested:
- [x] Windows XP SP3, APE 16.3-16.5, APD 16.3-16.5
- [x] Windows 7 SP1 x64, APE 16.5-16.6, APD 16.5-16.6
- [x] APE 15.x-16.2 - without "Align" menu item.

## Issues:
- [ ] havn't undo. How create undo?
- [x] implemented oops functionality, but not undo.

## Installation and usage:
- launch install.bat, all files will be copied to appropriate folders, and registered for autoloading.
- run the script from allegro command line: aln, or from menu Edit->Align (Alt+e+a)
- select objects, on form press button with required action (form situated in Options panel)

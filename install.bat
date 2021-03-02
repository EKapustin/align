@echo off
echo Align Tool installation (thanks to deargds)
echo -------------------------------------------
echo Copy .bmp files to %CDSROOT%\share\local\pcb\icons\ folder:
xcopy %cd%\*.bmp "%CDSROOT%\share\local\pcb\icons\" /y/q
echo -------------------------------------------
echo Copy .il files to %CDSROOT%\share\local\pcb\skill\ folder:
xcopy %cd%\*.il "%CDSROOT%\share\local\pcb\skill\" /y/q
echo -------------------------------------------
echo Copy .form files to %CDSROOT%\share\local\pcb\forms\ folder:
xcopy %cd%\*.form "%CDSROOT%\share\local\pcb\forms\" /y/q
echo -------------------------------------------
echo Register scripts in allegro.ilinit
for /f "tokens=1* delims=" %%a in ('findstr /lic:"align.il" "%CDSROOT%\share\local\pcb\skill\allegro.ilinit"') do call:skip_file1
echo Register align.il...
echo loadi("align.il")>>%CDSROOT%\share\local\pcb\skill\allegro.ilinit
:skip_file1
echo align.il registered.
for /f "tokens=1* delims=" %%a in ('findstr /lic:"align_do.il" "%CDSROOT%\share\local\pcb\skill\allegro.ilinit"') do call:skip_file2
echo Register align_do.il...
echo loadi("align_do.il")>>%CDSROOT%\share\local\pcb\skill\allegro.ilinit
:skip_file2
echo align_do.il registered.
for /f "tokens=1* delims=" %%a in ('findstr /lic:"align_utils.il" "%CDSROOT%\share\local\pcb\skill\allegro.ilinit"') do call:skip_file3
echo Register align_utils.il...
echo loadi("align_utils.il")>>%CDSROOT%\share\local\pcb\skill\allegro.ilinit
:skip_file3
echo align_utils.il registered.
echo -------------------------------------------
echo Installation completed, using command 'aln' to launch script in Allegro.
echo -------------------------------------------
pause
exit 0
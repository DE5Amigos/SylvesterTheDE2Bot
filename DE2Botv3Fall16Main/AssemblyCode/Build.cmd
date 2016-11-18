:: Build.cmd
::
:: A basic build script for the DE5Amigos Assembly program.
:: 
:: This program concatenates all of the assembly files into one
:: large assembly file that can then be run through the compiler to
:: check for correctness.
::
:: Harrison Statham
::

cls

@ECHO OFF

set InitDir=Include\Init
set StaticDir=Include\Static
set SubRoutines=Include\SubRoutines

set Init0=Include\ProgramHeader.asm
set Init1=%InitDir%\InterruptTable.asm
set Init2=%InitDir%\Initialization.asm
set Init3=%InitDir%\WaitForSafety.asm
set Init4=%InitDir%\WaitForUser.asm

set SR0=%SubRoutines%\Abs.asm
set SR1=%SubRoutines%\Atan2.asm
set SR2=%SubRoutines%\BattCheck.asm
set SR3=%SubRoutines%\CTimer_ISR.asm
set SR4=%SubRoutines%\Div16s.asm
set SR5=%SubRoutines%\I2C.asm
set SR6=%SubRoutines%\L2Estimate.asm
set SR7=%SubRoutines%\Mod360.asm
set SR8=%SubRoutines%\Mult16s.asm 
set SR9=%SubRoutines%\Wait1.asm

set Static0=%StaticDir%\Constants.asm
set Static1=%StaticDir%\MemoryAddresses.asm
set Static2=%StaticDir%\Variables.asmd


::
:: Build temporary files. 
::

copy Init0+Init1+Init2+Init3+Init4 InitTemp.asm
copy SR0+SR1+SR2+SR3+SR4+SR5+SR6+SR7+SR8+SR9 SubRoutineTemp.asm
copy Static0+Static1+Static2 StaticTemp.asm


::
:: Build the final assembly program.
::
copy InitTemp.asm+SubRoutineTemp.asm+StaticTemp.asm DE5Amigos.asm


::
:: Clean up
::
del /f InitTemp.asm SubRoutineTemp.asm StaticTemp.asm




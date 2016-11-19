:: Build2.cmd
::
:: A basic build script for the DE5Amigos Assembly program.
:: 
:: This program just calls the python program that does the
:: the concatenation of all of the assembly files.
:: 
:: There is no difference between the python build script
:: and Build.cmd. The python file is just simpler to write
:: and maintain.
::
:: Harrison Statham
::


CLS
@ECHO OFF

::  
:: Clean up some files before we try and build.
:: Sometimes python wont output the correct file
:: if we dont intentionally delete the output 
:: assembly file.
::
:: The mif file clean up is just for completeness.
:: 

echo.
echo  =======================================================
echo  Welcome to the DE5Amigos Build Script...
echo.
echo  Harrison Statham
echo  =======================================================
echo.

echo  Starting clean up...


if exist "DE5Amigos.asm" (
    
    echo  Cleaning up DE5Amigos.asm
	del /f "DE5Amigos.asm"
)

if exist "DE5Amigos.mif" (
    
    echo  Cleaning up DE5Amigos.mif
	del /f "DE5Amigos.mif"
)

if exist "FinalProgram.asm" (
    
    echo Cleaning up FinalProgram.asm
	del /f "FinalProgram.asm"
)

if exist "FinalProgram.mif" (
    
    echo Cleaning up FinalProgram.mif
	del /f "FinalProgram.mif"
)


::
:: Build the final output assembly file.
::

echo  Concatenating Assembly Files...

python Build.py "Build"


::
:: Compile the final assembly file.
::

set currentDir=C:\Users\HarrisonStatham\Documents\GitHub\SylvesterTheDE2Bot\DE2Botv3Fall16Main\AssemblyCode
set compileDir="C:\Program Files (x86)\Emerald Editor Community\Crimson Editor SVN286\SCASM"

cd %compileDir%
echo  Compiling With SCASM...
SCASM.exe %currentDir%\DE5Amigos.asm

cd %currentDir%

if exist "DE5Amigos.err" (
    
    echo  Errors Found...
    echo.
	python Build.py "Error"

)

echo  Compilation Successfull...
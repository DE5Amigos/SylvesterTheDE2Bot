
CLS
@ECHO OFF

SET INIT_DIR=Include\Init
SET STATIC_DIR=Include\Static

SET ROUTINE=Include\SubRoutines

del /f FinalProgram.asm

SET InitFiles=(1 2 3 4)

@ECHO ON


FOR /l %A IN %InitFiles% DO (
	echo %A
)
@ECHO OFF

copy 	Include\ProgramHeader.asm + %INIT_DIR%\InterruptTable.asm "TempProg1.asm"
copy 	%INIT_DIR%\Initialization.asm + %INIT_DIR%\WaitForSafety.asm + %INIT_DIR%\WaitForUser.asm "TempProg2.asm"
copy 	TempProg1.asm + TempProg2.asm "TempProg3.asm"

copy 	%ROUTINE%\Abs.asm + %ROUTINE%\Atan2.asm + %ROUTINE%\BattCheck.asm + %ROUTINE%\Div16s.asm "SubRoutineTemp1.asm"
copy 	%ROUTINE%\I2C.asm + %ROUTINE%\L2Estimate.asm + %ROUTINE%\Mod360.asm "SubRoutineTemp2.asm"
copy 	%ROUTINE%\Mult16s.asm + %ROUTINE%\Wait1.asm "SubRoutineTemp3.asm
copy 	"SubRoutineTemp1.asm" + "SubRoutineTemp2.asm" + "SubRoutineTemp3.asm" "SubRoutineTemp.asm"

copy 	TempProg3.asm + Main.asm + SubRoutineTemp.asm + %STATIC_DIR%\Constants.asm + %STATIC_DIR%\MemoryAddresses.asm  FinalProgram.asm

del /f TempProg1.asm TempProg2.asm TempProg3.asm SubRoutineTemp1.asm SubRoutineTemp2.asm SubRoutineTemp3.asm SubRoutineTemp.asm
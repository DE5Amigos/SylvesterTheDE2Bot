#
# Build File
#
#

import sys

inputFiles = [
	
	
	'Include\ProgramHeader.asm',
	'Include\Init\InterruptTable.asm',
	'Include\Init\Initialization.asm',
	'Include\Init\WaitForSafety.asm',
	'Include\Init\WaitForUser.asm',

	'Main.asm',
	'Include\SubRoutines\Die.asm',

	'Include\SubRoutines\Abs.asm',
	'Include\SubRoutines\Atan2.asm',
	'Include\SubRoutines\BattCheck.asm',
	'Include\SubRoutines\CTimer_ISR.asm',
	'Include\SubRoutines\Div16s.asm',
	'Include\SubRoutines\I2C.asm',
	'Include\SubRoutines\L2Estimate.asm',
	'Include\SubRoutines\Mod360.asm',
	'Include\SubRoutines\Mult16s.asm',
	'Include\SubRoutines\ReturnHome.asm',
	'Include\SubRoutines\Turn45.asm',
	'Include\SubRoutines\Wait1.asm',

	'Include\Static\Variables.asm',
	'Include\Static\Constants.asm',
	'Include\Static\MemoryAddresses.asm'
]


outputFile = 'DE5Amigos.asm'


def main():
		
	inArg = sys.argv[1]

	if(inArg == 'Build'):

		with open(outputFile, 'a') as outFile:

			for f in inputFiles:

				inFile 	= open(f, 'r')
				data 	= inFile.read()

				outFile.write(data)

				inFile.close()

	if(inArg == 'Error'):

		with open('DE5Amigos.err') as errorFile:

			print(errorFile.read())

	if(inArg == 'Clean'):
		pass
		


	






if __name__ == '__main__':
	main()

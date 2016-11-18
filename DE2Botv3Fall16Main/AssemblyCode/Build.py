#
# Build File
#
#

inputFiles = [
	
	
	'Include\ProgramHeader.asm',
	'Include\Init\InterruptTable.asm',
	'Include\Init\Initialization.asm',
	'Include\Init\WaitForSafety.asm',
	'Include\Init\WaitForUser.asm',

	'Main.asm',

	'Include\SubRoutines\Abs.asm',
	'Include\SubRoutines\Atan2.asm',
	'Include\SubRoutines\BattCheck.asm',
	'Include\SubRoutines\CTimer_ISR.asm',
	'Include\SubRoutines\Div16s.asm',
	'Include\SubRoutines\I2C.asm',
	'Include\SubRoutines\L2Estimate.asm',
	'Include\SubRoutines\Mod360.asm',
	'Include\SubRoutines\Mult16s.asm',
	'Include\SubRoutines\Wait1.asm',

	'Include\Static\Variables.asm',
	'Include\Static\Constants.asm',
	'Include\Static\MemoryAddresses.asm'
]


outputFile = 'DE5Amigos.asm'


def main():
	
	with open(outputFile, 'a') as outFile:

		for f in inputFiles:

			inFile 	= open(f, 'r')
			data 	= inFile.read()

			outFile.write(data)

			inFile.close()


	






if __name__ == '__main__':
	main()

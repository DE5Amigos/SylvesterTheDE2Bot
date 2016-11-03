--
-- RegisterFile
-- 
--
-- A register file implementation in VHDL.
-- 
-- Since we have a 10-bit operand to work with, we can implement 32 registers.
--
-- Harrison Statham
--
--

library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity RegisterFile is

	port (

		clock 		: in 	std_logic;
		resetn 		: in 	std_logic;

		-- Read/Write Signals.
		readWrite 	: in 	std_logic;

		-- Read/Write addresses.
		readAddrA	: in 	std_logic_vector(3 downto 0);
		readAddrB	: in 	std_logic_vector(3 downto 0);
		writeAddr 	: in 	std_logic_vector(3 downto 0);

		-- In register is the data that we want to write to some given register.
		inReg 		: in 	std_logic_vector(16 downto 0);
		
		-- Get two registers' contents.
		outRegA 	: out 	std_logic_vector(16 downto 0);
		outRegB 	: out 	std_logic_vector(16 downto 0)

	);

end RegisterFile;


architecture arch of RegisterFile is
begin
	
	-- 
	-- Register File
	-- 
	-- An array that holds the contents of the registers.
	--

	type register_file is array(0 to 31) of std_logic_vector(15 downto 0);


	-- 
	-- Process
	-- 
	-- A state machine for the register file. This controls the flow of data in and out of the
	-- register file.
	--

	process (clock, resetn)
	begin

		-- If we are in a reset state, then we want to clear all of the register contents.
		if (resetn = '0') then

			-- Set all of the registers in the register file to 0.
			register_file(0 to 31) <= x"0000";


		-- On the rising edge of the clock, we want to write the data into, and read the data
		-- from the register file, and "return" it to the "caller" for use.
		elsif (RISING_EDGE(clock)) then

			-- loop through 0 to 31 in binary, and compare the values to the 
			-- value stored in readAddr and writeAddr.


			if (readWrite = '0') then

				-- if we are in read mode, then we want to read the register value at
				-- readAddr.

				-- Turn the binary address of the read addr into decimal to write into the array.
				variable indexDec1;
				variable indexDec2;

				outRegA(15 downto 0) <= register_file(indexDec1) (15 downto 0);
				outRegB(15 downto 0) <= register_file(indexDec2) (15 downto 0);

			else

				-- If we are in write mode, then we want to take the data in the "inReg"
				-- and put the data into the destination register.
				variable indexDecWrite;
				
				register_file(indexDecWrite) (15 downto 0) <= inReg(15 downto 0);

			end if;
			

		end if;

	end process;
	

end architecture arch;





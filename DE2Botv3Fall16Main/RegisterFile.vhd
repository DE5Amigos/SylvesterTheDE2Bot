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
use ieee.numeric_std.all;

entity RegisterFile is

	port (

		clock 		: in 	std_logic;
		resetn 		: in 	std_logic;

		-- Read/Write Signals.
		writeEnable : in 	std_logic;

		-- Read/Write addresses.
		readAddrA	: in 	std_logic_vector(3 downto 0);
		readAddrB	: in 	std_logic_vector(3 downto 0);
		writeAddr 	: in 	std_logic_vector(3 downto 0);

		-- In register is the data that we want to write to some given register.
		inReg 		: in 	std_logic_vector(15 downto 0);
		
		-- Get two registers' contents.
		outRegA 	: out 	std_logic_vector(15 downto 0);
		outRegB 	: out 	std_logic_vector(15 downto 0)

	);

end RegisterFile;


architecture arch of RegisterFile is
begin
	
	-- 
	-- Register File
	-- 
	-- An array that holds the contents of the registers.
	--

	-- Note: We want "... array(1 to 31) ... " because our 0-th register is the AC which is local
	-- to SCOMP.

	type register_file is array(1 to 31) of std_logic_vector(15 downto 0);

	signal registers : register_file;


	process (clock, resetn)
	begin

		-- If we are in a reset state, then we want to clear all of the register contents.
		if (resetn = '0') then

			-- Set all of the registers in the register file to 0.


		-- On the rising edge of the clock, we want to write the data into, and read the data
		-- from the register file, and "return" it to the "caller" for use.
		elsif (RISING_EDGE(clock)) then

			--
			-- Note: I didn't know how to implement the "to_integer(unsigned(...))" portion.
			-- I found this link on SO.
			--
			-- See: http://stackoverflow.com/questions/19942067/writing-a-register-file-in-vhdl
			-- 
			outRegA <= registers(to_integer(unsigned(readAddrA)));
			outRegB <= registers(to_integer(unsigned(readAddrB)));

			if (writeSignal = '1') then

				registers(to_integer(unsigned(writeAddr))) <= inReg;

			end if;

		end if;
	end process;

end architecture arch;





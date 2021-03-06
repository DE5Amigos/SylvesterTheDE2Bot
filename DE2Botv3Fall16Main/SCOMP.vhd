LIBRARY IEEE;
LIBRARY ALTERA_MF;
LIBRARY LPM;

USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE ALTERA_MF.ALTERA_MF_COMPONENTS.ALL;
USE LPM.LPM_COMPONENTS.ALL;

use ieee.numeric_std.all;


ENTITY SCOMP IS
  PORT(
    CLOCK    : IN    STD_LOGIC;
	RESETN   : IN    STD_LOGIC;
	PCINT    : IN    STD_LOGIC_VECTOR( 3 DOWNTO 0);
	IO_WRITE : OUT   STD_LOGIC;
	IO_CYCLE : OUT   STD_LOGIC;
	IO_ADDR  : OUT   STD_LOGIC_VECTOR( 7 DOWNTO 0);
	IO_DATA  : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0)
  );
END SCOMP;


ARCHITECTURE a OF SCOMP IS
  
	TYPE STATE_TYPE IS (

		RESET_PC,
		FETCH,
		DECODE,
		EX_LOAD,
		EX_STORE,
		EX_STORE2,
		EX_ADD,
		EX_SUB,
		EX_JUMP,
		EX_JNEG,
		EX_JPOS,
		EX_JZERO,
		EX_AND,
		EX_OR,
		EX_XOR,
		EX_SHIFT,
		EX_ADDI,
		EX_ILOAD,
		EX_ISTORE,
		EX_CALL,
		EX_RETURN,
		EX_IN,
		EX_OUT,
		EX_OUT2,
		EX_LOADI,
		EX_RETI,
		
		EX_MOVR,
		EX_ADDR,
		EX_SUBR,

		EX_ANDR,
		EX_ORR,

		EX_CMP,
		EX_STORER,
		EX_STORER2,

		EX_LOADR,
		EX_LOADR2
	);
	
	
	TYPE STACK_TYPE IS ARRAY (0 TO 9) OF STD_LOGIC_VECTOR(10 DOWNTO 0);
	
	type HSREGISTER_FILE is array (0 to 31) of std_logic_vector(15 downto 0);
	
	
	
	SIGNAL regFile 		: HSREGISTER_FILE;
	
	SIGNAL STATE        : STATE_TYPE;
	SIGNAL PC_STACK     : STACK_TYPE;
	SIGNAL IO_IN        : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL AC           : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL AC_SAVED     : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL AC_SHIFTED   : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL IR           : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL MDR          : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL PC           : STD_LOGIC_VECTOR(10 DOWNTO 0);
	SIGNAL PC_SAVED     : STD_LOGIC_VECTOR(10 DOWNTO 0);
	SIGNAL MEM_ADDR     : STD_LOGIC_VECTOR(10 DOWNTO 0);
	SIGNAL MW           : STD_LOGIC;
	SIGNAL IO_WRITE_INT : STD_LOGIC;
	SIGNAL GIE          : STD_LOGIC;
	SIGNAL IIE      	: STD_LOGIC_VECTOR( 3 DOWNTO 0);
	SIGNAL INT_REQ      : STD_LOGIC_VECTOR( 3 DOWNTO 0);
	SIGNAL INT_REQ_SYNC : STD_LOGIC_VECTOR( 3 DOWNTO 0); -- registered version of INT_REQ
	SIGNAL INT_ACK      : STD_LOGIC_VECTOR( 3 DOWNTO 0);
	SIGNAL IN_HOLD      : STD_LOGIC;
	
	
	
	


  BEGIN
  
    -- Use altsyncram component for unified program and data memory
	MEMORY : altsyncram
	GENERIC MAP (
		intended_device_family => "Cyclone",
		width_a          => 16,
		widthad_a        => 11,
		numwords_a       => 2048,
		operation_mode   => "SINGLE_PORT",
		outdata_reg_a    => "UNREGISTERED",
		indata_aclr_a    => "NONE",
		wrcontrol_aclr_a => "NONE",
		address_aclr_a   => "NONE",
		outdata_aclr_a   => "NONE",
		init_file        => "misctest.mif",
		lpm_hint         => "ENABLE_RUNTIME_MOD=NO",
		lpm_type         => "altsyncram"
	)
	PORT MAP (
		wren_a    => MW,
		clock0    => NOT(CLOCK),
		address_a => MEM_ADDR,
		data_a    => AC,
		q_a       => MDR
	);
	
	
	-- Use LPM function to shift AC using the SHIFT instruction
	SHIFTER: LPM_CLSHIFT
	GENERIC MAP (
		lpm_width     => 16,
		lpm_widthdist => 4,
		lpm_shifttype => "ARITHMETIC"
	)
	PORT MAP (
		data      => AC,
		distance  => IR(3 DOWNTO 0),
		direction => IR(4),
		result    => AC_SHIFTED
	);
	
	
	-- Use LPM function to drive I/O bus
	IO_BUS: LPM_BUSTRI
	GENERIC MAP (
		lpm_width => 16
	)
	PORT MAP (
		data     => AC,
		enabledt => IO_WRITE_INT,
		tridata  => IO_DATA
	);
	
	
	
    IO_ADDR  <= IR(7 DOWNTO 0);
	
	
	WITH STATE SELECT MEM_ADDR <=
		PC WHEN FETCH,
		IR(10 DOWNTO 0) WHEN OTHERS;
	
	
	WITH STATE SELECT IO_CYCLE <=
		'1' WHEN EX_IN,
		'1' WHEN EX_OUT2,
		'0' WHEN OTHERS;

	IO_WRITE <= IO_WRITE_INT;


    PROCESS (CLOCK, RESETN)
      
      
      variable regFileDest 		: integer range 0 to 31;
      variable regFileSource 	: integer range 0 to 31;
      
      BEGIN
        
        IF (RESETN = '0') THEN          -- Active low, asynchronous reset
			
			STATE <= RESET_PC;
			
		ELSIF (RISING_EDGE(CLOCK)) THEN
		
			CASE STATE IS
			
				WHEN RESET_PC =>
					MW        		<= '0';          -- Clear memory write flag
					PC        		<= "00000000000"; -- Reset PC to the beginning of memory, address 0x000
					AC        		<= x"0000";      -- Clear AC register
					IO_WRITE_INT 	<= '0';
					GIE       		<= '1';          -- Enable interrupts
					IIE       		<= "0000";       -- Mask all interrupts
					STATE     		<= FETCH;
					IN_HOLD   		<= '0';
					INT_REQ_SYNC 	<= "0000";

				WHEN FETCH =>
				
					MW    			<= '0';       -- Clear memory write flag
					IR    			<= MDR;       -- Latch instruction into the IR
					IO_WRITE_INT 	<= '0';       -- Lower IO_WRITE after an OUT
					
					
					
					
					
					
					-- Interrupt Control
					IF (GIE = '1') AND  -- If Global Interrupt Enable set and...
					  (INT_REQ_SYNC /= "0000") THEN -- ...an interrupt is pending
						IF INT_REQ_SYNC(0) = '1' THEN   -- Got interrupt on PCINT0
							INT_ACK <= "0001";     -- Acknowledge the interrupt
							PC <= "00000000001";    -- Redirect execution
						ELSIF INT_REQ_SYNC(1) = '1' THEN
							INT_ACK <= "0010";     -- repeat for other pins
							PC <= "00000000010";
						ELSIF INT_REQ_SYNC(2) = '1' THEN
							INT_ACK <= "0100";
							PC <= "00000000011";
						ELSIF INT_REQ_SYNC(3) = '1' THEN
							INT_ACK <= "1000";
							PC <= "00000000100";
						END IF;
						GIE <= '0';            -- Disable interrupts while in ISR
						AC_SAVED <= AC;        -- Save AC
						PC_SAVED <= PC;        -- Save PC
						STATE <= FETCH;        -- Repeat FETCH with new PC
					ELSE -- either no interrupt or interrupts disabled
						PC        <= PC + 1;   -- Increment PC to next instruction address
						STATE     <= DECODE;
						INT_ACK   <= "0000";   -- Clear any interrupt acknowledge
					END IF;
	
	
	
				WHEN DECODE =>
					
					-- Write to the register variables.
					regFileDest 	:= ieee.numeric_std.to_integer(ieee.numeric_std.unsigned(IR(9 downto 5)));
					regFileSource 	:= ieee.numeric_std.to_integer(ieee.numeric_std.unsigned(IR(4 downto 0)));
					
					CASE IR(15 downto 11) IS
					
						WHEN "00000" => 	STATE <= FETCH;
						WHEN "00001" =>     STATE <= EX_LOAD;
						WHEN "00010" =>     STATE <= EX_STORE;
						WHEN "00011" =>     STATE <= EX_ADD;
						WHEN "00100" =>     STATE <= EX_SUB;
						WHEN "00101" =>     STATE <= EX_JUMP;
						WHEN "00110" =>     STATE <= EX_JNEG;
						WHEN "00111" =>     STATE <= EX_JPOS;
						WHEN "01000" =>     STATE <= EX_JZERO;
						WHEN "01001" =>     STATE <= EX_AND;
						WHEN "01010" =>     STATE <= EX_OR;
						WHEN "01011" =>     STATE <= EX_XOR;
						WHEN "01100" =>     STATE <= EX_SHIFT;
						WHEN "01101" =>     STATE <= EX_ADDI;
						WHEN "01110" =>     STATE <= EX_ILOAD;
						WHEN "01111" =>     STATE <= EX_ISTORE;
						WHEN "10000" =>     STATE <= EX_CALL;
						WHEN "10001" =>     STATE <= EX_RETURN;
						WHEN "10010" =>     STATE <= EX_IN;
						
						WHEN "10011" =>       -- OUT
							STATE <= EX_OUT;
							IO_WRITE_INT <= '1'; -- raise IO_WRITE
							
						WHEN "10100" =>       -- CLI
							IIE <= IIE AND NOT(IR(3 DOWNTO 0));  -- disable indicated interrupts
							STATE <= FETCH;
							
						WHEN "10101" =>       -- SEI
							IIE <= IIE OR IR(3 DOWNTO 0);  -- enable indicated interrupts
							STATE <= FETCH;
							
						WHEN "10110" =>       STATE <= EX_RETI;
						WHEN "10111" =>       STATE <= EX_LOADI;


						-- 
						-- Register-to-Register Operations
						--
						-- Harrison

						WHEN "11000" => 	STATE <= EX_MOVR;
						WHEN "11001" => 	STATE <= EX_ADDR;
						WHEN "11010" =>		STATE <= EX_SUBR;
						WHEN "11011" => 	STATE <= EX_ANDR;
						WHEN "11100" => 	STATE <= EX_ORR;
						WHEN "11101" =>		STATE <= EX_CMP;
						WHEN "11110" =>		STATE <= EX_STORER;
						WHEN "11111" =>		STATE <= EX_LOADR;


						WHEN OTHERS =>		STATE <= FETCH;      -- Invalid opcodes default to NOP
						
					END CASE;
				
				
				
				--
				-- Fetch States
				-- 
				--

				WHEN EX_LOAD =>
					AC    <= MDR;            -- Latch data from MDR (memory contents) to AC
					STATE <= FETCH;

				WHEN EX_STORE =>
					MW    <= '1';            -- Raise MW to write AC to MEM
					STATE <= EX_STORE2;

				WHEN EX_STORE2 =>
					MW    <= '0';            -- Drop MW to end write cycle
					STATE <= FETCH;

				WHEN EX_ADD =>
					AC    <= AC + MDR;
					STATE <= FETCH;

				WHEN EX_SUB =>
					AC    <= AC - MDR;
					STATE <= FETCH;

				WHEN EX_JUMP =>
					PC    <= IR(10 DOWNTO 0);
					STATE <= FETCH;

				WHEN EX_JNEG =>
					IF (AC(15) = '1') THEN
						PC    <= IR(10 DOWNTO 0);
					END IF;

				STATE <= FETCH;

				WHEN EX_JPOS =>
					IF ((AC(15) = '0') AND (AC /= x"0000")) THEN
						PC    <= IR(10 DOWNTO 0);
					END IF;
					STATE <= FETCH;

				WHEN EX_JZERO =>
					IF (AC = x"0000") THEN
						PC    <= IR(10 DOWNTO 0);
					END IF;
					STATE <= FETCH;

				WHEN EX_AND =>
					AC    <= AC AND MDR;
					STATE <= FETCH;

				WHEN EX_OR =>
					AC    <= AC OR MDR;
					STATE <= FETCH;

				WHEN EX_XOR =>
					AC    <= AC XOR MDR;
					STATE <= FETCH;

				WHEN EX_SHIFT =>
					AC    <= AC_SHIFTED;
					STATE <= FETCH;

				WHEN EX_ADDI =>
					AC    <= AC + (IR(10) & IR(10) & IR(10) &
					 IR(10) & IR(10) & IR(10 DOWNTO 0));
					STATE <= FETCH;

				WHEN EX_ILOAD =>
					IR(10 DOWNTO 0) <= MDR(10 DOWNTO 0);
					STATE <= EX_LOAD;

				WHEN EX_ISTORE =>
					IR(10 DOWNTO 0) <= MDR(10 DOWNTO 0);
					STATE          <= EX_STORE;

				WHEN EX_CALL =>
					FOR i IN 0 TO 8 LOOP
						PC_STACK(i + 1) <= PC_STACK(i);
					END LOOP;
					PC_STACK(0) <= PC;
					PC          <= IR(10 DOWNTO 0);
					STATE       <= FETCH;

				WHEN EX_RETURN =>
					FOR i IN 0 TO 8 LOOP
						PC_STACK(i) <= PC_STACK(i + 1);
					END LOOP;
					PC          <= PC_STACK(0);
					STATE       <= FETCH;

				WHEN EX_IN =>
					IF IN_HOLD = '0' THEN
						AC    <= IO_DATA;
						IN_HOLD <= '1';
					ELSE
						STATE <= FETCH;
						IN_HOLD <= '0';
					END IF;

				WHEN EX_OUT =>
					STATE <= EX_OUT2;

				WHEN EX_OUT2 =>
					STATE <= FETCH;

				WHEN EX_LOADI =>
					AC    <= (IR(10) & IR(10) & IR(10) &
					 IR(10) & IR(10) & IR(10 DOWNTO 0));
					STATE <= FETCH;

				WHEN EX_RETI =>
					GIE   <= '1';      -- re-enable interrupts
					PC    <= PC_SAVED; -- restore saved registers
					AC    <= AC_SAVED;
					STATE <= FETCH;


				--
				-- Register-to-Register Operations
				--

				WHEN EX_MOVR =>
					
					if( regFileDest = 0 ) then
						
						-- If regFileSource is 0, then we dont want to overwrite AC with register_file(0)
						-- We just skip.
						if( regFileSource /= 0 ) then
						
							AC <= regFile(regFileSource);
						
						end if;
						
					else 
						if( regFileSource = 0) then
							
							regFile(regFileDest) <= AC;
							
						else
					
							regFile(regFileDest) <= regFile(regFileSource);
						
						end if;
					end if;

					STATE <= FETCH;
				
				
				
				
				WHEN EX_ADDR =>

					if( regFileDest = 0 ) then
						
						if(regFileSource = 0) then
							
							-- Effectively doing AC*2.
							AC <= AC + AC;
							
						else
							
							AC <= AC + regFile(regFileSource);
							
						end if;
						
					else 
						
						if(regFileSource = 0) then
					
							AC <= regFile(regFileDest) + AC;
						else
							
							AC <= regFile(regFileDest) + regFile(regFileSource);
						end if;
						
					end if;

					STATE <= FETCH;


				--
				-- SUBR
				-- 
				-- Subtract two registers together.
				--
				-- Format: subr <regA>, <regB> 
				--
				-- AC = <regA> - <regB>
				--
				-- NOTE: The following pseudo-instructions could be implemented in the assembler:
				--
				-- 1) 	subr <regA>, <regB>, <regC> becomes
				-- 
				--		subr <regB>, <regC>
				-- 		movr <regA>, AC
				-- 
				--
				-- 

				WHEN EX_SUBR =>
					
					if( regFileDest = 0 ) then
						
						if(regFileSource = 0) then
							
							-- Anything minus itself is just zero.
							AC <= x"0000";
							
						else
							
							AC <= AC - regFile(regFileSource);
						end if;
						
					else 
						
						if(regFileSource = 0) then
							
							AC <= regFile(regFileDest) - AC;
						else
						
							AC <= regFile(regFileDest) - regFile(regFileSource);
						end if;
						
						
					end if;
					
					STATE 	<= FETCH;

				
	
				--
				-- ANDR
				-- 
				-- Logical AND two registers together.
				--
				-- Format: ANDR <regA>, <regB> 
				--
				-- AC = <regA> & <regB>
				--
				-- NOTE: The following pseudo-instructions could be implemented in the assembler:
				--
				-- 1) 	andr <regA>, <regB>, <regC> becomes
				-- 
				--		andr <regB>, <regC>
				-- 		movr <regA>, AC
				-- 
				--
				-- 
				
				WHEN EX_ANDR =>

					if( regFileDest = 0 ) then
						
						if(regFileSource /= 0) then
							
							AC <= AC and regFile(regFileSource);
						end if;
						
						-- AC <= AC and AC is just AC... IE do nothing.
						
					else 
						
						if(regFileSource /= 0) then
							
							AC <= regFile(regFileDest) and regFile(regFileSource);
						else
							
							AC <= regFile(regFileDest) and AC;
						end if;
						
					end if;

					STATE <= FETCH;
				
				
				
				--
				-- ORR
				-- 
				-- Logical OR two registers together.
				--
				-- Format: ORR <regA>, <regB> 
				--
				-- AC = <regA> | <regB>
				--
				-- NOTE: The following pseudo-instructions could be implemented in the assembler:
				--
				-- 1) 	orr <regA>, <regB>, <regC> becomes
				-- 
				--		orr <regB>, <regC>
				-- 		movr <regA>, AC
				-- 
				--
				-- 

				WHEN EX_ORR =>

					if( regFileDest = 0 ) then
						
						if( regFileSource /= 0) then
						
							AC <= AC or regFile(regFileSource);
						end if;
						
						-- AC <= AC or AC is just AC.
						
					else 
						
						if( regFileSource = 0) then
							
							AC <= regFile(regFileDest) or AC;
						else
					
							AC <= regFile(regFileDest) or regFile(regFileSource);
						end if;
						
					end if;

					STATE <= FETCH;

	
	
				--
				-- CMP
				-- 
				-- Compare two registers together.
				--
				-- Format: CMP <regA>, <regB> 
				--
				-- AC = -1  	when <regA> is less than <regB>
				-- AC = 0 		when <regA> equals <regB>
				-- AC = 1 		when <regA> is greater than <regB>
				--
				-- Then the programmer uses jneg, jzero, jpos to jump accordingly.
				--
				-- NOTE: The following pseudo-instructions could be implemented in the assembler:
				--
				-- 1) 	gt <regA>, <regB>, <labelToJumpToIfTrue> becomes
				-- 
				-- 		cmp <regA>, <regB>
				-- 		jpos <labelToJumpToIfTrue>
				--
				-- 2) 	lt <regA>, <regB>, <labelToJumpToIfTrue> becomes
				--
				-- 		cmp <regA>, <regB>
				-- 		jneg <labelToJumpToIfTrue>
				--
				-- 3) 	eq <regA>, <regB>, <labelToJumpToIfTrue> becomes
				--
				-- 		cmp <regA>, <regB>
				-- 		jzero <labelToJumpToIfTrue>
				--
				-- 4) 	lte <regA>, <regB>, <labelToJumpToIfTrue> becomes
				--
				-- 		cmp <regA>, <regB>
				-- 		jneg <labelToJumpToIfTrue>
				-- 		jzero <labelToJumpToIfTrue>
				--
				-- 5) 	gte <regA>, <regB>, <labelToJumpToIfTrue> becomes
				--
				-- 		cmp <regA>, <regB>
				-- 		jzero <labelToJumpToIfTrue>
				-- 		jpos <labelToJumpToIfTrue>
				--
				-- 
				--
				-- 
	
				WHEN EX_CMP =>
					
					
					if( regFileDest = 0 ) then
						
						-- If we are comparing the AC to the AC then of course it is equal.
						if(regFileSource = 0) then
							
							AC <= x"0000";
						
						else
							
							-- If the AC and the source register are equal then we set the AC = 0.
							if(AC = regFile(regFileSource)) then
							
								AC <= "0000000000000000";
							
							-- If the AC is less than the register source, then we set AC = -1.
							elsif(ieee.numeric_std.signed(AC) < ieee.numeric_std.signed(regFile(regFileSource))) then
							
								AC <= "1111111111111111";
							
							-- If the AC is greater than the register source, then we set AC = 1.
							else
							
								AC <= "0000000000000001";
							
							end if;
						
						end if;
						
					else 
						
						if(regFileSource = 0) then
							
							if(regFile(regFileDest) = AC) then
							
								AC <= "0000000000000000";
							
							elsif(ieee.numeric_std.signed(regFile(regFileDest)) < ieee.numeric_std.signed(AC)) then
							
								AC <= "1111111111111111";
							
							else 
							
								AC <= "0000000000000001";
							
							end if;
							
						else
					
							if(regFile(regFileDest) = regFile(regFileSource)) then
							
								AC <= "0000000000000000";
							
							elsif(ieee.numeric_std.signed(regFile(regFileDest)) < ieee.numeric_std.signed(regFile(regFileSource))) then
							
								AC <= "1111111111111111";
							
							else
							
								AC <= "0000000000000001";
							
							end if;
						
						end if;
						
					end if;

					STATE <= FETCH;



				--
				-- STORER
				-- 
				-- Store data to an address in the supplied register.
				-- Oh yeah, you MUST BE CAREFUL when using this...
				--
				-- On the other hand, you can now write self modifying
				-- code, just in case you want to have some fun...
				--
				--
				-- Format: STORER <register> 
				--
				-- Memory[register] := AC
				-- 
				--
				-- 

				WHEN EX_STORER =>

					-- Modify the instruction register to our new
					-- address which is stored in the register that is
					-- provided as part of the instruction.

					if(regFileDest = 0) then

						IR(10 downto 0) <= AC(10 downto 0);

					else

						IR(10 downto 0) <= regFile(regFileDest)(10 downto 0);
					
					end if;

					-- Now we write the MW signal high. 
					-- On the next clock, MEM_ADDR will be loaded with our 
					-- new "modified" IR values :)

					MW 	<= '1';
					
					STATE <= EX_STORER2;


				WHEN EX_STORER2 =>
					MW <= '0';
					STATE <= FETCH; 


						
				--
				-- LOADR
				-- 
				-- Load data stored in memory at the address specified by in
				-- in the register to the AC.
				--
				-- NOTE: Be careful!! There is no telling what will happen
				-- if you specify an address that is out of bounds!!
				--
				-- Have fun!
				--
				-- Format: LOADR <register> 
				--
				-- AC := Memory[register]
				-- 
				--


				WHEN EX_LOADR =>

					-- Modify the IR(10 downto 0) value to the value stored in
					-- the register.

					if(regFileDest = 0) then

						IR(10 downto 0) <= AC(10 downto 0);

					else

						IR(10 downto 0) <= regFile(regFileDest)(10 downto 0);
					
					end if;

					STATE <= EX_LOADR2;

				WHEN EX_LOADR2 =>

					-- At this point, the memory has been read, and the value
					-- returned to the MDR. We can now grab that data like normal.

					AC <= MDR;

					STATE <= FETCH;



				
				-- Just for reference.
				--WHEN EX_STORE =>
				--	MW    <= '1';            -- Raise MW to write AC to MEM
				--	STATE <= EX_STORE2;

				-- WHEN EX_STORE2 =>
				-- 	MW    <= '0';            -- Drop MW to end write cycle
				--	STATE <= FETCH;






				-- Dont need this... 

				WHEN EX_GT =>
					
					
					
					STATE <= FETCH;

					
					
					
					
					

				WHEN OTHERS =>
					STATE <= FETCH;          -- If an invalid state is reached, return to FETCH
					
			END CASE;
			
			INT_REQ_SYNC <= INT_REQ;  -- register interrupt requests to SCOMP's clock.
			
		END IF;
      END PROCESS;
      
      -- This process monitors the external interrupt pins, setting
	-- some flags if a rising edge is detected, and clearing flags
	-- once the interrupt is acknowledged.
	PROCESS(RESETN, PCINT, INT_ACK, IIE)
	BEGIN
		IF (RESETN = '0') THEN
			INT_REQ <= "0000";  -- clear all interrupts on reset
		ELSE
			FOR i IN 0 TO 3 LOOP -- for each of the 4 interrupt pins
				IF (INT_ACK(i) = '1') OR (IIE(i) = '0') THEN
					INT_REQ(i) <= '0';   -- if acknowledged or masked, clear interrupt
				ELSIF RISING_EDGE(PCINT(i)) THEN
					INT_REQ(i) <= '1';   -- if rising edge on PCINT, request interrupt
				END IF;
			END LOOP;
		END IF;
	END PROCESS;
      
  END a;

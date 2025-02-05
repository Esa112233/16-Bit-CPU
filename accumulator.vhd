----------------------------------------------------------------------------------
-- Company: Department of Electrical and Computer Engineering, University of Alberta
-- Engineer: Shyama Gandhi and Bruce Cockburn
-- Create Date: 10/29/2020 07:18:24 PM
-- Module Name: cpu - structural(datapath)
-- Description: CPU LAB 3 - ECE 410 (2023)
-- Revision:
-- Revision 0.01 - File Created
-- Revision 1.01 - File Modified by Raju Machupalli (October 31, 2021)
-- Revision 2.01 - File Modified by Shyama Gandhi (November 2, 2021)
-- Revision 3.01 - File Modified by Antonio Andara (October 31, 2023)
-- Revision 4.01 - File Modified by Antonio Andara (October 28, 2024)
-- Additional Comments: in order to write to the accumulator acc_write
-- must be set to high, writing of the accumulator only occurs during
-- the rising edge of the clock
--*********************************************************************************
-- 16-bit accumulator register as shown in the datapath of lab manual
-----------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY accumulator IS
PORT( clock     : IN STD_LOGIC
	; reset     : IN STD_LOGIC 
	; acc_write : IN STD_LOGIC  
	; acc_in    : IN STD_LOGIC_VECTOR (15 DOWNTO 0)
	; acc_out   : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
	);

END accumulator;

ARCHITECTURE Behavioral OF accumulator IS

BEGIN

	PROCESS (reset, clock)
	BEGIN
	-- asynchronous reset of the accumulator
		IF reset = '1' THEN
			acc_out <= (OTHERS => '0');
		ELSIF rising_edge(clock) then
		  if acc_write = '1' THEN
			acc_out <= acc_in;
		END IF;
		END IF;
	END PROCESS;
	
END Behavioral;

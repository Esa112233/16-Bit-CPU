
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
-- Additional Comments:
--*********************************************************************************
-- A total of fifteen operations can be performed using 4 select lines of this ALU.
-- The select line codes have been given to you in the lab manual.
-----------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;
USE ieee.std_logic_misc.ALL;


ENTITY alu16 IS
    PORT ( A         : IN  STD_LOGIC_VECTOR(15 DOWNTO 0)
         ; B         : IN  STD_LOGIC_VECTOR(15 DOWNTO 0)
         ; shift_amt : IN  STD_LOGIC_VECTOR(3 DOWNTO 0)
         ; alu_sel   : IN  STD_LOGIC_VECTOR(3 DOWNTO 0)
         ; alu_out   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
         ; overflow : out std_logic
         );
END alu16;

ARCHITECTURE Dataflow OF alu16 IS
signal alu_aux : std_logic_vector (15 downto 0);
BEGIN
alu_out<=alu_aux;
	PROCESS (A, B, shift_amt, alu_sel)
	BEGIN
		CASE alu_sel IS
			WHEN "0001" =>
				alu_aux <= A; -- Pass A
			WHEN "0010" =>
				alu_aux <= B; -- Pass B
			WHEN "0011" =>
				alu_aux <= STD_LOGIC_VECTOR(shift_left(unsigned(B), to_integer(unsigned(shift_amt)))); -- Logical shift left
				--alu_out <= A srl to_integer(unsigned(shift_amt));
			WHEN "0100" =>
				alu_aux <= STD_LOGIC_VECTOR(shift_right(unsigned(B), to_integer(unsigned(shift_amt)))); -- Logical shift right
			WHEN "0101" => -- Add
				alu_aux <= std_logic_vector(signed(A) + signed(B));
			WHEN "0110" => -- subtract
				alu_aux <= std_logic_vector(signed(B) - signed(A));

			WHEN "0111" =>
				alu_aux <= std_logic_vector(signed(B) + 1);
			WHEN "1000" =>
				alu_aux <= std_logic_vector(signed(B) - 1);
			WHEN "1001" =>
				alu_aux <= A and B;
			WHEN "1010" =>
				alu_aux <= A or B;
			WHEN "1011" =>
				alu_aux <= not A;
			WHEN "1100" =>
				alu_aux <= not B;
			WHEN "1101" =>
				alu_aux <= "0000000000000001"; -- should be 1 but idk what to do
			WHEN "1110" =>
				alu_aux <= (others => '0');
			WHEN "1111" => 
				alu_aux <= X"FFFF"; --should be -1 but idk what to do 
		
			WHEN OTHERS =>
				alu_aux <= (OTHERS => '0');
				
		END CASE;
		
	END PROCESS;
	
alu_sel_process : process(alu_sel, alu_aux)
    variable temp : signed(15 downto 0);
	variable temp_A : signed(15 downto 0);
	variable temp_B : signed(15 downto 0);
begin
    
CASE alu_sel IS
    when "0101" => --add
       --logic here
                temp := signed(A) + signed(B);
				temp_A := signed(A);
				temp_B := signed(B);
				
				if (A(15) = B(15)) and (alu_aux(15) /= A(15)) then
				overflow <= '1';
                else
                    overflow <= '0';
                end if;
        
    when "0110" => --subtract
                temp := signed(A) - signed(B);
				temp_A := signed(A);
				temp_B := signed(B);
				
				if (A(15) /= B(15)) and (alu_aux(15) /= A(15)) then
                    overflow <= '1';
                else
                    overflow <= '0';
                end if;
    
    when others =>
    overflow <= '0';
    
    end case;
    
    end process;
    

END Dataflow;
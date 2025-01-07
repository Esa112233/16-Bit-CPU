----------------------------------------------------------------------------------
-- Filename : alu.vhdl
-- Author : Antonio Alejandro Andara Lara
-- Date : 31-Oct-2023
-- Design Name: alu_tb
-- Project Name: ECE 410 lab 3 2023
-- Description : testbench for the ALU of the simple CPU design
-- Revision 1.01 - File Modified by Antonio Andara (October 28, 2024)
-- Additional Comments:
-- Copyright : University of Alberta, 2023
-- License : CC0 1.0 Universal
----------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY alu_tb IS
END alu_tb;

ARCHITECTURE sim OF alu_tb IS
    SIGNAL alu_sel   : STD_LOGIC_VECTOR(3 DOWNTO 0)  := "0000";
    SIGNAL input_a   : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL input_b   : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL shift_amt : STD_LOGIC_VECTOR(3 DOWNTO 0)  := "0000";
    SIGNAL alu_out   : STD_LOGIC_VECTOR(15 DOWNTO 0);
    signal overflow : std_logic := '0';

BEGIN

    uut : ENTITY WORK.alu16 (Dataflow)
        PORT MAP( alu_sel     => alu_sel
                , A           => input_a
                , B           => input_b
                , shift_amt   => shift_amt
                , alu_out     => alu_out
                , overflow    => overflow
                );

        stim_proc : PROCESS
        BEGIN
            -- Test ALU operations:

            -- Direct output of input_a
            alu_sel <= "0001";
            input_a <= "0110010000000000";
            input_b <= "0011001100000000";
            --overflow <= '0';
            WAIT FOR 20 ns;
            
            ASSERT (alu_out = "0110010000000000")
            REPORT "output did not pass for A" 
            SEVERITY ERROR;
            
            -- Direct output of input_b
            alu_sel <= "0010";
            input_a <= "0110010000000000";
            input_b <= "0011001100000000";
            WAIT FOR 20 ns;
            
            ASSERT (alu_out = "0011001100000000")
            REPORT "output did not pass for B" 
            SEVERITY ERROR;
            
            -- shift left
            alu_sel <= "0011";
            input_a <= "1110010000000000";
            input_b <= "0011001100000000";
            shift_amt <= "0001";
            WAIT FOR 20 ns;
            
            ASSERT (alu_out = "0110011000000000")
            REPORT "output did not shift correctly right" 
            SEVERITY ERROR;
            
            -- shift right
            alu_sel <= "0100";
            input_a <= "1110010000000000";
            input_b <= "0011001100000000";
            shift_amt <= "0001";
            WAIT FOR 20 ns;
            
            ASSERT (alu_out = "0001100110000000")
            REPORT "output did not shift correctly left" 
            SEVERITY ERROR;
            
            -- Add
            alu_sel <= "0101";
            input_a <= "0111111111111111";
            input_b <= "0000000000000001";
            WAIT FOR 20 ns;
            
            ASSERT (alu_out = "1000000000000000")
            REPORT "error in add" 
            SEVERITY ERROR;
            
            assert (overflow = '1')
            report "Overflow not detected for addition"
            severity error;
          
            --overflow <= '0';
            
            wait for 10 ns;
            
            -- subtract
            alu_sel <= "0110";
            input_a <= "1000000000000000";
            input_b <= "0000000000000001";
            WAIT FOR 20 ns;
            
            ASSERT (alu_out = "0111111111111111")
            REPORT "error in subtract" 
            SEVERITY error;
            
            Assert (overflow = '1')
            report("overflow not up")
            severity error;
            
            overflow <= '0';
            
            wait for 10 ns;
            -- increment
            alu_sel <= "0111";
            input_a <= "1110010000000000";
            input_b <= "0011001100000000";
            WAIT FOR 20 ns;
            
            ASSERT (alu_out = "1110010000000001")
            REPORT "error in increment" 
            SEVERITY ERROR;
            
            -- decrement
            alu_sel <= "1000";
            input_a <= "1110010000000000";
            input_b <= "0011001100000000";
            WAIT FOR 20 ns;
            
            ASSERT (alu_out = "1110001111111111")
            REPORT "error in decrement" 
            SEVERITY ERROR;
            
             -- and
            alu_sel <= "1001";
            input_a <= "1110010000000000";
            input_b <= "0011001100000000";
            WAIT FOR 20 ns;
            
            ASSERT (alu_out = "0010000000000000")
            REPORT "error in and" 
            SEVERITY ERROR;
            
            -- or
            alu_sel <= "1010";
            input_a <= "1110010000000000";
            input_b <= "0011001100000000";
            WAIT FOR 20 ns;
            
            ASSERT (alu_out = "1111011100000000")
            REPORT "error in or"
            SEVERITY ERROR;
            
            -- not a
            alu_sel <= "1011";
            input_a <= "1110010000000000";
            input_b <= "0011001100000000";
            WAIT FOR 20 ns;
            
            ASSERT (alu_out = "0001101111111111")
            REPORT "error in not a"
            SEVERITY ERROR;
            
             -- not b
            alu_sel <= "1100";
            input_a <= "1110010000000000";
            input_b <= "0011001100000000";
            WAIT FOR 20 ns;
            
            ASSERT (alu_out = "1100110011111111")
            REPORT "error in not b"
            SEVERITY ERROR;
            
            -- 1
            alu_sel <= "1101";
            input_a <= "1110010000000000";
            input_b <= "0011001100000000";
            WAIT FOR 20 ns;
            
            ASSERT (alu_out = "0000000000000001")
            REPORT "error in 1"
            SEVERITY ERROR;
            
            -- 0
            alu_sel <= "1110";
            input_a <= "1110010000000000";
            input_b <= "0011001100000000";
            WAIT FOR 20 ns;
            
            ASSERT (alu_out = "0000000000000000")
            REPORT "error in 0"
            SEVERITY ERROR;
            
            -- -1
            alu_sel <= "1111";
            input_a <= "1110010000000000";
            input_b <= "0011001100000000";
            WAIT FOR 20 ns;
            
            ASSERT (alu_out = X"FFFF")
            REPORT "error in F"
            SEVERITY ERROR;

            -- NAND operation
          --  alu_sel <= "001";
          --  input_a <= "01100100";
           -- input_b <= "00110011";
           -- WAIT FOR 20 ns;
            


            -- Add cases for each ALU operation...

            WAIT;
    END PROCESS stim_proc;

END sim;

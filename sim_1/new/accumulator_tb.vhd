----------------------------------------------------------------------------------
-- Filename : accumulator.vhdl
-- Author : Antonio Alejandro Andara Lara
-- Date : 31-Oct-2023
-- Design Name: accumulator_tb
-- Project Name: ECE 410 lab 3 2023
-- Description : testbench for the accumulator register of the simple CPU
-- Revision 1.01 - File Modified by Antonio Andara (October 28, 2024)
-- Additional Comments:
-- Copyright : University of Alberta, 2023
-- License : CC0 1.0 Universal
----------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY accumulator_tb IS
END accumulator_tb;

ARCHITECTURE sim OF accumulator_tb IS
    SIGNAL clock     : STD_LOGIC                      := '0';
    SIGNAL reset     : STD_LOGIC                      := '0';
    SIGNAL acc_write : STD_LOGIC                      := '0';
    SIGNAL acc_in    : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '1');
    SIGNAL acc_out   : STD_LOGIC_VECTOR (15 DOWNTO 0);

BEGIN

    uut : ENTITY work.accumulator(Behavioral)
        PORT MAP(clock => clock
        ,        reset => reset
        ,        acc_write => acc_write
        ,        acc_in => acc_in
        ,        acc_out => acc_out);

    clk_process : PROCESS
    BEGIN
        WAIT FOR 10 ns;
        clock <= NOT clock;
    END PROCESS clk_process;

    stim_proc : PROCESS
    BEGIN
        -- Reset the accumulator
        reset <= '1';
        WAIT FOR 20 ns;
        reset     <= '0';
        wait for 20 ns;
        
        
        assert (acc_out = "0000000000000000")
        report "acc_out is not 0"
        severity error;
        

        -- Test data write
        acc_in    <= "1010101010101010";
        acc_write <= '1';
        WAIT FOR 20 ns;
        acc_write <= '0';
        wait for 20 ns;

        -- Assertion to check if data is written correctly
        ASSERT (acc_out = "1010101010101010")
        REPORT "Mismatch in acc_out value after first write!"
            SEVERITY ERROR;

        -- Disable write and change input
        acc_write <= '0';
        acc_in    <= "1010010101010101";
        WAIT FOR 20 ns;
        
        
        -- Assertion to check if data is maintained when write is disabled
        ASSERT (acc_out = "1010101010101010")
        REPORT "Mismatch in acc_out value after disabling write!"
        SEVERITY ERROR;
       

        -- Another test data write
        acc_in    <= "1100110011001100";
        acc_write <= '1';
        WAIT FOR 20 ns;

        -- Assertion to check if data is written correctly
        ASSERT (acc_out = "1101110011001100")
        REPORT "Mismatch in acc_out value after second write!"
            SEVERITY ERROR;

        -- Disable write and end the test
        acc_write <= '0';
        WAIT;
    END PROCESS stim_proc;

END sim;

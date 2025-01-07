----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/28/2024 08:38:41 PM
-- Design Name: 
-- Module Name: controller_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity controller_tb is
--  Port ( );
end controller_tb;

architecture Behavioral of controller_tb is

          signal clock          : STD_LOGIC
        ; signal reset          : STD_LOGIC := '0'
        ; signal enter          : STD_LOGIC
        ; signal zero_flag      : STD_LOGIC := '0'
        ; signal sign_flag      : STD_LOGIC := '0'
        ; signal of_flag        : STD_LOGIC := '0'
        ; signal immediate_data : STD_LOGIC_VECTOR(15 DOWNTO 0)
        ; signal mux_sel        : STD_LOGIC_VECTOR(1 DOWNTO 0)
        ; signal acc_mux_sel    : STD_LOGIC
        ; signal alu_mux_sel    : STD_LOGIC
        ; signal acc0_write     : STD_LOGIC
        ; signal acc1_write     : STD_LOGIC
        ; signal rf_address     : STD_LOGIC_VECTOR(2 DOWNTO 0)
        ; signal rf_write       : STD_LOGIC
        ; signal rf_mode        : STD_LOGIC
        ; signal alu_sel        : STD_LOGIC_VECTOR(3 DOWNTO 0)
        ; signal shift_amt      : STD_LOGIC_VECTOR(3 DOWNTO 0)
        ; signal output_en      : STD_LOGIC
        ; signal PC_out         : STD_LOGIC_VECTOR(4 DOWNTO 0)
        ; signal OPCODE_output  : STD_LOGIC_VECTOR(3 DOWNTO 0)
        ; signal done           : STD_LOGIC;
        
        constant clk_period : time := 8ns;
begin

controller : entity work.controller 
port map(
        clock => clock
,       reset => reset
,       enter => enter
,       zero_flag => zero_flag
,       sign_flag => sign_flag
,       of_flag => of_flag
,       immediate_data => immediate_data
,       mux_sel => mux_sel
,       acc_mux_sel => acc_mux_sel
,       alu_mux_sel => alu_mux_sel
,       acc0_write => acc0_write
,       acc1_write => acc1_write
,       rf_address => rf_address
,       rf_write => rf_write
,       rf_mode => rf_mode
,       alu_sel => alu_sel -- use this signal for alu 0 and 1
,       shift_amt => shift_amt -- use this signal for both alu's
,       output_en => output_en
,       PC_out => PC_out
,       OPCODE_output => OPCODE_output
,       done => done);

clock_stim : process
begin
    clock <= '0';
    wait for clk_period/2;
    clock <= '1';
    wait for clk_period/2;
end process;

stim_process : process
begin
    reset <= '1';
    wait for clk_period;
    reset <= '0';
    
    enter <= '1';
    wait for clk_period;
    
    enter <= '1';
    wait for clk_period;
    
    enter <= '1';
    wait for clk_period;
    
    
    wait;
end process;







end Behavioral;

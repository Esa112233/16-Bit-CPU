----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/29/2024 02:01:46 PM
-- Design Name: 
-- Module Name: cpu_core2_tb - Behavioral
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

entity cpu_core2_tb is
--  Port ( );
end cpu_core2_tb;

architecture Behavioral of cpu_core2_tb is

        signal user_input : std_logic_vector(15 downto 0)
   ;    signal reset          : std_logic
   ;    signal enter          : std_logic
   ;    signal clock          : std_logic
   ;    signal done           : std_logic
   ;    signal PC_out         : STD_LOGIC_VECTOR(4 DOWNTO 0)
   ;    signal OPCODE_output  : STD_LOGIC_VECTOR(3 DOWNTO 0)
   ;    signal output         : std_logic_vector(15 downto 0)
   ;    constant clk_period : time := 8 ns;
        
   
  

begin

cpu : entity work.cpu_core 
port map(
            enter => enter
,           reset => reset
,           clock => clock
,           done => done
,           PC_out => PC_out
,           OPCODE_output => OPCODE_output
,           input => user_input
,           output => output);

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
    
    user_input <= "0000000000000010"; 
--user_input <= "1111000011110000";
    enter <= '1';
    wait for clk_period;
    
    enter <= '1';
    wait for clk_period;
    
    enter <= '1';
    wait for clk_period;
    
    
    wait;
end process;


end Behavioral;

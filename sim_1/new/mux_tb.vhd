----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/19/2024 02:56:42 PM
-- Design Name: 
-- Module Name: mux_tb - Behavioral
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

entity mux_tb is
--  Port ( );
end mux_tb;

architecture Behavioral of mux_tb is
    SIGNAL in0    : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL in1    : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL in2    : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL in3    : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL sel    : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL mux_out : STD_LOGIC_VECTOR(15 DOWNTO 0);
    
    SIGNAL mux2_0    : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL mux2_1    : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL sel2    : STD_LOGIC;
    SIGNAL mux_out2 : STD_LOGIC_VECTOR(15 DOWNTO 0);
    
begin

mux4 : entity work.mux4 
            port map( in0 => in0,
                        in1 => in1,
                        in2 => in2,
                        in3 => in3,
                        mux_sel => sel,
                        mux_out => mux_out
        );
        
mux2 : entity work.mux2 
            port map( in0 => mux2_0,
                        in1 => mux2_1,
                        mux_sel => sel2,
                        mux_out => mux_out2
        );
stimulus : process

begin

in0 <= "1111111111111111";
in1 <= "1111111100000000";
in2 <= "0000000000000000";
in3 <= "0000000000000000";
sel <= "00";   

mux2_1 <= "1111111100000000";
mux2_0 <= "0000000011111111";
sel2 <= '0';

 
WAIT FOR 20 ns;

sel <= "01";  
sel2 <= '1';  
WAIT FOR 20 ns;

wait;
end process;
end Behavioral;

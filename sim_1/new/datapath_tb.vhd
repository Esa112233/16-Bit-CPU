----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/19/2024 08:18:45 AM
-- Design Name: 
-- Module Name: datapath_tb - Behavioral
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

entity datapath_tb is
--  Port ( );
end datapath_tb;

architecture Behavioral of datapath_tb is

SIGNAL in2 : std_logic_vector(15 DOWNTO 0) := (others => '0');
    SIGNAL in3 : std_logic_vector(15 DOWNTO 0) := (others => '0');
    SIGNAL mux_sel2_acc : std_logic := '0';
    SIGNAL mux_sel4 : std_logic_vector(1 DOWNTO 0) := (others => '0');
    SIGNAL rf_address : std_logic_vector(2 DOWNTO 0) := (others => '0');
    SIGNAL rf_mode : std_logic := '0';
    SIGNAL rf_write : std_logic := '0';
    SIGNAL output_en : std_logic := '0';
    SIGNAL shift_amt_alu1 : std_logic_vector(3 DOWNTO 0) := (others => '0');
    SIGNAL alu_sel_alu1 : std_logic_vector(3 DOWNTO 0) := (others => '0');
    SIGNAL mux_sel2_alu : std_logic := '0';
    SIGNAL acc0_write : std_logic := '0';
    SIGNAL acc1_write : std_logic := '0';
    SIGNAL shift_amt_alu0 : std_logic_vector(3 DOWNTO 0) := (others => '0');
    SIGNAL alu_sel_alu0 : std_logic_vector(3 DOWNTO 0) := (others => '0');
    SIGNAL clock : std_logic := '0';
    SIGNAL reset : std_logic := '0';
    SIGNAL overflow : std_logic;
    SIGNAL overflow_alu1 : std_logic;
    SIGNAL buffer_output : std_logic_vector(15 DOWNTO 0);
    SIGNAL zero : std_logic;
    SIGNAL sign : std_logic;
    constant clock_period : time := 8 ns;

begin

uut : entity work.datapath
    PORT MAP (
            in2 => in2,
            in3 => in3,
            mux_sel2_acc => mux_sel2_acc,
            mux_sel4 => mux_sel4,
            rf_address => rf_address,
            rf_mode => rf_mode,
            rf_write => rf_write,
            output_en => output_en,
            shift_amt_alu1 => shift_amt_alu1,
            alu_sel_alu1 => alu_sel_alu1,
            mux_sel2_alu => mux_sel2_alu,
            acc0_write => acc0_write,
            acc1_write => acc1_write,
            shift_amt_alu0 => shift_amt_alu0,
            alu_sel_alu0 => alu_sel_alu0,
            clock => clock,
            reset => reset,
            overflow => overflow,
            overflow_alu1 => overflow_alu1,
            buffer_output => buffer_output,
            zero => zero,
            sign => sign
        );
        
-- clock process
clk_process : process
begin
clock <= '0';
wait for clock_period/2;
clock <= '1';
wait for clock_period/2;
end process;

--stimulus
stimulus : process
begin
reset <= '1';
wait for clock_period;
reset <= '0';

-- write to accumulator
acc0_write <= '0'; -- hold value
mux_sel4 <= "11"; -- Select input 3 from mux
in3 <= "0000000011111111"; --initialize the input that will go into acc_0 from mux4

wait for clock_period;

acc0_write <= '1'; -- enable write

wait for clock_period;

acc0_write <= '0';
mux_sel2_acc <= '0'; -- here

wait for clock_period;
-- checking for mode 0
rf_mode <= '0';
rf_write <= '1';
rf_address <= "010";

wait for clock_period;
-- checking for dual write
rf_mode <= '1';
rf_write <= '1';
rf_address <= "101";

wait for clock_period;
-- set to 0
rf_write <= '0';
mux_sel2_alu <= '0';

wait for clock_period;
-- do not B
alu_sel_alu0 <= "1100";

wait for clock_period;
-- now select the output from alu
mux_sel4 <= "00";

wait for clock_period;
-- write it
acc0_write <= '1';

wait for clock_period;
-- show enable
acc0_write <= '1';
output_en <= '1';

wait for clock_period;
-- set to 0
acc0_write <= '0';
output_en <= '0';

wait for clock_period;
-- FFFF
alu_sel_alu1 <= "1111";

wait for clock_period;
-- write out
acc1_write <= '1';

wait for clock_period;
-- rf1_in should be output from alu 1
acc1_write <= '0';
mux_sel2_acc <= '1';

wait for clock_period;
-- checking for mode 0
rf_mode <= '0';
rf_write <= '1';
rf_address <= "000";

wait for clock_period;
-- checking for dual write
rf_mode <= '1';
rf_write <= '1';
rf_address <= "111";

wait for clock_period;

rf_write <= '0';
mux_sel2_alu <= '0';


wait;
end process;

-- write to accumulator


-- final output to buffer
-- write and read to register file
-- alu operation
end Behavioral;

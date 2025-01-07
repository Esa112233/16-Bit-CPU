----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/25/2024 01:16:32 PM
-- Design Name: 
-- Module Name: cpu_core - Behavioral
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

entity cpu_core is

port(
    enter : in std_logic
;   done : out std_logic
;   reset : in std_logic
;   clock : in std_logic
;   input : std_logic_vector(15 downto 0)
;   output : out std_logic_vector(15 downto 0)
;   PC_out : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
;   OPCODE_output  : OUT STD_LOGIC_VECTOR(3 DOWNTO 0));

end cpu_core;

architecture Behavioral of cpu_core is
-- signals for datapath input
        signal immediate_data : std_logic_vector(15 downto 0)
   --;    signal user_input : std_logic_vector(15 downto 0)
   ;    signal mux_sel2_acc : std_logic
   ;    signal mux_sel4 : std_logic_vector(1 downto 0)
   ;    signal rf_address : STD_LOGIC_VECTOR(2 DOWNTO 0)
   ;    signal rf_mode    : std_logic
   ;    signal rf_write   : STD_LOGIC
   ;    signal output_en     : std_logic
   --;    signal shift_amt_alu1 : STD_LOGIC_VECTOR(3 DOWNTO 0)
  -- ;    signal alu_sel_alu1   : STD_LOGIC_VECTOR(3 DOWNTO 0)
   ;    signal mux_sel2_alu  : STD_LOGIC
   ;    signal acc0_write : STD_LOGIC
   ;    signal acc1_write : STD_LOGIC
   ;    signal shift_amt_alu0 : STD_LOGIC_VECTOR(3 DOWNTO 0)
   ;    signal alu_sel_alu0   : STD_LOGIC_VECTOR(3 DOWNTO 0)
   
   -- input signals for controller
        
    ;    signal zero_flag      : STD_LOGIC
    ;   signal sign_flag      : STD_LOGIC
    ;   signal of_flag        : STD_LOGIC;

begin

data_path : entity work.datapath 
port map(
        in2 => immediate_data
,       in3 => input
,       mux_sel2_acc => mux_sel2_acc
,       mux_sel4 => mux_sel4
,       rf_address => rf_address
,       rf_mode => rf_mode
,       rf_write => rf_write
,       output_en => output_en
,       shift_amt_alu1 => shift_amt_alu0
,       alu_sel_alu1 => alu_sel_alu0
,       mux_sel2_alu => mux_sel2_alu
,       acc0_write => acc0_write
,       acc1_write => acc1_write
,       shift_amt_alu0 => shift_amt_alu0
,       alu_sel_alu0 => alu_sel_alu0
,       buffer_output => output
,       clock => clock
,       reset => reset
,       zero => zero_flag
,       sign => sign_flag);

controller : entity work.controller 
port map(
        clock => clock
,       reset => reset
,       enter => enter
,       zero_flag => zero_flag
,       sign_flag => sign_flag
,       of_flag => of_flag
,       immediate_data => immediate_data
,       mux_sel => mux_sel4
,       acc_mux_sel => mux_sel2_acc
,       alu_mux_sel => mux_sel2_alu
,       acc0_write => acc0_write
,       acc1_write => acc1_write
,       rf_address => rf_address
,       rf_write => rf_write
,       rf_mode => rf_mode
,       alu_sel => alu_sel_alu0 -- use this signal for alu 0 and 1
,       shift_amt => shift_amt_alu0 -- use this signal for both alu's
,       output_en => output_en
,       PC_out => PC_out
,       OPCODE_output => OPCODE_output
,       done => done);

end Behavioral;


-- Company: Department of Electrical and Computer Engineering, University of Alberta
-- Engineer: Antonio Andara Lara, Shyama Gandhi and Bruce Cockburn
-- Create Date: 10/29/2020 07:18:24 PM
-- Design Name: DATAPATH FOR THE CPU
-- Module Name: cpu - structural(datapath)
-- Description: CPU_PART 1 OF LAB 3 - ECE 410 (2021)
-- Revision:
-- Revision 0.01 - File Created
-- Revision 1.01 - File Modified by Raju Machupalli (October 31, 2021)
-- Revision 2.01 - File Modified by Shyama Gandhi (November 2, 2021)
-- Revision 3.01 - File Modified by Antonio Andara (October 31, 2023)
-- Revision 4.01 - File Modified by Antonio Andara (October 28, 2024)
-- Additional Comments:
--*********************************************************************************
-- datapath top level module that maps all the components used inside of it
-----------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_misc.ALL;
USE ieee.numeric_std.ALL;

ENTITY datapath IS
    PORT (
    
        in2 : in std_logic_vector(15 downto 0)
   ;    in3 : in std_logic_vector(15 downto 0)
   ;    mux_sel2_acc : in std_logic
   ;    mux_sel4 : in std_logic_vector
   ;    rf_address : in STD_LOGIC_VECTOR(2 DOWNTO 0)
   ;    rf_mode    : IN std_logic
   ;    rf_write   : IN STD_LOGIC
   ;    output_en     : IN std_logic
   ;    shift_amt_alu1 : IN  STD_LOGIC_VECTOR(3 DOWNTO 0)
   ;    alu_sel_alu1   : IN  STD_LOGIC_VECTOR(3 DOWNTO 0)
   ;    mux_sel2_alu  : IN STD_LOGIC
   ;    acc0_write : IN STD_LOGIC
   ;    acc1_write : IN STD_LOGIC
   ;    shift_amt_alu0 : IN  STD_LOGIC_VECTOR(3 DOWNTO 0)
   ;    alu_sel_alu0   : IN  STD_LOGIC_VECTOR(3 DOWNTO 0)
   ;    clock : in std_logic
   ;    reset : in std_logic
   ;    overflow : out std_logic
   ;    overflow_alu1 : out std_logic
   ;    buffer_output : OUT std_logic_vector(15 DOWNTO 0)
   ;    zero : out std_logic
   ;    sign :out std_logic
   
   
    );
END datapath;

ARCHITECTURE Structural OF datapath IS
    ---------------------------------------------------------------------------
    SIGNAL alu0_out    : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL alu1_out    : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL acc0_out    : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL acc1_out    : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL rf0_in      : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL rf1_in      : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL rf0_out     : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL rf1_out     : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL mux_out     : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL alu_mux_out : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL acc_mux_out : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL user_input  : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL ouput_en    : STD_LOGIC;
    SIGNAL clock_div   : STD_LOGIC;
    ---------------------------------------------------------------------------
BEGIN
    -- Instantiate all components here
    mux4 : entity work.mux4
     port map (in0 => alu0_out
     ,         in1 => rf0_out
     ,         in2 => in2
     ,         in3 => in3
     ,         mux_sel => mux_sel4
     ,         mux_out => mux_out);
  

    acc_mux : entity work.mux2
    port map(in0 => acc0_out
    ,        in1 => acc1_out
    ,        mux_sel => mux_sel2_acc
    ,        mux_out => acc_mux_out);

    alu_mux : entity work.mux2
    port map(in0 => rf1_out
    ,        in1 => acc0_out
    ,        mux_sel => mux_sel2_alu
    ,        mux_out => alu_mux_out);

    accumulator0 : entity work.accumulator
    port map(clock => clock
    ,        reset => reset
    ,        acc_write => acc0_write
    ,        acc_in => mux_out
    ,        acc_out => acc0_out);

    accumulator1 : entity work.accumulator
    port map(clock => clock
    ,        reset => reset
    ,        acc_write => acc1_write
    ,        acc_in => alu1_out
    ,        acc_out => acc1_out);

    register_file : entity work.register_file 
    port map(clock => clock
    ,        rf_write => rf_write
    ,        rf_mode => rf_mode
    ,        rf_address => rf_address
    ,        rf0_in => acc0_out
    ,        rf1_in => acc_mux_out
    ,        rf0_out => rf0_out
    ,        rf1_out => rf1_out);

    alu0 : entity work.alu16
    port map(shift_amt => shift_amt_alu0
    ,        alu_sel => alu_sel_alu0
    ,        A => rf0_out
    ,        B => alu_mux_out
    ,        alu_out => alu0_out
    ,        overflow => overflow);

    alu1 : entity work.alu16
    port map(shift_amt => shift_amt_alu1
    ,        alu_sel => alu_sel_alu1
    ,        A => rf1_out
    ,        B => acc0_out
    ,        alu_out => alu1_out
    ,        overflow => overflow_alu1);

    tri_state_buffer : entity work.tri_state_buffer
    port map(output_en => output_en
    ,        buffer_input => acc0_out
    ,        buffer_output => buffer_output);

    -- logic for flags
    
    zero <= '1' when mux_out = "0000000000000000" else '0';
    sign <= mux_out(15);
-- h
END Structural;

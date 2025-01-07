
-- Company: Department of Electrical and Computer Engineering, University of Alberta
-- Engineer: Shyama Gandhi and Bruce Cockburn
-- Create Date: 10/29/2020 07:18:24 PM
-- Updated Date: 01/11/2021
-- Design Name: CONTROLLER FOR THE CPU
-- Module Name: cpu - behavioral(controller)
-- Description: CPU_LAB 3 - ECE 410 (2021)
-- Revision:
-- Revision 0.01 - File Created
-- Revision 1.01 - File Modified by Raju Machupalli (October 31, 2021)
-- Revision 2.01 - File Modified by Shyama Gandhi (November 2, 2021)
-- Revision 3.01 - File Modified by Antonio Andara (October 31, 2023)
-- Revision 4.01 - File Modified by Antonio Andara (October 28, 2024)
-- Additional Comments:
--*********************************************************************************
-- The controller implements the states for each instructions and asserts appropriate control signals for the datapath during every state.
-- For detailed information on the opcodes and instructions to be executed, refer the lab manual.
-----------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY controller IS
    PORT( clock          : IN STD_LOGIC
        ; reset          : IN STD_LOGIC
        ; enter          : IN STD_LOGIC
        ; zero_flag      : IN STD_LOGIC
        ; sign_flag      : IN STD_LOGIC
        ; of_flag        : IN STD_LOGIC
        ; immediate_data : BUFFER STD_LOGIC_VECTOR(15 DOWNTO 0)
        ; mux_sel        : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
        ; acc_mux_sel    : OUT STD_LOGIC
        ; alu_mux_sel    : OUT STD_LOGIC
        ; acc0_write     : OUT STD_LOGIC
        ; acc1_write     : OUT STD_LOGIC
        ; rf_address     : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
        ; rf_write       : OUT STD_LOGIC
        ; rf_mode        : OUT STD_LOGIC
        ; alu_sel        : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
        ; shift_amt      : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
        ; output_en      : OUT STD_LOGIC
        ; PC_out         : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
        ; OPCODE_output  : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
        ; done           : OUT STD_LOGIC
        );
END controller;

ARCHITECTURE Behavioral OF controller IS
    -- Instructions and their opcodes (pre-decided)
    CONSTANT OPCODE_LDI  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0010";
    CONSTANT OPCODE_STA  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0100";
    CONSTANT OPCODE_INC  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1001";
    CONSTANT OPCODE_INA  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0001";
    CONSTANT OPCODE_LDA  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0011";
    CONSTANT OPCODE_ADD  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0101";
    CONSTANT OPCODE_SUB  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0110";
    CONSTANT OPCODE_SHIFL_A  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1000";
   -- CONSTANT OPCODE_INC_A  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1001";
    CONSTANT OPCODE_DEC_A  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1010";
    CONSTANT OPCODE_AND_A  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1011";
    CONSTANT OPCODE_JMPZ  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1101";
    CONSTANT OPCODE_OUTA  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1110";
    CONSTANT OPCODE_BIT_NOT  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0111";
    CONSTANT OPCODE_TAS  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1100";

    -- CONSTANT OPCODE_XXXX : STD_LOGIC_VECTOR(3 DOWNTO 0) := "XXXX"; -- left for implementation
    CONSTANT OPCODE_HALT : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1111";

    TYPE state_type IS ( STATE_FETCH
                       , STATE_DECODE
                       , STATE_LDI
                       , STATE_LDA
                       , STATE_STA
                       , STATE_INC
                       , STATE_ADD
                       , STATE_INA
                       , STATE_SUB
                       , STATE_SHIFT_L    --STATE_INC_A
                       , STATE_DECREMENT_A
                       , STATE_AND_A
                       , STATE_JMPZ
                       , STATE_OUT_A
                       , STATE_NOT
                       , STATE_TAS
                       , STATE_TAS_SET
                       , STATE_TAS_WAIT
                       , STATE_JMPZ_2
                       , STATE_HALT
                       );

    SIGNAL state : state_type;
    SIGNAL IR    : STD_LOGIC_VECTOR(15 DOWNTO 0); -- instruction register
    SIGNAL PC    : INTEGER RANGE 0 TO 31 := 0;    -- program counter
    SIGNAL SIMD  : STD_LOGIC;
    -- program memory that will store the instructions sequentially from part 1 and part 2 test program
    TYPE PM_BLOCK IS ARRAY(0 TO 33) OF STD_LOGIC_VECTOR(15 DOWNTO 0);

BEGIN

    --opcode is kept up-to-date
    OPCODE_output <= IR(7 DOWNTO 4);
    SIMD <= IR(15);

    PROCESS (reset, clock)
        -- "PM" is the program memory that holds the instructions to be executed by the CPU 
        VARIABLE PM     : PM_BLOCK;

        -- To STATE_DECODE the 4 MSBs from the PC content
        VARIABLE OPCODE : STD_LOGIC_VECTOR(3 DOWNTO 0);

    BEGIN
        IF (reset = '1') THEN -- RESET initializes all the control signals to 0.
            PC             <= 0;
            IR             <= (OTHERS => '0');
            PC_out         <= STD_LOGIC_VECTOR(to_unsigned(PC, PC_out'length));
            mux_sel        <= "00";
            alu_mux_sel    <= '0';
            acc_mux_sel    <= '0';
            immediate_data <= (OTHERS => '0');
            acc0_write     <= '0';
            acc1_write     <= '0';
            rf_address     <= "000";
            rf_write       <= '0';
            rf_mode        <= '0';
            alu_sel        <= "0000";
            output_en      <= '0';
            done           <= '0';
            shift_amt      <= "0000";
            state          <= STATE_FETCH; -- shouldnt we go to fetch first?

            -- Test program for STA, LDI and INC
            PM(0) := "0000000000010000"; -- IN A  => send user input to acc0
            -- acc_in = "0000000011111111"
            -- everything else is 0
            PM(1) := "0000000001000001"; -- STA R[1]  => store acc0 to R1 with address 1
            -- R1 will have "0000000011111111" stored in the first address 
            PM(2) := "0000000000110001"; -- LDA R[1]  => load the value in R[1] back into the accumulator                              01101
            -- Acc0 will have an output of "00000000ffffffff"  or 0x00ff
            PM(3) := "0000000010100000";  -- DEC A     => Decrement the value stored in Acc0
            -- Acc0 output should be "0000000011111110" or 0x00fe
            PM(4) := "0000000001000001";  -- STA R[1]  => store Acc0 in Register at index 1
            -- R1 will have "0000000011111110"
            PM(5) := "0000000011100000";  -- OUTA  => Send Acc0 to output
            -- Should see "0000000011111110" on the output
            PM(6) := "0000110011010000";  -- JUMPZ x0C => Jump to element 12
            PM(7) := "0000000000100000";  -- LDI A, x0000  => load immideate data from PM into Acc0
            -- Acc0 will be 0x0000
            PM(8) := "0000000000000000";  -- data for above instruction
            PM(9) := "0000001011010000";  -- JUMPZ x02  -- Jump to element 2 in PM if acc0 is 0, which it should be
            -- Stay 
            PM(10) := "0000000000100000"; -- LDI A, X000F
            PM(11) := "0000000000001111"; -- Data for above
            PM(12) := "0000000001000001"; -- STA R[1]
            -- R[1] should have x000F    or 0x00fe if jumped from pm(6)
            PM(13) := "0000000000100000";  -- LDI A, X00AA
            -- Acc0 sould be X00AA
            PM(14) := "0000000010101010"; -- X00AA
            PM(15) := "0000000010110001"; -- AND A, R[1]o
            -- Acc0 should be 0x000A  or 0x00AA if jumped from pm(6)
            PM(16) := "0000000011100000"; -- OUTA
            -- Should see 0X000A on the ooutput line  or 0x00AA
            PM(17) := "0000000010010000"; -- INCA
            -- Acc0 should be 0x000B     or 0x00AB
            PM(18) := "0000000001000001"; -- STA R[1], A0        -- simd
            -- R[1] Should be 0x000B      or 0x00AB
            PM(19) := "0000000000100000";  -- LDI A, 0X000F
            -- Acc0 should be 0x000F
            PM(20) := "0000000000001111";  -- Data for above
            PM(21) := "0000000001010001"; -- Add A, R[1]                 --simd       
            -- Acc0 should be 0x000B      or  0x00BA
            PM(22) := "0000000011100000"; -- OUTA
            -- Should see 0x000B on the output line
           
            PM(23) := "0000000011000000"; -- TAS
            PM(24) := "0000000001110000"; -- Not
            PM(25) := "0000000011110000"; -- Done should be 1
            
            
--            PM(0) := "0000000000010000";  --IN A  => send user input to acc0
--            --Acc0 Should be 0xf0f0
--            PM(1) := "0000000001000010"; -- STA R[1]  => store acc0 to R2 with address 2
--            -- R2 should be 0xf0f0
--            PM(2) := "0000100011010000";  -- JUMPZ x08 => Jump to element 8 in PM if Acc0 is all zeroes
--            -- should not jump
--            PM(3) := "0000000001010001"; -- Add A, R[1]
--           -- acc0 should be 0xf0f0
--            PM(4) := "1000000001000111"; -- STA R[7] and R[3]  => store acc0 to R2 with address 2
--           -- R[7] will have 0xf0f0  R[3] will have acc1 out
--           PM(5) := "0000000010100000";  -- DEC A     => Decrement the value stored in Acc0
--           -- Acc0 should be 0xf0ef
--           PM(6) := "0000000000100000";  -- LDI A, xffff  => load immideate data from PM into Acc0
--          -- Acc0 should be 0xffff
--           PM(7) := "1111111111111111";  -- LDI A, xffff  => load immideate data from PM into Acc0
--           PM(8) := "0000000011100000";  -- OUTA  => Send Acc0 to output
--           -- output should be 0xffff
--           PM(9) := "0000000011000000"; -- TAS
--           -- Acc0 and R[0] should be 0x0001
--           PM(10) := "0000000001110000"; -- Not
--           -- Acc0 should be 0xfffe
--           PM(11) := "0000000010010000"; -- INC
--           -- Acc0 should be 0xffff
--           PM(12) := "0000000000100000";  -- LDI A, 0X8000
--           -- acc0 should be 0x8000
--           PM(13) := "1000000000000000";  -- 0X8000
--           PM(14) := "0000000001000111"; -- STA R[7], A0
--           -- R[7] should be 0x8000
--           PM(15) := "0000000000110000"; -- LDA R[0]
--           -- Acc0 should be 0x0000
--           PM(16) := "0000000010100000";  -- DEC A     => Decrement the value stored in Acc0
--           -- Acc0 should be 0xffff
--           PM(17) := "0000000011100000"; -- OUTA
--           -- output should be 0xffff
--           PM(18) := "0000000011000000"; -- TAS
--           --Acc0 should be 1 and r[1] should be 1
--           PM(19) := "0000000010010000"; -- INC
--           -- Acc0 should be 0x0002
--           PM(20) := "0000000011110000"; -- Done should be 1
            

        ELSIF RISING_EDGE(clock) THEN
            CASE state IS

                WHEN STATE_FETCH => -- FETCH instruction
                    IF enter = '1' THEN
                        PC_out         <= STD_LOGIC_VECTOR(to_unsigned(PC, PC_out'length));
                        mux_sel        <= "00";
                        alu_mux_sel    <= '0';
                        acc_mux_sel    <= '0';
                        immediate_data <= (OTHERS => '0');
                        acc0_write     <= '0';
                        acc1_write     <= '0';
                        rf_address     <= "000";
                        rf_write       <= '0';
                        rf_mode        <= '0';
                        alu_sel        <= "0000";
                        shift_amt      <= "0000";
                        done           <= '0';
                        PC             <= PC + 1;
                        IR             <= PM(PC);
                        output_en      <= '0';
                        state          <= STATE_DECODE;
                    ELSIF  enter = '0' THEN
                        state <= STATE_FETCH;
                    END IF;

                WHEN STATE_DECODE => -- DECODE instruction

                    OPCODE := IR(7 DOWNTO 4);

                    CASE OPCODE IS
                        WHEN OPCODE_LDI => state <= STATE_LDI;
                        WHEN OPCODE_STA => state <= STATE_STA;
                        WHEN OPCODE_INC => state <= STATE_INC;
                        WHEN OPCODE_INA => state <= STATE_INA;
                        WHEN OPCODE_ADD => state <= STATE_ADD;
                        WHEN OPCODE_SUB => state <= STATE_SUB;
                        WHEN OPCODE_shifl_a => state <= STATE_SHIFT_L;
                        WHEN OPCODE_DEC_A => state <= STATE_DECREMENT_A;
                        WHEN OPCODE_AND_A => state <= STATE_AND_A;
                        WHEN OPCODE_JMPZ => state <= STATE_JMPZ;
                        WHEN OPCODE_OUTA => state <= STATE_OUT_A;
                        WHEN OPCODE_BIT_NOT => state <= STATE_NOT;
                        WHEN OPCODE_TAS => state <= STATE_TAS;
                        WHEN OPCODE_LDA => state <= STATE_LDA;    
                        WHEN OPCODE_HALT => state <= STATE_HALT;
                        WHEN OTHERS     => state <= STATE_HALT;      
                        
                    END CASE;

                    -----------------------------
                    -- multiplexer set up
                    mux_sel        <= "00";
                    acc_mux_sel    <= '0';
                    alu_mux_sel    <= '0';
                    -----------------------------
                    -- accumulator setup
                    acc0_write     <= '0';
                    acc1_write     <= '0';
                    -----------------------------
                    -- register file setup
                    rf_address     <= IR(2 DOWNTO 0); -- decode pre-emptively sets up the register file
                    rf_write       <= '0';
                    rf_mode        <= IR(15); -- SIMD mode
                    -----------------------------
                    -- ALU setup
                    alu_sel        <= "0000";
                    shift_amt      <= IR(3 DOWNTO 0);
                    -----------------------------
                    immediate_data <= PM(PC); -- pre-fetching immediate data
                    output_en      <= '0';
                    done           <= '0';

                WHEN STATE_LDI => -- LDI exceute
                    mux_sel        <= "10";
                    acc_mux_sel    <= '0';
                    alu_mux_sel    <= '0';
                    immediate_data <= PM(PC);
                    acc0_write     <= '1';
                    acc1_write     <= '0';
                    rf_address     <= "000";
                    rf_write       <= '0';
                    alu_sel        <= "0000";
                    output_en      <= '0';
                    done           <= '0';
                    PC             <= PC + 1;
                    state          <= STATE_FETCH;

                WHEN STATE_STA            => -- STA exceute
                    immediate_data <= (OTHERS => '0');
                    acc0_write     <= '0';
                    acc1_write     <= '0';
                    alu_sel        <= "0000";
                    mux_sel        <= "00";
                    rf_write       <= '1';
                    acc_mux_sel    <= '1';
                    alu_mux_sel    <= '0';
                    output_en      <= '0';
                    done           <= '0';
                    state          <= STATE_FETCH;

                WHEN STATE_INC            =>
                    immediate_data <= (OTHERS => '0');
                    alu_sel        <= "0111";
                    shift_amt      <= "0000";
                    mux_sel        <= "00";
                    acc_mux_sel    <= '0';
                    alu_mux_sel    <= '1';
                    acc0_write     <= '1';
                    acc1_write     <= SIMD;
                    rf_address     <= "000";
                    rf_write       <= '0';
                    output_en      <= '0';
                    done           <= '0';
                    state          <= STATE_FETCH;
                    
                WHEN STATE_ADD            => -- correct
                    immediate_data <= (OTHERS => '0');
                    alu_sel        <= "0101";
                    shift_amt      <= "0000";
                    mux_sel        <= "00";
                    acc_mux_sel    <= '0';
                    alu_mux_sel    <= '1';
                    acc0_write     <= '1'; -- 0 sisnce my output is the storage, do we need to add to the accumulator?
                    acc1_write     <= SIMD;
                    rf_address     <= "000";
                    rf_write       <= '0';
                    output_en      <= '0';
                    done           <= '0';
                    state          <= STATE_FETCH;
                    --halt output istruction
                WHEN STATE_INA             =>
                    mux_sel        <= "11";
                    acc0_write     <= '1';
                    state          <= STATE_FETCH;
                    -- MAY NOT NEED THIS acc0_write     <= '1';
                WHEN STATE_SUB             => -- correct
                    alu_sel        <= "0110";
                    alu_mux_sel    <= '1';
                    acc1_write     <= SIMD;
                    acc0_write     <= '1';
                    mux_sel        <= "00";
               
                    state          <= STATE_FETCH;
                    
                WHEN STATE_SHIFT_L             =>
                    alu_sel        <= "0011";
                    alu_mux_sel    <= '1';
                    acc1_write     <= SIMD;
                    acc0_write     <= '1'; -- assuming we dont store it back
                    mux_sel        <= "00";
                   -- shift_amt      <= "0000";  Already done above
                   state          <= STATE_FETCH;
                   
               -- WHEN STATE_INCREMENT_A          =>
                 --   alu_sel        <= "0111";
                   -- alu_mux_sel    <= '1';
                   -- acc1_write     <= SIMD;
                   -- acc0_write     <= '1'; -- assuming we dont store it back
                   -- shift_amt      <= "0000";  Already done above
                  -- state          <= STATE_FETCH;
                   
                WHEN STATE_DECREMENT_A          =>
                    alu_sel        <= "1000";
                    alu_mux_sel    <= '1';
                    acc1_write     <= SIMD;
                    acc0_write     <= '1'; -- assuming we dont store it back
                   -- shift_amt      <= "0000";  Already done above
                   state          <= STATE_FETCH;
                   
                WHEN STATE_AND_A          =>
                    alu_sel        <= "1001";
                    alu_mux_sel    <= '1';
                    acc1_write     <= SIMD;
                    acc0_write     <= '1';
                   -- shift_amt      <= "0000";  Already done above
                   state          <= STATE_FETCH;
                   
                WHEN STATE_JMPZ           =>
                    alu_mux_sel    <= '1';
                    alu_sel        <= "0010";
                    mux_sel        <= "00";
                   
                 
                   state            <= STATE_JMPZ_2;
                   
                WHEN STATE_JMPZ_2           =>
                     IF (zero_flag = '1') THEN
                        PC          <= TO_INTEGER(UNSIGNED(IR(12 downto 8)));      
                   ENd IF;
                   
                   state <= STATE_FETCH;
                   
                   
                WHEN STATE_OUT_A          =>
                   output_en        <= '1';
                   state            <= STATE_FETCH;
                   
                WHEN STATE_NOT       =>  -- MAYBE ADD A STATE FIRST THAT WILL ADD ACC0 TO REGITER FILE
                    alu_sel        <= "1100";
                    alu_mux_sel    <= '1';
                    acc1_write     <= SIMD;
                    acc0_write     <= '1';
                    state          <= STATE_FETCH;
                   
                WHEN STATE_TAS       =>
                    rf_address     <= IR(2 downto 0);
                    mux_sel        <= "01";
                    STATE <= STATE_TAS_WAIT;
                   
                
                WHEN STATE_TAS_WAIT  =>
                    IF (zero_flag = '1') then
                        alu_sel    <= "1101";
                        mux_sel        <= "00";
                        acc0_write     <= '1';
                       STATE <= STATE_TAS_SET;
                    ELSE
                        alu_sel     <= "1110";     -- probably add another state for clearing acc0
                        mux_sel     <= "00";
                        acc0_write     <= '1';
                        STATE <= STATE_FETCH;
                    end if; 
                
                WHEN STATE_TAS_SET   =>
                   -- mux_sel        <= "00";
                    --acc0_write     <= '1';
                    rf_write       <= '1';
                    state          <= STATE_FETCH;
                   
                WHEN STATE_LDA       =>
                    mux_sel        <= "01";
                    acc0_write     <= '1';
                    acc1_write     <= SIMD;
                    state          <= STATE_FETCH;  -- look at this
                    
                WHEN STATE_HALT       =>
                    done <= '1';   -- maybe add output enable
                    output_en <= '1';
                    state <= STATE_HALT;
                    
                   

                WHEN OTHERS =>
                    mux_sel        <= "00";
                    acc_mux_sel    <= '0';
                    alu_mux_sel    <= '0';
                    immediate_data <= (OTHERS => '0');
                    acc0_write     <= '0';
                    acc1_write     <= '0';
                    rf_address     <= "000";
                    rf_write       <= '0';
                    alu_sel        <= "0000";
                    output_en      <= '1';
                    done           <= '1';
                    state          <= STATE_HALT;

            END CASE;
        END IF;
    END PROCESS;

END Behavioral;
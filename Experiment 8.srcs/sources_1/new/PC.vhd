----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Ty Farris and Ryan Solorzano
-- 
-- Create Date: 09/25/2017 12:27:59 PM
-- Design Name: 
-- Module Name: ProgramCounter - Behavioral
-- Project Name: Experiment 3: Counters as Program Counters
-- Target Devices: 
-- Tool Versions: 
-- Description: Program counter executes instructions by using a counter and a mux to select the address and then accesses the instructions in the prog_rom
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

entity ProgramCounter is
    Port ( FROM_IMMED : in STD_LOGIC_VECTOR (9 downto 0);
           FROM_STACK : in STD_LOGIC_VECTOR (9 downto 0);
           PC_MUX_SEL : in STD_LOGIC_VECTOR (1 downto 0);
           FROM_INTRR : in STD_LOGIC_VECTOR (9 downto 0); 
                PC_LD : in STD_LOGIC;
               PC_INC : in STD_LOGIC;
                  RST : in STD_LOGIC;
                  CLK : in STD_LOGIC;
                   IR : out STD_LOGIC_VECTOR (17 downto 0);
                  CNT : out STD_LOGIC_VECTOR (9 downto 0));
end ProgramCounter;

architecture Behavioral of ProgramCounter is
    
    --3X2 MUX ---------------------------------
    component Mux_3x2 
        Port ( A : in STD_LOGIC_VECTOR (9 downto 0);
               B : in STD_LOGIC_VECTOR (9 downto 0);
               C : in STD_LOGIC_VECTOR (9 downto 0);
             SEL : in STD_LOGIC_VECTOR (1 downto 0);
          OUTPUT : out STD_LOGIC_VECTOR (9 downto 0));
    end component;
    
    --10 bit counter---------------------------
    component cntr_10bit
        Port ( D_IN : in STD_LOGIC_VECTOR (9 downto 0);
              PC_LD : in STD_LOGIC;
             PC_INC : in STD_LOGIC;
                RST : in STD_LOGIC;
                CLK : in STD_LOGIC;
           PC_COUNT : out STD_LOGIC_VECTOR (9 downto 0));
    end component;
    
    --program_rom-------------------------------
    component prog_rom
        Port (     ADDRESS : in std_logic_vector(9 downto 0); 
               INSTRUCTION : out std_logic_vector(17 downto 0); 
                       CLK : in std_logic);
    end component;
    
    --intermediate signal declaration
    signal program_d_in : std_logic_vector(9 downto 0);
    signal pc_cnt : std_logic_vector(9 downto 0);
    
begin
    CNT <= pc_cnt;
    mux : Mux_3x2
    port map ( A => FROM_IMMED,
               B => FROM_STACK, 
               C => FROM_INTRR,
             SEL => PC_MUX_SEL,
          OUTPUT => program_d_in);

    program_counter : cntr_10bit
    port map (  D_IN => program_d_in,
               PC_LD => PC_LD,
              PC_INC => PC_INC,
                 RST => RST,
                 CLK => CLK,
            PC_COUNT => pc_cnt);
              
    my_prog_rom : prog_rom
    port map (  ADDRESS =>  pc_cnt,
            INSTRUCTION => IR,
                    CLK => CLK);       
    
end Behavioral;

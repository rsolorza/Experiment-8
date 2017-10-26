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
-- Description: 10-bit counter to count through the addresses
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity cntr_10bit is
    Port ( D_IN : in STD_LOGIC_VECTOR (9 downto 0);
           PC_LD : in STD_LOGIC;
           PC_INC : in STD_LOGIC;
           RST : in STD_LOGIC;
           CLK : in STD_LOGIC;
           PC_COUNT : out STD_LOGIC_VECTOR (9 downto 0));
end cntr_10bit;

architecture Behavioral of cntr_10bit is

signal t_cnt : std_logic_vector(9 downto 0) := "0000000000";

begin

cntr: process(CLK, PC_LD, PC_INC, D_IN, RST, t_cnt)
    begin 
        if (RST = '1') then
            t_cnt <= (others => '0'); -- async clear
        elsif (rising_edge(CLK)) then
            if (PC_LD = '1') then
                t_cnt <= D_IN; -- load
            else
                if (PC_INC = '1') then
                    t_cnt <= t_cnt + 1; -- incr
              --  else 
                --    t_cnt <= t_cnt - 1; -- decr
                    
                end if;
             end if;
          end if;
       end process;
       
       PC_COUNT <= t_cnt;






end Behavioral;
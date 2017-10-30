----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Ty Farris and Ryan Solorzano
-- 
-- Create Date: 09/19/2017 01:03:59 PM
-- Design Name: 
-- Module Name: Mux_2x1 - Behavioral
-- Project Name: Experiment 7
-- Target Devices: 
-- Tool Versions: 
-- Description: Selects the data between 2 inputs
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

entity mux_2x1_10bit is
    Port ( A : in STD_LOGIC_VECTOR (9 downto 0);
           B : in STD_LOGIC_VECTOR (9 downto 0);
           SEL : in STD_LOGIC;
           OUTPUT : out STD_LOGIC_VECTOR (9 downto 0));

end mux_2x1_10bit;

architecture Behavioral of mux_2x1_10bit is

begin
    myProcess: process (A, B, SEL)
    begin 
    
        if (SEL = '0') then
            OUTPUT <= A;
        elsif (SEL = '1') then
            OUTPUT <= B;
        else
            OUTPUT <= "0000000000";
        end if;
    end process;

end Behavioral;
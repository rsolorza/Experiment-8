----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/13/2017 12:02:15 PM
-- Design Name: 
-- Module Name: ALU - Behavioral
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ALU is
    Port ( A : in STD_LOGIC_VECTOR (7 downto 0);
           B : in STD_LOGIC_VECTOR (7 downto 0);
           SEL : in STD_LOGIC_VECTOR (3 downto 0);
           Cin : in STD_LOGIC;
           RESULT : out STD_LOGIC_VECTOR (7 downto 0);
           C : out STD_LOGIC;
           Z : out STD_LOGIC);
end ALU;

architecture Behavioral of ALU is

begin

    logic_unit: process(SEL, A, B, Cin)
        variable result_and_flags : std_logic_vector  (8 downto 0)  := "000000000";
        begin
            case SEL is
                when "0000" =>      -- ADD                
                result_and_flags := ('0' & A) + ('0' & B);

                when "0001" =>      -- ADDC
                result_and_flags := ('0' & A) + ('0' & B) + Cin;
            
                when "0010" =>      -- SUB
                result_and_flags := ('1' & A) - ('1' & B);
            
                when "0011" =>      -- SUBC
                result_and_flags := ('1' & A) - ('1' & B) - Cin;
            
                when "0100" =>      -- CMP
                result_and_flags := ('1' & A) - ('1' & B);
            
                when "0101" =>      -- AND
                result_and_flags := ('0' & A) and ('0' & B);
            
                when "0110" =>      -- OR
                result_and_flags := ('0' & A) or ('0' & B);
            
                when "0111" =>      -- EXOR
                result_and_flags := ('0' & A) xor ('0' & B);
            
                when "1000" =>      -- TEST
                result_and_flags := ('0' & A) and ('0' & B);
            
                when "1001" =>      -- LSL
                result_and_flags(8 downto 1) := A;
                result_and_flags(0) := Cin;
            
                when "1010" =>      -- LSR
                result_and_flags(7) := Cin;
                result_and_flags(8) := A(0);
                result_and_flags(6 downto 0) := A(7 downto 1);
                
                when "1011" =>      -- ROL
                result_and_flags(8) := A(7);
                result_and_flags(7 downto 1) :=  A(6 downto 0);
                result_and_flags(0) := A(7);
            
                when "1100" =>      -- ROR
                result_and_flags(8) := A(0);
                result_and_flags(6 downto 0) := A (7 downto 1);
                result_and_flags(7) := A(0);
            
                when "1101" =>      -- ASR
                result_and_flags(8) := A(0);
                result_and_flags(6 downto 0) := A (7 downto 1);
                result_and_flags(7) := A (7);
            
                when "1110" =>      -- MOV    **Note dont load flags for this instruction** 
                result_and_flags := '0' & B;
                
                when "1111" =>      -- Not used
                result_and_flags := "000000000";
                
                when others =>
                result_and_flags := "000000000";
                
            end case;
            
            C <= result_and_flags(8);   
                    
            if (result_and_flags (7 downto 0) = "00000000") then
                Z <= '1';
            else 
                Z <= '0';
            end if;
            
            RESULT <= result_and_flags(7 downto 0);
        end process;

end Behavioral;
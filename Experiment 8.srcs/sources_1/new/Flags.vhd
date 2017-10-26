----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/20/2017 12:11:21 PM
-- Design Name: 
-- Module Name: Flags - Behavioral
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

entity Flags is
    Port ( FLG_C_SET : in STD_LOGIC;
           FLG_C_CLR : in STD_LOGIC;
           FLG_C_LD : in STD_LOGIC;
           FLG_Z_LD : in STD_LOGIC;
           FLG_LD_SEL : in STD_LOGIC;
           FLG_SHAD_LD : in STD_LOGIC;
           C_FLAG : out STD_LOGIC;
           Z_FLAG : out STD_LOGIC;
           C : in STD_LOGIC;
           Z : in STD_LOGIC;
           CLK : in STD_LOGIC);
end Flags;

architecture Behavioral of Flags is

    component FlagReg is 
        port ( D    : in  STD_LOGIC; --flag input
               LD   : in  STD_LOGIC; --load Q with the D value
               SET  : in  STD_LOGIC; --set the flag to '1'
               CLR  : in  STD_LOGIC; --clear the flag to '0'
               CLK  : in  STD_LOGIC; --system clock
               Q    : out  STD_LOGIC); --flag output
    end component;

begin

    my_cFlag : FlagReg
        port map ( D   => C,
                   LD  => FLG_C_LD,
                  SET  => FLG_C_SET,
                  CLR  => FLG_C_CLR,
                  CLK  => CLK,
                   Q   => C_FLAG);

    my_ZFlag : FlagReg
        port map ( D   => C,
                   LD  => FLG_Z_LD,
                  SET  => '0',
                  CLR  => '0',
                  CLK  => CLK,
                   Q   => Z_FLAG);                   
                   
end Behavioral;

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/20/2017 11:57:56 AM
-- Design Name: 
-- Module Name: testbench_exp7 - Behavioral
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

entity testbench_exp7 is
--  Port ( );
end testbench_exp7;

architecture Behavioral of testbench_exp7 is

    component RAT_wrapper is
        Port ( LEDS     : out   STD_LOGIC_VECTOR(15 downto 0);
               SEGMENTS : out   STD_LOGIC_VECTOR(7 downto 0); 
               DISP_EN  : out   STD_LOGIC_VECTOR(3 downto 0); 
               SWITCHES : in    STD_LOGIC_VECTOR(15 downto 0);
               BUTTONS  : in    STD_LOGIC_VECTOR(3 downto 0); 
               RESET    : in    STD_LOGIC;
               CLK      : in    STD_LOGIC);
    end component;

    signal segments : std_logic_vector(7 downto 0) := (others => '0');
    signal leds : std_logic_vector(15 downto 0) := (others => '0');
    signal disp_en : std_logic_vector (3 downto 0) := (others => '0');
    signal switches : std_logic_vector (15 downto 0) := (others => '0');
    signal buttons : std_logic_vector (3 downto 0) := (others => '0');
    signal reset, clk : std_logic := '0';

    begin

        RAT: RAT_wrapper
            Port map ( LEDS => leds,
                       SEGMENTS => segments, 
                       DISP_EN  => disp_en, 
                       SWITCHES => switches,
                       BUTTONS  => buttons, 
                       RESET => reset,
                       CLK => clk);
                       
                       
                       
        clk_process : process
            begin
                clk <= not clk;
                wait for 1ns;
            end process;
        
        
        
        number_process : process
            begin
                switches <= "0000000001000011";
                buttons <= "0000";
                reset <= '0';
                wait for 40ns;
                
                switches <= "0000000000001111";
                buttons <= "0000";
                reset <= '0';
                wait for 40ns;                
                
                switches <= "1000000001111111";
                buttons <= "0000";
                reset <= '0';
                wait for 40ns;
                
                switches <= "0000000000000000";
                buttons <= "0000";
                reset <= '0';
                wait for 40ns;                
                
            end process; 
    
    end Behavioral;
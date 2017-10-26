-------------------------------------------------------------------------------
-- Company:  RAT Technologies
-- Engineer:  Various RAT rats
-- 
-- Create Date:    1/31/2012
-- Design Name: 
-- Module Name:    RAT_wrapper - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: Wrapper for RAT MCU. This model provides an interface 
--    for the RAT MCU to the Basys3 development board. 
-- 
--    Note: RESET - mapped to middle button on Basys3 board
--       
--          INT - interrupt pin, tied to '0';  
--
--    Note: this version does not utilized all 16 switches and 16 LEDs
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Revision 1.01 - Updated file to support Basys3 board  (11-15-2016)
--               - Added s_output_port to sensitivity list
--               - Added support for clock divider
-- Revision 2.00 - Updated to support all LEDs and switches on 
--                   Basys3 board  (11-20-2016)
-- Additional Comments: 
--
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity RAT_wrapper is
    Port ( LEDS     : out   STD_LOGIC_VECTOR(15 downto 0);
           SEGMENTS : out   STD_LOGIC_VECTOR(7 downto 0); 
           DISP_EN  : out   STD_LOGIC_VECTOR(3 downto 0); 
           SWITCHES : in    STD_LOGIC_VECTOR(15 downto 0);
           BUTTONS  : in    STD_LOGIC_VECTOR(3 downto 0); 
           RESET    : in    STD_LOGIC;
           CLK      : in    STD_LOGIC);
end RAT_wrapper;

architecture Behavioral of RAT_wrapper is

   -------------------------------------------------------------------------------
   -- INPUT PORT IDS -------------------------------------------------------------
   CONSTANT SWITCHES_LO_ID : STD_LOGIC_VECTOR (7 downto 0) := X"20";
   CONSTANT SWITCHES_HI_ID : STD_LOGIC_VECTOR (7 downto 0) := X"21";
   CONSTANT BUTTONS_ID     : STD_LOGIC_VECTOR (7 downto 0) := X"24";
   -------------------------------------------------------------------------------
   
   -------------------------------------------------------------------------------
   -- OUTPUT PORT IDS ------------------------------------------------------------
   CONSTANT LEDS_LO_ID    : STD_LOGIC_VECTOR (7 downto 0) := X"40";
   CONSTANT LEDS_HI_ID    : STD_LOGIC_VECTOR (7 downto 0) := X"41";
   CONSTANT SEGMENTS_ID   : STD_LOGIC_VECTOR (7 downto 0) := X"82";
   CONSTANT DISP_EN_ID    : STD_LOGIC_VECTOR (7 downto 0) := X"83";
   -------------------------------------------------------------------------------

   -------------------------------------------------------------------------------
   -- Declare RAT_MCU ------------------------------------------------------------
   component RAT_MCU 
       Port ( IN_PORT  : in  STD_LOGIC_VECTOR (7 downto 0);
              OUT_PORT : out STD_LOGIC_VECTOR (7 downto 0);
              PORT_ID  : out STD_LOGIC_VECTOR (7 downto 0);
              IO_STRB  : out STD_LOGIC;
              RESET    : in  STD_LOGIC;
              INT      : in  STD_LOGIC;
              CLK      : in  STD_LOGIC);
   end component RAT_MCU;
   -------------------------------------------------------------------------------

   -------------------------------------------------------------------------------
   -- Clock Divider --------------------------------------------------------------
   component clk_div2_buf is
      Port (   CLK : in STD_LOGIC;
             CLK_2 : out STD_LOGIC);
   end component;

   -- The new "master" clock signal ----------------------------------------------
   signal s_clk        : std_logic;

   -- Signals for connecting RAT_MCU to RAT_wrapper ------------------------------
   signal s_input_port  : std_logic_vector (7 downto 0);
   signal s_output_port : std_logic_vector (7 downto 0);
   signal s_port_id     : std_logic_vector (7 downto 0);
   signal s_load        : std_logic;
   --signal s_interrupt   : std_logic; -- not yet used
   
   -- Register definitions for output devices ------------------------------------
   signal r_LEDS_LO    : std_logic_vector (7 downto 0) := (others => '0'); 
   signal r_LEDS_HI    : std_logic_vector (7 downto 0) := (others => '0'); 
   signal r_SEGMENTS   : std_logic_vector (7 downto 0) := (others => '0'); 
   signal r_DISP_EN    : std_logic_vector (3 downto 0) := (others => '0'); 
   -------------------------------------------------------------------------------

begin

   -- Instantiate clock divider---------------------------------------------------
   cdiv2 : clk_div2_buf
   port map(CLK => CLK, 
            CLK_2 => s_clk); 
   -------------------------------------------------------------------------------


   -- Instantiate RAT_MCU --------------------------------------------------------
   MCU: RAT_MCU
   port map(  IN_PORT  => s_input_port,
              OUT_PORT => s_output_port,
              PORT_ID  => s_port_id,
              RESET    => RESET,  
              IO_STRB  => s_load,
              INT      => '0',
              CLK      => s_clk);         
   -------------------------------------------------------------------------------


   ------------------------------------------------------------------------------- 
   -- MUX for selecting what input to read 
   -------------------------------------------------------------------------------
   inputs: process(s_port_id, SWITCHES, BUTTONS)
   begin
      if (s_port_id = SWITCHES_LO_ID) then
         s_input_port <= SWITCHES(7 downto 0);
      elsif (s_port_id = SWITCHES_HI_ID) then
            s_input_port <= SWITCHES(15 downto 8);
      elsif (s_port_id = BUTTONS_ID) then 
         s_input_port <= "0000" & BUTTONS; 
      else
         s_input_port <= x"00";
      end if;
   end process inputs;
   -------------------------------------------------------------------------------


   -------------------------------------------------------------------------------
   -- Decoder for updating output registers
   -- Register updates depend on rising clock edge and asserted load signal
   -------------------------------------------------------------------------------
   outputs: process(s_clk, s_load, s_port_id, s_output_port) 
   begin   
      if (rising_edge(s_clk)) then
         if (s_load = '1') then 
           
            if (s_port_id = LEDS_LO_ID) then
               r_LEDS_LO <= s_output_port;
            elsif (s_port_id = LEDS_HI_ID) then
               r_LEDS_HI <= s_output_port;
            elsif (s_port_id = SEGMENTS_ID) then
               r_SEGMENTS <= s_output_port;
            elsif (s_port_id = DISP_EN_ID) then
               r_DISP_EN <= s_output_port(3 downto 0);
            end if;
           
         end if; 
      end if;
   end process outputs;      
   -------------------------------------------------------------------------------

   -- Register Interface Assignments ---------------------------------------------
   LEDS(7 downto 0) <= r_LEDS_LO; 
   LEDS(15 downto 8) <= r_LEDS_HI; 
   SEGMENTS <= r_SEGMENTS; 
   DISP_EN <= r_DISP_EN; 
   -------------------------------------------------------------------------------
   
end Behavioral;
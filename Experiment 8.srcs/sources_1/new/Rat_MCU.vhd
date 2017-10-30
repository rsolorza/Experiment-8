----------------------------------------------------------------------------------
-- Company: Ratner Engineering
-- Engineer: James Ratner
-- 
-- Create Date:    20:59:29 02/04/2013 
-- Design Name: 
-- Module Name:    RAT_MCU - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: Starter MCU file for RAT MCU. 
--
-- Dependencies: 
--
-- Revision: 3.00
-- Revision: 4.00 (08-24-2016): removed support for multibus
-- Revision: 4.01 (11-01-2016): removed PC_TRI reference
-- Revision: 4.02 (11-15-2016): added SCR_DATA_SEL 
-- Additional Comments: add stack pointer
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity RAT_MCU is
    Port ( IN_PORT  : in  STD_LOGIC_VECTOR (7 downto 0);
           RESET    : in  STD_LOGIC;
           CLK      : in  STD_LOGIC;
           INT      : in  STD_LOGIC;
           OUT_PORT : out  STD_LOGIC_VECTOR (7 downto 0);
           PORT_ID  : out  STD_LOGIC_VECTOR (7 downto 0);
           IO_STRB  : out  STD_LOGIC);
end RAT_MCU;



architecture Behavioral of RAT_MCU is

   component prog_rom  
      port (     ADDRESS : in std_logic_vector(9 downto 0); 
             INSTRUCTION : out std_logic_vector(17 downto 0); 
                     CLK : in std_logic);  
   end component;

   component ALU
       Port (   A : in  STD_LOGIC_VECTOR (7 downto 0);
                B : in  STD_LOGIC_VECTOR (7 downto 0);
              Cin : in  STD_LOGIC;
              SEL : in  STD_LOGIC_VECTOR(3 downto 0);
                C : out  STD_LOGIC;
                Z : out  STD_LOGIC;
           RESULT : out  STD_LOGIC_VECTOR (7 downto 0));
   end component;

   component CONTROL_UNIT 
       Port ( CLK           : in   STD_LOGIC;
              C             : in   STD_LOGIC;
              Z             : in   STD_LOGIC;
              INT           : in   STD_LOGIC;
              RESET         : in   STD_LOGIC; 
              OPCODE_HI_5   : in   STD_LOGIC_VECTOR (4 downto 0);
              OPCODE_LO_2   : in   STD_LOGIC_VECTOR (1 downto 0);
              
              PC_LD         : out  STD_LOGIC;
              PC_INC        : out  STD_LOGIC;
              PC_MUX_SEL    : out  STD_LOGIC_VECTOR (1 downto 0);		  

              SP_LD         : out  STD_LOGIC;
              SP_INCR       : out  STD_LOGIC;
              SP_DECR       : out  STD_LOGIC;
 
              RF_WR         : out  STD_LOGIC;
              RF_WR_SEL     : out  STD_LOGIC_VECTOR (1 downto 0);

              ALU_OPY_SEL   : out  STD_LOGIC;
              ALU_SEL       : out  STD_LOGIC_VECTOR (3 downto 0);

              SCR_WR        : out  STD_LOGIC;
              SCR_ADDR_SEL  : out  STD_LOGIC_VECTOR (1 downto 0);
			  SCR_DATA_SEL  : out  STD_LOGIC; 

              FLG_C_LD      : out  STD_LOGIC;
              FLG_C_SET     : out  STD_LOGIC;
              FLG_C_CLR     : out  STD_LOGIC;
              FLG_SHAD_LD   : out  STD_LOGIC;
              FLG_LD_SEL    : out  STD_LOGIC;
              FLG_Z_LD      : out  STD_LOGIC;
              
              I_SET    : out  STD_LOGIC;
              I_CLR    : out  STD_LOGIC;

              RST           : out  STD_LOGIC;
              IO_STRB       : out  STD_LOGIC);
   end component;

   component RegisterFile 
       Port ( D_IN   : in     STD_LOGIC_VECTOR (7 downto 0);
              DX_OUT : out    STD_LOGIC_VECTOR (7 downto 0);
              DY_OUT : out    STD_LOGIC_VECTOR (7 downto 0);
              ADRX   : in     STD_LOGIC_VECTOR (4 downto 0);
              ADRY   : in     STD_LOGIC_VECTOR (4 downto 0);
              WE     : in     STD_LOGIC;
              CLK    : in     STD_LOGIC);
   end component;

   component ProgramCounter 
      port ( RST,CLK,PC_LD,PC_INC : in std_logic; 
             FROM_IMMED : in std_logic_vector (9 downto 0); 
             FROM_STACK : in std_logic_vector (9 downto 0); 
             FROM_INTRR : in std_logic_vector (9 downto 0); 
             PC_MUX_SEL : in std_logic_vector (1 downto 0); 
                  CNT   : out std_logic_vector (9 downto 0)); 
   end component; 
    
    component Flags
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
    end component;
    
    component Mux_2x1
        Port ( A : in STD_LOGIC_VECTOR (7 downto 0);
               B : in STD_LOGIC_VECTOR (7 downto 0);
             SEL : in STD_LOGIC;
          OUTPUT : out STD_LOGIC_VECTOR (7 downto 0));
    end component;
    
    component Mux_4x1_8bit
         Port ( A : in STD_LOGIC_VECTOR (7 downto 0);
                B : in STD_LOGIC_VECTOR (7 downto 0);
                C : in STD_LOGIC_VECTOR (7 downto 0);
                D : in STD_LOGIC_VECTOR (7 downto 0); 
              SEL : in STD_LOGIC_VECTOR (1 downto 0);
           OUTPUT : out STD_LOGIC_VECTOR (7 downto 0));    
    end component;
    
    component Scratch_Ram
        Port ( DATA_IN  : in  STD_LOGIC_VECTOR (9 downto 0);
               DATA_OUT : out STD_LOGIC_VECTOR (9 downto 0); 
               ADDR     : in  STD_LOGIC_VECTOR (7 downto 0);
               WE       : in  STD_LOGIC; 
               CLK      : in  STD_LOGIC);
        end component;
        
    component mux_2x1_10bit 
            Port ( A : in STD_LOGIC_VECTOR (9 downto 0);
                   B : in STD_LOGIC_VECTOR (9 downto 0);
                   SEL : in STD_LOGIC;
                   OUTPUT : out STD_LOGIC_VECTOR (9 downto 0));
        end component;

    component stack_pointer 
        port (   RST : in std_logic;
                 CLK : in std_logic;
                  LD : in std_logic;
                INCR : in std_logic;
                DECR : in std_logic; 
                 DIN : in std_logic_vector (7 downto 0); 
            DATA_OUT : out std_logic_vector (7 downto 0));
    end component;
        
   -- intermediate signals ----------------------------------  
   signal s_inst_reg : std_logic_vector(17 downto 0) := (others => '0'); 
 
   -- signals into PC ----------------------------------------
   signal pc_mux_input : std_logic_vector(9 downto 0) := (others => '0');
   signal s_pc_count : std_logic_vector(9 downto 0) := (others => '0');
   
   -- signal for Scratch RAM/ SP ------------------------------------------
   signal scr_data_out :std_logic_vector(9 downto 0) := (others => '0');
   
   -- signals into Register File ------------------------------
   signal reg_data_in : std_logic_vector(7 downto 0) := "00000000";
   
   -- signals into the ALU -----------------------------------
   signal dx_out : std_logic_vector(7 downto 0) := "00000000";
   signal dy_out : std_logic_vector(7 downto 0) := "00000000";
   signal alu_b_input : std_logic_vector(7 downto 0) := "00000000";
   signal carry_flag : std_logic := '0';

    -- signals out of the ALU ---------------------------------
    signal alu_result : std_logic_vector(7 downto 0) := "00000000";
    signal c_flag_in : std_logic := '0';
    signal z_flag_in : std_logic := '0';

    -- signals from the Control Unit --------------------------
    signal rf_wr : std_logic := '0';
    signal rf_wr_sel : std_logic_vector(1 downto 0) := "00";
    signal alu_sel : std_logic_vector(3 downto 0) := "0000";
    signal alu_opy_sel : std_logic := '0';
    signal s_pc_ld : std_logic := '0'; 
    signal s_pc_inc : std_logic := '0'; 
    signal s_rst : std_logic := '0'; 
    signal s_pc_mux_sel : std_logic_vector(1 downto 0) := "00"; 
    signal i_flag_set : std_logic := '0';
    signal i_flag_clr : std_logic := '0';
    
    -- signals into SP -------------------------------------------
    signal sp_ld : std_logic := '0';
    signal sp_inc : std_logic := '0';
    signal sp_dec : std_logic := '0';
    signal sp_data_out : std_logic_vector (7 downto 0) := (others => '0');
    signal sp_data_out_minus : std_logic_vector (7 downto 0) := (others => '0');
    
    -- signals into SCR -------------------------------------------
    signal scr_wr : std_logic := '0';
    signal scr_data_sel : std_logic := '0';
    signal scr_addr_sel : std_logic_vector(1 downto 0) := (others => '0');
    signal scr_mux_out : std_logic_vector (9 downto 0) := (others => '0');
    signal scr_addr_mux_out : std_logic_vector (7 downto 0) := (others => '0');
    signal scr_dx_out : std_logic_vector (9 downto 0) := (others => '0');
    
    -- signals into Flags ------------------------------------------
    signal flg_c_set : std_logic := '0';
    signal flg_c_clr : std_logic := '0';
    signal flg_c_ld : std_logic := '0';
    signal flg_z_ld : std_logic := '0';
    signal flg_ld_sel : std_logic := '0';
    signal flg_shad_ld : std_logic := '0';    
    signal z_flag : std_logic := '0';
    
   -- helpful aliases ------------------------------------------------------------------
   alias s_ir_immed_bits : std_logic_vector(9 downto 0) is s_inst_reg(12 downto 3); 
   
   

begin

    OUT_PORT <= dx_out;
    PORT_ID <= s_inst_reg(7 downto 0);
    
   my_prog_rom: prog_rom  
   port map(     ADDRESS => s_pc_count, 
             INSTRUCTION => s_inst_reg, 
                     CLK => CLK); 

   my_alu: ALU
   port map ( A => dx_out,       
              B => alu_b_input,       
              Cin => carry_flag,     
              SEL => alu_sel,     
              C => c_flag_in,       
              Z => z_flag_in,       
              RESULT => alu_result); 


   my_cu: CONTROL_UNIT 
   port map ( CLK           => CLK, 
              C             => carry_flag, 
              Z             => z_flag, 
              INT           => INT, 
              RESET         => RESET, 
              OPCODE_HI_5   => s_inst_reg(17 downto 13), 
              OPCODE_LO_2   => s_inst_reg(1 downto 0), 
              
              PC_LD         => s_pc_ld, 
              PC_INC        => s_pc_inc,  
              PC_MUX_SEL    => s_pc_mux_sel, 

              SP_LD         => sp_ld, 
              SP_INCR       => sp_inc, 
              SP_DECR       => sp_dec, 

              RF_WR         => rf_wr, 
              RF_WR_SEL     => rf_wr_sel, 

              ALU_OPY_SEL   => alu_opy_sel, 
              ALU_SEL       => alu_sel,
			  
              SCR_WR        => scr_wr, 
              SCR_ADDR_SEL  => scr_addr_sel,              
			  SCR_DATA_SEL  => scr_data_sel,
			  
              FLG_C_LD      => flg_c_ld, 
              FLG_C_SET     => flg_c_set, 
              FLG_C_CLR     => flg_c_clr, 
              FLG_SHAD_LD   => flg_shad_ld, 
              FLG_LD_SEL    => flg_ld_sel, 
              FLG_Z_LD      => flg_z_ld, 
              I_SET    => i_flag_set, 
              I_CLR    => i_flag_clr,  

              RST           => s_rst,
              IO_STRB       => IO_STRB);
              

   my_regfile: RegisterFile 
   port map ( D_IN   => reg_data_in,   
              DX_OUT => dx_out,   
              DY_OUT => dy_out,   
              ADRX   => s_inst_reg(12 downto 8),   
              ADRY   => s_inst_reg(7 downto 3),     
              WE     => rf_wr,   
              CLK    => CLK); 


   my_PC: ProgramCounter 
   port map ( RST        => s_rst,
              CLK        => CLK,
              PC_LD      => s_pc_ld,
              PC_INC     => s_pc_inc,
              FROM_IMMED => s_inst_reg(12 downto 3),
              FROM_STACK => scr_data_out,
              FROM_INTRR => "1111111111",
              PC_MUX_SEL => s_pc_mux_sel,
                   CNT   => s_pc_count); 

    my_alu_mux : mux_2x1
        port map ( A => dy_out, 
                   B => s_inst_reg(7 downto 0),
                 SEL => alu_opy_sel,
              OUTPUT => alu_b_input);

    my_flags : Flags
        port map ( FLG_C_SET => flg_c_set,
           FLG_C_CLR => flg_c_clr,
           FLG_C_LD => flg_c_ld,
           FLG_Z_LD => flg_z_ld,
           FLG_LD_SEL => flg_ld_sel,
           FLG_SHAD_LD => flg_shad_ld,
           C_FLAG => carry_flag,
           Z_FLAG => z_flag,
           C => c_flag_in,
           Z => z_flag_in,
           CLK => CLK);
           
    reg_file_mux: Mux_4x1_8bit
        Port map ( A => alu_result,
                   B => scr_data_out(7 downto 0),
                   C => sp_data_out,
                   D => IN_PORT, 
                 SEL => rf_wr_sel,
              OUTPUT => reg_data_in);   
              
    SCR: Scratch_Ram
        Port map ( DATA_IN => scr_mux_out,
                   DATA_OUT => scr_data_out,
                   ADDR => scr_addr_mux_out,
                   WE => scr_wr, 
                   CLK => CLK);  
                   
    sp_data_out_minus <= sp_data_out - 1;
    scr_addr_mux: Mux_4x1_8bit
            Port map ( A => dy_out,
                       B => s_inst_reg(7 downto 0),
                       C => sp_data_out,
                       D => sp_data_out_minus, 
                     SEL => scr_addr_sel,
                  OUTPUT => scr_addr_mux_out);
    
    scr_dx_out <= "00" & dx_out;
    scr_data_mux: mux_2x1_10bit 
        Port map ( A => scr_dx_out,
                   B => s_pc_count,
                 SEL => scr_data_sel,
              OUTPUT => scr_mux_out);
              
    SP: stack_pointer
            port map (   RST => RESET,
                         CLK => CLK,
                          LD => sp_ld,
                        INCR => sp_inc,
                        DECR => sp_dec, 
                         DIN => dx_out, 
                    DATA_OUT => sp_data_out);
              
              

end Behavioral;
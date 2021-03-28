--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   21:03:04 01/16/2018
-- Design Name:   
-- Module Name:   C:/Users/Maciek/Desktop/PWR 2017-18 ZIMA/0vlsi projekt/VHDL/SR_230196_DANICKIm/dystrybutortest.vhd
-- Project Name:  SR_230196_DANICKIm
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: dystrybutor
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes:
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY dystrybutortest IS
END dystrybutortest;
 
ARCHITECTURE behavior OF dystrybutortest IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT dystrybutor
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         pelny : IN  std_logic;
			koniec : IN  std_logic;
         rodzpaliwa : IN  std_logic;
         postep : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
	signal koniec : std_logic := '0';
   signal pelny : std_logic := '0';
   signal rodzpaliwa : std_logic := '0';

 	--Outputs
   signal postep : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: dystrybutor PORT MAP (
          clk => clk,
          reset => reset,
          pelny => pelny,
			 koniec => koniec,
          rodzpaliwa => rodzpaliwa,
          postep => postep
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
   -- Stimulus process
   stim_proc: process
   begin		
		wait for clk_period;
		reset <='1';
		wait for clk_period;
		reset <='0';
		wait for clk_period;
		rodzpaliwa <='0';
		pelny <='0';
		wait for clk_period*10;
		pelny <='1';
      wait for clk_period*4;
		koniec <='1';
		wait for clk_period*10;
   end process;

END;

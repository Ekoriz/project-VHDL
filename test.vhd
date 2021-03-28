-------------------------------PROJEKT VHDL ----------------------------------------------
----------------------------Maciej DANICKI 230196-----------------------------------------
----------------------------Dystrybutor paliwa--------------------------------------------
						
---------------------------Zajêcia Œrody 11:15--------------------------------------------
------------------------------20.01.2018--------------------------------------------------
library std, ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.std_logic_textio.all;

ENTITY test IS
END test;
 
ARCHITECTURE behavior OF test IS 
 
    COMPONENT dystrybutor
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         pelny : IN  std_logic;
         koniec : IN  std_logic;
         rodzpaliwa : IN  std_logic;
			teraz : out std_logic;
			rodzpaliwadozapisu : OUT  std_logic_vector(7 downto 0);
			cenapaliwadozapisu : OUT  std_logic_vector(7 downto 0);
			ILOSCLITROW : out std_logic_vector(7 downto 0);
			CENAZAPALIWOALL : out std_logic_vector(7 downto 0);
         postep : OUT  std_logic
        );
    END COMPONENT;
    
	

   --Inputs
	
	signal strobe : std_logic;
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal pelny : std_logic := '0';
   signal koniec : std_logic := '0';
   signal rodzpaliwa : std_logic := '0';

 	--Outputs
	
	signal rodzpaliwadozapisu : std_logic_vector(7 downto 0);
	signal cenapaliwadozapisu : std_logic_vector(7 downto 0);
	signal teraz : std_logic;
   signal postep : std_logic;
	signal	ILOSCLITROW  : std_logic_vector(7 downto 0);
	signal	CENAZAPALIWOALL  : std_logic_vector(7 downto 0);
   -- Clock period definitions
   constant period     : time := 20 ns;  
   constant p10        : time := period/10;
   constant edge       : time := period-p10;
   constant clk_period : time := 10 ns;

	shared variable zapisz:boolean:=False;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: dystrybutor PORT MAP (
          clk => clk,
          reset => reset,
          pelny => pelny,
          koniec => koniec,
			 ILOSCLITROW => ILOSCLITROW,
			 CENAZAPALIWOALL => CENAZAPALIWOALL,
			 rodzpaliwadozapisu => rodzpaliwadozapisu,
			 cenapaliwadozapisu => cenapaliwadozapisu,
			 teraz => teraz,
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
		reset <='1';
		wait for clk_period;
		reset <='0';
--#1 TANKOWANIE DO PELNA Z ODLOZENIEM DOZOWNIKA	
		rodzpaliwa <='1';
		wait for clk_period;
		koniec <='0';
		pelny <='0';
      wait for clk_period*5;
		pelny <='1';
      wait for clk_period;
		koniec <='1';
		wait for clk_period;
		
--#2 TANKOWANIE DO PELNA BEZ ODKLADANIA DOZOWNIKA 			
		rodzpaliwa <='0';
		wait for clk_period;
		koniec <='0';
		pelny <='0';
		wait for clk_period*7;
		pelny <='1';
      wait for clk_period*2;
--#3 TANKOWANIE Z ODLOZENIEM DOZOWNIKA	
		rodzpaliwa <='1';
		wait for clk_period;
		koniec <='0';
		pelny <='0';
      wait for clk_period*5;
		koniec <='1';
		wait for clk_period;
--#4 TANKOWANIE Z ZMIANA RODZAJU PALIWA  	
		wait for clk_period;
		rodzpaliwa <='0';
		wait for clk_period;
		koniec <='0';
		pelny <='0';
      wait for clk_period*4;
		rodzpaliwa <='1';
		wait for clk_period*4;
		pelny <='1';
      wait for clk_period;

--#5 TANKOWANIE i po jednym cyklu koniec 
      wait for clk_period;		
		koniec <='0';
		rodzpaliwa <='0';
		pelny <='0';
		wait for clk_period;	
		koniec <='1';

--#5 TANKOWANIE i po jednym cyklu koniec 
      wait for clk_period;		
		koniec <='0';
		rodzpaliwa <='1';
		pelny <='0';
		wait for clk_period*25;
		koniec <='1';
		pelny <='1';
      wait for clk_period*4;



		
		end process;
		
		
		
		
		
		
		
		
		
		
		
		
		----------------------------
		-------- opóŸnienie sygna³u strobuj¹cego ---------
strobe <= TRANSPORT clk AFTER edge;
-------- zapis danych do pliku - proces: „output" -------- 

 
output: PROCESS (strobe,teraz)

variable str        :string(1 to 40);
variable lineout    :line;
variable init_file  :std_logic := '1';
file outfile        :text is out "wy.txt";
-------- funkcja konwersji: std_logic => character 
-------- 

FUNCTION conv_to_char (sig: std_logic) RETURN character IS
BEGIN
CASE sig IS
WHEN '1'     => return '1';
WHEN '0'     => return '0';
WHEN 'Z'     => return 'Z';
WHEN others  => return 'X';
END CASE;
END conv_to_char;


-------- funkcja konwersji: std_logic_vector => string -------- 
FUNCTION conv_to_string (inp: std_logic_vector; length: integer) RETURN string IS
VARIABLE s : string(1 TO length);
BEGIN
FOR i IN 0 TO (length-1) LOOP
s(length-i) := conv_to_char(inp(i));
END LOOP;
RETURN s;
END conv_to_string;


FUNCTION conv_to_string1 (inp: std_logic_vector; length: integer) RETURN string IS
VARIABLE d : string(1 TO length);
--VARIABLE dd : std_logic_vector(7 downto 0);
BEGIN
--dd := conv_to_char(inp);
FOR i IN 0 TO (length-1) LOOP
--dd := dd-"00000001";
--d <= d+1;
END LOOP;
RETURN d;

END conv_to_string1;



-------------------------------------
BEGIN
-------- nag³ówek pliku wyjœciowego (podzia³ kolumn) -------- 
IF init_file = '1' THEN
--str:="clk                                     ";
--write(lineout,str); writeline(outfile,lineout);
--str:="| reset                                 ";
--write(lineout,str); writeline(outfile,lineout);
str:="| | Ilosc(L)                            ";
write(lineout,str); writeline(outfile,lineout);
str:="| |           Koszt           |  0=ON  |";
write(lineout,str); writeline(outfile,lineout);
str:="| |         |          Cena(L)|  1=PB  |";
write(lineout,str); writeline(outfile,lineout);
str:="| |         |        |        | Rodzaj |";
write(lineout,str); writeline(outfile,lineout);
str:="| |         |        |        |        |";
write(lineout,str); writeline(outfile ,lineout);
init_file := '0';
END IF;
-------- zapis danych do pliku wyjsciowego „wyjscie" -------- 
IF (strobe'EVENT AND strobe='0' and teraz='1') THEN
str    := (others => ' ');
--str(1) := conv_to_char(clk);
str(1) := '|';
--str(3) := conv_to_char(reset);
str(3)  := '|';
str(5 to 12) := conv_to_string(ILOSCLITROW,8);
str(13)      := '|';
str(14 to 21) := conv_to_string(CENAZAPALIWOALL,8);
str(22) 		 := '|';
str(23 to 30) := conv_to_string(cenapaliwadozapisu,8);
str(31)      := '|';
str(32 to 39) := conv_to_string(rodzpaliwadozapisu,8);
str(40)      := '|';
write(lineout,str);
writeline(outfile,lineout);
END IF;

END PROCESS output;

END;

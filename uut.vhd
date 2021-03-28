

-------------------------------PROJEKT VHDL ----------------------------------------------
----------------------------Maciej DANICKI 230196-----------------------------------------
----------------------------Dystrybutor paliwa--------------------------------------------
						
---------------------------Zajêcia Œrody 11:15--------------------------------------------
------------------------------20.01.2018--------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;


entity dystrybutor is
		port ( clk,reset : in std_logic; -- wejœcia: zegarowe i zeruj¹ce
		pelny : in std_logic;            -- wejœcie - stan baku
		koniec : in std_logic;           --koniec polozenie dozownika paliwa '1' oznacza ze dozownik jest nie uzywany 
		rodzpaliwa : in std_logic;       --0=PB 1=ON
		teraz : out std_logic;           --informacja o zapisie
		rodzpaliwadozapisu : OUT  std_logic_vector(7 downto 0); -- informacja o rodzaju paliwa do zapisania w pliku 
		cenapaliwadozapisu : OUT  std_logic_vector(7 downto 0); -- informacja o cenie  paliwa do zapisania w pliku 
		ILOSCLITROW : out std_logic_vector(7 downto 0);			  -- suma zatankownaych litow
		CENAZAPALIWOALL : out std_logic_vector(7 downto 0);	  -- cena za cale paliwo
		
		postep : out std_logic); -- wyjœcie
end dystrybutor;

architecture dystrybutora of dystrybutor is


		
		type STANY is (oczekiwanie,sprawdzanie,nalewanie,drukowanie); -- deklaracja typu wyliczeniowego
		signal stan, stan_nast : STANY; -- sygna³y: stan i stan_nast typu STANY;
		signal litry :std_logic_vector(7 downto 0); -- sygna³: litry (iloœæ paliwa)
		signal cenalitra :std_logic_vector(7 downto 0);
		signal cenazapaliwo :std_logic_vector(7 downto 0);
		signal doliczeniaceny :std_logic_vector(7 downto 0);
	--	signal dozmianynainteger :std_logic_vector(7 downto 0);
	--	signal dozmianynainteger2 :std_logic_vector(7 downto 0);
		begin
		
		
			reg:process(clk,reset)
			begin
						if (reset='1')then
								stan <=oczekiwanie;
						elsif(clk'Event and clk='1') then
								stan<=stan_nast;
						end if;
			end process reg;
			
			
			komb:process(stan,pelny,litry,cenazapaliwo,koniec)
			begin
					stan_nast<= stan; -- pozwala unikn¹æ wielkrotnego
					case stan is -- pisania else stan_nast <= „po staremu";
							when oczekiwanie=>
									if (koniec='0') then
											stan_nast<= sprawdzanie;
									elsif (koniec='1' or pelny='1')then 
											stan_nast<= oczekiwanie;
									elsif (pelny='0' and koniec='0') then
											stan_nast<= sprawdzanie;
									elsif (koniec='0') then
											stan_nast<= sprawdzanie;
									else
									stan_nast<= sprawdzanie;
									end if;
							when sprawdzanie=>
									if (koniec='1')then 
										stan_nast<= drukowanie;
									elsif (pelny='1')	then
										stan_nast<= oczekiwanie;
									elsif(pelny ='0' and koniec='0' )then	
										stan_nast<= nalewanie;	
									end if;
									
									
							when nalewanie=>
									if (koniec='1' or pelny ='1' )then 
										stan_nast<= drukowanie;
									elsif (pelny='0' AND koniec='0' ) and (litry="00011111") then
										stan_nast<= oczekiwanie;
									elsif (pelny='0' and koniec='0') then
										stan_nast<= nalewanie;
									else 
										stan_nast<= drukowanie;
									
									end if;
						
						
							when drukowanie=>
									if (koniec='1')then 
										stan_nast<= oczekiwanie;
									elsif(pelny ='1')then	
										stan_nast<= oczekiwanie;
									else
										stan_nast<= oczekiwanie;
									end if;
							
							
				end case;
		end process komb;
		
		--wybor paliwa i przypisanie odpowiedniej ceny 
		rodzpaliw:process(rodzpaliwa)
		begin
		     if rodzpaliwa='0' then
			  cenalitra <= "00000011";
			  
			  cenapaliwadozapisu <= "00000011";  --out uzywany do zapisu do pliku 
			  rodzpaliwadozapisu <= "00000000";	 --out uzywany do zapisu do pliku 
			  
			--  cenapaliwadozapisu <= to_integer(signed(dozmianynainteger));
			--  rodzpaliwadozapisu <= to_integer(signed(dozmianynainteger2));
			  elsif (rodzpaliwa='1') then
				cenalitra <= "00000100";
				
				cenapaliwadozapisu <= "00000100";
			   rodzpaliwadozapisu <= "00000001";

		end if;
		end process rodzpaliw;
		
		--licznik litrow i ceny paliwa 
		licznik:process(clk,reset,stan,stan_nast)
		begin
				if reset ='1' then
							litry <= "00000000";
							doliczeniaceny<="00000000";
				elsif (clk'event and clk='1') then
						if (stan_nast=nalewanie AND litry /="00011111") then
							litry<= litry+1; 
							doliczeniaceny<= doliczeniaceny+cenalitra;
							ILOSCLITROW <= litry;
							CENAZAPALIWOALL <= doliczeniaceny;
						elsif(stan_nast=oczekiwanie )then
								ILOSCLITROW<= "00000000";
								CENAZAPALIWOALL<="00000000";
								litry<= "00000000";
								doliczeniaceny<= "00000000";
								
	--aby inicjalizowac od 1 litra a nie od 0 
						elsif(stan_nast=sprawdzanie and rodzpaliwa='0')then
								ILOSCLITROW<= "00000001";
								CENAZAPALIWOALL<="00000011";
								litry<= "00000001";
								doliczeniaceny<= "00000011";
						elsif(stan_nast=sprawdzanie and rodzpaliwa='1')then
								ILOSCLITROW<= "00000001";
								CENAZAPALIWOALL<="00000100";
								litry<= "00000001";
								doliczeniaceny<= "00000100";
						else
								
								litry<= "00000000";
								doliczeniaceny<= "00000000";
						end if;
				end if;
		end process licznik;
	
		koszty:process(cenalitra,litry,clk)
		begin
				if stan=drukowanie and (koniec='1' or pelny='1') then
				cenazapaliwo <= litry;
				elsif(koniec='0') then 
				cenazapaliwo <= "00000000";
				else

		end if;
		end process koszty;
		
		kiedyzapis:process(stan,stan_nast)
		begin
				if stan=drukowanie and (koniec='1' or pelny='1') then 
				teraz <= '1';
				elsif ( stan=oczekiwanie) then
				teraz <= '0';
				else
				teraz <= '0';
				end if;
		end process kiedyzapis;
		
		postep <= '1' when stan = nalewanie else '0';
		
end dystrybutora;


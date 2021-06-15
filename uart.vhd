-- uart.vhd: UART controller - receiving part
-- Author(s): Lenka Šoková xsokov01
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use ieee.numeric_std.all;

-------------------------------------------------
entity UART_RX is
port(	
    CLK: 	    in std_logic;
	RST: 	    in std_logic;
	DIN: 	    in std_logic;
	DOUT: 	    out std_logic_vector(7 downto 0);
	DOUT_VLD: 	out std_logic
);
end UART_RX;  

-------------------------------------------------
architecture behavioral of UART_RX is

signal cnt  : std_logic_vector(4 downto 0);
signal cnt1 : std_logic_vector(3 downto 0);
signal rx_en : std_logic;
signal cnt_en : std_logic;
signal DVLD : std_logic := '0';

begin
	FSM : entity work.UART_FSM(behavioral)
    port map (
        CLK 	    => CLK,
        RST 	    => RST,
        DIN 	    => DIN,

        CNT 	    => cnt,
        CNT1 	    => cnt1,
		RX_EN       => rx_en,
		CNT_EN 		=> cnt_en,
		
		DOUT_VLD    => DVLD
    );

	DOUT_VLD <= DVLD;

	process (CLK) begin
		if (RST = '1') then
			cnt <= "00000";
			cnt1 <= "0000";
			DOUT <= "00000000";
		
		elsif rising_edge(CLK) then
			
			if cnt_en = '1' then
				cnt <= cnt + 1;
			
				-- vstup sa načítal na výstup
			elsif cnt1(3) = '1' then
				cnt1 <= "0000";
				cnt <= "00000";
			end if;

			-- reset DOUT
			if DVLD = '1' then
				DOUT <= "00000000";
			end if;

			if rx_en = '1' and (cnt = "01111" or cnt(4) = '1') then								
				cnt <= "00000";

				-- nastavenie výstupu podľa vstupných bitov
				case cnt1 is
				when "0000" => DOUT(0) <= DIN;
				when "0001" => DOUT(1) <= DIN;
				when "0010" => DOUT(2) <= DIN;
				when "0011" => DOUT(3) <= DIN;
				when "0100" => DOUT(4) <= DIN;
				when "0101" => DOUT(5) <= DIN;
				when "0110" => DOUT(6) <= DIN;
				when "0111" => DOUT(7) <= DIN; 
				when others => null;
				end case;
				
				cnt1 <= cnt1 + 1;
			end if;
		end if;
	end process;

end behavioral;

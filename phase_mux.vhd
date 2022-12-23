LIBRARY ieee; 
USE ieee.std_logic_1164.all; 
USE ieee.numeric_std.all; 

entity phase_mux is
    port(
        clk: in std_logic;
        phase_in0: in std_logic;
        phase_in1: in std_logic;
        phase_in2: in std_logic;
        phase_in3: in std_logic;
        phase_out: out std_logic;
        mux_sel: in std_logic_vector(1 downto 0)
    );
end phase_mux;

architecture phasemux_arc of phase_mux is
begin
    process(clk)
    begin
    if (clk'event) and (clk='1') then
        case mux_sel is
            when "00" => phase_out<=phase_in0;
            when "01" => phase_out<=phase_in1;
            when "10" => phase_out<=phase_in2;
            when others => phase_out<=phase_in3;
        end case;
    end if;
    end process;
end phasemux_arc;
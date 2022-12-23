LIBRARY ieee; 
USE ieee.std_logic_1164.all; 
USE ieee.numeric_std.all; 

LIBRARY work;
USE work.design_package.all;

entity phase_register is
    port(
        clk: in std_logic;
        phase_in:in std_logic;
        o_phase: out std_logic;
        load_phase: in std_logic;
        rst:in std_logic
    );
end phase_register;

architecture keynonce_arc of phase_register is
begin
    process(clk, load_phase, rst, phase_in)
    begin
    if (rst='1') then
        o_phase<='1';--up
    elsif (clk'event and clk ='1') then
        if (load_phase='1') then
        o_phase<=phase_in;
        end if;
    end if;
    end process;

end keynonce_arc;
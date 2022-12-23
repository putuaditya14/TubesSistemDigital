LIBRARY ieee; 
USE ieee.std_logic_1164.all; 
USE ieee.numeric_std.all; 

LIBRARY work;
USE work.design_package.all;

entity state_register is
    port(
        state_in:in std_logic_vector(383 downto 0);
        clk:in std_logic;
        state_out: out std_logic_vector(383 downto 0);
        load_state: in std_logic;
        rst:in std_logic
    );
end state_register;

architecture state_arc of state_register is
begin
    process(clk, load_state, rst, state_in)
    begin
    if (rst='1') then
        state_out<=(383 downto 0 =>'0');
    elsif (clk'event and clk='1') then
        if (load_state ='1') then
            state_out<=state_in;
        end if;
    end if;
    end process;
end state_arc;
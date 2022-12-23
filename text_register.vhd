LIBRARY ieee; 
USE ieee.std_logic_1164.all; 
USE ieee.numeric_std.all; 

LIBRARY work;
USE work.design_package.all;

entity text_register is
    port(
        enc_mode: in std_logic;
        text_in:in std_logic_vector(text_l-1 downto 0);
        clk:in std_logic;
        text_out: out std_logic_vector(text_l-1 downto 0);
        text_load: in std_logic;
        rst:in std_logic;
        tag_match: in std_logic
    );
end text_register;

architecture text_arc of text_register is
signal new_text: std_logic_vector(text_l-1 downto 0);
begin
    process(clk, text_load, rst, text_in, enc_mode, tag_match)
    begin
    if (rst='1') then
        text_out<=(text_l-1 downto 0=>'0');
    elsif (clk'event and clk='1') then
        if (enc_mode='1') then
            if (text_load='1') then
                text_out<=text_in;
            end if;
        else
            if (text_load='1') then
                new_text<=text_in;
            end if;
            if (tag_match='1') then
                text_out<=new_text;
            end if;
        end if;
    end if;
    end process;
end text_arc;
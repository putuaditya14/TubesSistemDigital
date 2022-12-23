LIBRARY ieee; 
USE ieee.std_logic_1164.all; 
USE ieee.numeric_std.all; 

LIBRARY work;
USE work.design_package.all;

entity tag_register is
    port(
        clk: in std_logic;
        enc_mode: in std_logic;
        tag_in: in std_logic_vector((tag_l-1) downto 0);
        o_tag: out std_logic_vector((tag_l-1) downto 0);
        load_tag: in std_logic;
        rst:in std_logic
    );
end tag_register;

architecture tag_arc of tag_register is
begin
    process(clk, enc_mode, tag_in, tag_in, rst)
    begin
    if (rst='1') then
        o_tag<=((tag_l-1) downto 0 =>'0');
    elsif (clk'event and clk='1') then
        if (load_tag='1' and enc_mode='1') then
            o_tag<=tag_in;
        elsif (load_tag='1' and enc_mode='0') then
            o_tag<=(tag_l-1 downto 0 =>'0');
        end if;
    end if;
    end process;
end tag_arc;
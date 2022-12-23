LIBRARY ieee; 
USE ieee.std_logic_1164.all; 
USE ieee.numeric_std.all; 

LIBRARY work;
USE work.design_package.all;

entity input_divider is
    port(
        clk: in std_logic;
        uart_in:in std_logic_vector(total_l-1 downto 0);
        load_in: in std_logic;
        key_nonce: out std_logic_vector(key_l+nonce_l-1 downto 0);
        ad: out std_logic_vector(ad_l-1 downto 0);
        tag: out std_logic_vector(tag_l-1 downto 0);
        o_text: out std_logic_vector(text_l-1 downto 0);
        rst:in std_logic
    );
end input_divider;

architecture input_dividerarc of input_divider is
begin
    process(load_in, rst, uart_in)
    begin
    if (rst='1') then
        key_nonce<=(key_l+nonce_l-1 downto 0 =>'0');
        ad<=(ad_l-1 downto 0=>'0');
        tag<=(tag_l-1 downto 0=>'0');
        o_text<=(text_l-1 downto 0=>'0');
    elsif (clk'event and clk='1') then
        if (load_in ='1') then
            key_nonce<=uart_in(287 downto 176);
            ad<=uart_in(175 downto  144);
            tag<=uart_in(143 downto 96);
            o_text<=uart_in(95 downto 0);
        end if;
    end if;
    end process;
end input_dividerarc;
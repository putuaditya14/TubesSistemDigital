LIBRARY ieee; 
USE ieee.std_logic_1164.all; 
USE ieee.numeric_std.all; 

LIBRARY work;
USE work.design_package.all;

entity crypt is
    port(
        text_in:in std_logic_vector(text_l-1 downto 0);
        out_text: out std_logic_vector(text_l-1 downto 0);
        out_phase: out std_logic;
        state_in: in std_logic_vector(383 downto 0);
        out_state: out std_logic_vector(383 downto 0);
        enc_mode: in std_logic
    );
end crypt;

architecture crypt_arc of crypt is
signal curr_text: std_logic_vector(text_l-1 downto 0);
signal curr_state:std_logic_vector(383 downto 0);
signal i: integer;
begin
    process(text_in, state_in, enc_mode)
    begin
    i<=0;
    curr_state<=state_in;
    if (enc_mode='1') then --encrypt
            curr_text(text_l-1 downto 0)<= text_in(text_l-1 downto 0) XOR up_string(text_l, x"80", curr_state);
            curr_state<=up_state(x"80", curr_state);
            curr_state<=down_func(text_in(text_l-1 downto 0)&(rkin-1-text_l downto 0 => '0'), text_l, x"00", curr_state);
    else
            curr_text(text_l-1 downto 0)<= text_in(text_l-1 downto 0) XOR up_string(text_l, x"80", curr_state);
            curr_state<=up_state(x"80", curr_state);
            curr_state<=down_func(curr_text(text_l-1 downto 0)&(rkin-1-text_l downto 0 => '0'), text_l, x"00", curr_state);
    end if;
    out_state<=curr_state;
    out_text<=curr_text;
    out_phase<='0';
    end process;
end crypt_arc;
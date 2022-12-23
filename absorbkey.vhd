LIBRARY ieee; 
USE ieee.std_logic_1164.all; 
USE ieee.numeric_std.all; 

LIBRARY work;
USE work.design_package.all;

entity absorbkey is
    port(
        key_nonce: in std_logic_vector(key_l+nonce_l-1 downto 0);
        state_in: in std_logic_vector(383 downto 0);
        phase_in: in std_logic;
        out_phase: out std_logic;
        out_state: out std_logic_vector(383 downto 0)
    );
end absorbkey;

architecture absorbkey_arc of absorbkey is
signal curr_state:std_logic_vector(383 downto 0);
signal curr_phase: std_logic;
signal appended_string:std_logic_vector(key_l+nonce_l+7 downto 0):=(key_nonce & x"06");
begin
    process(state_in, key_nonce, phase_in)
    begin
    curr_state<=state_in;
    curr_phase<=phase_in;
    if (curr_phase/='1') then
        curr_phase<= '1';
        curr_state<=up_state(c_absorbkey, curr_state);
    end if;
    curr_state<=down_func(appended_string & (rkin-key_l-nonce_l-9 downto 0 => '0'),key_l+nonce_l+8 ,c_absorbkey, curr_state);
    curr_phase<='0';
    out_state<=curr_state;
    out_phase<=curr_phase;
    end process;
end absorbkey_arc;
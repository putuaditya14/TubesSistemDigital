LIBRARY ieee; 
USE ieee.std_logic_1164.all; 
USE ieee.numeric_std.all; 

LIBRARY work;
USE work.design_package.all;

entity squeeze is
    port(
        state_in:in std_logic_vector(383 downto 0);
        tag: out std_logic_vector(tag_l-1 downto 0);
        out_state: out std_logic_vector(383 downto 0);
        out_phase : out std_logic;
        input_tag: in std_logic_vector(tag_l-1 downto 0);
        tag_match: out std_logic
    );
end squeeze;

architecture squeeze_arc of squeeze is
signal curr_state: std_logic_vector(383 downto 0);
signal new_tag: std_logic_vector(tag_l-1 downto 0);
begin
    process(state_in)
    begin
        curr_state<=state_in;
        new_tag<=up_string(tag_l, x"40",curr_state);
        tag<=new_tag;
        curr_state<=up_state(x"40",curr_state);
        out_phase<='1';
        out_state<=curr_state;
        if (new_tag=input_tag) then
            tag_match<='1';
        else
            tag_match<='0';
        end if;
    end process;
end squeeze_arc;
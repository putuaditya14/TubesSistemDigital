LIBRARY ieee; 
USE ieee.std_logic_1164.all; 
USE ieee.numeric_std.all; 

LIBRARY work;
USE work.design_package.all;

entity absorb is
    port(
        ad:in std_logic_vector(ad_l-1 downto 0);
        phase_in: in std_logic;
        state_in: in std_logic_vector(383 downto 0);
        out_state: out std_logic_vector(383 downto 0);
        out_phase: out std_logic
    );
end absorb;

architecture absorb_arc of absorb is
signal curr_state:std_logic_vector(383 downto 0);
signal curr_phase: std_logic;

begin
    process(state_in, ad, phase_in)
    begin
    curr_state<=state_in;
    curr_phase<=phase_in;
    if (curr_phase/='1') then
        curr_phase<= '1';
        curr_state<=up_state(c_absorb, curr_state);
    end if;
    curr_state<=down_func(ad & (rkin-1-ad_l downto 0 =>'0'), ad_l, c_absorb, curr_state);
    curr_phase<='0';
    out_state<=curr_state;
    out_phase<=curr_phase;
    end process;

end absorb_arc;
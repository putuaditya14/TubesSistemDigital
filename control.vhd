LIBRARY ieee; 
USE ieee.std_logic_1164.all; 
USE ieee.numeric_std.all; 

LIBRARY work;
USE work.design_package.all;

entity control is
    port(
        rst, clk, go: in std_logic;
        mux_sel: out std_logic_vector(1 downto 0);
        load_input, load_state, load_phase, load_tag, load_text: out std_logic
    );
end control;

architecture rtl of control is
type states is (init, s0, s1, s2, s3, s4, s5);
signal next_s, curr_s: states;
begin
    process (clk, rst)
    begin
    if (rst='1') then
        curr_s<=init;
    elsif (clk'event and clk='1') then
        curr_s<=next_s;
    end if;
    end process;

    process (curr_s, go)
    begin
        case curr_s is
            when init => 
                if (go='1') then
                    next_s<=s0;
                else
                    next_s<=init;
                end if;
            
            when s0 =>
                load_input<='1';
                load_state<='0';
                load_phase<='0';
                load_tag<='0';
                load_text<='0';
                mux_sel<="00";
                next_s<=s1;
            
            when s1 =>
                load_input<='0';
                load_state<='1';
                load_phase<='1';
                load_tag<='0';
                load_text<='0';
                mux_sel<="00";
                next_s<=s2;
            
            when s2 =>
                load_input<='0';
                load_state<='1';
                load_phase<='1';
                load_tag<='0';
                load_text<='0';
                mux_sel<="01";
                next_s<=s3;
                
            when s3 =>
                load_input<='0';
                load_state<='1';
                load_phase<='1';
                load_tag<='0';
                load_text<='1';
                mux_sel<="10";
                next_s<=s4;

            when s4 =>
                load_input<='0';
                load_state<='1';
                load_phase<='1';
                load_tag<='1';
                load_text<='0';
                mux_sel<="11";
                next_s<=s5;

            when s5 =>
                load_input<='0';
                load_state<='0';
                load_phase<='0';
                load_tag<='0';
                load_text<='0';
                mux_sel<="00";
                next_s<=s5;
                
            when others=>
                next_s<=init;
        end case;
        end process;
end architecture rtl;
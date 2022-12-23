LIBRARY ieee; 
USE ieee.std_logic_1164.all; 
USE ieee.numeric_std.all; 

LIBRARY work;
USE work.design_package.all;

entity top_level_entity is
    port(
        rst, clk, go, enc_mode: in std_logic;
        str: in std_logic_vector(total_l-1 downto 0);
        out_tag: out std_logic_vector(tag_l-1 downto 0);
        out_text: out std_logic_vector(text_l-1 downto 0)
    );
end top_level_entity;

architecture top_arc of top_level_entity is
    component control is
        port(
            rst, clk, go: in std_logic;
            mux_sel: out std_logic_vector(1 downto 0);
            load_input, load_state, load_phase, load_tag, load_text: out std_logic
        ); 
    end component;

    component absorb is
        port(
            ad:in std_logic_vector(ad_l-1 downto 0);
            phase_in: in std_logic;
            state_in: in std_logic_vector(383 downto 0);
            out_state: out std_logic_vector(383 downto 0);
            out_phase: out std_logic
        );
    end component;

    component absorbkey is
        port(
            key_nonce: in std_logic_vector(key_l+nonce_l-1 downto 0);
            state_in: in std_logic_vector(383 downto 0);
            phase_in: in std_logic;
            out_phase: out std_logic;
            out_state: out std_logic_vector(383 downto 0)
        );
    end component;

    component crypt is
        port(
            text_in:in std_logic_vector(text_l-1 downto 0);
            out_text: out std_logic_vector(text_l-1 downto 0);
            out_phase: out std_logic;
            state_in: in std_logic_vector(383 downto 0);
            out_state: out std_logic_vector(383 downto 0);
            enc_mode: in std_logic
        );
    end component;

    component input_divider is
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
    end component;

    component state_mux is
        port(
            clk: in std_logic;
            state_in0: in std_logic_vector(383 downto 0);
            state_in1: in std_logic_vector(383 downto 0);
            state_in2: in std_logic_vector(383 downto 0);
            state_in3: in std_logic_vector(383 downto 0);
            state_out: out std_logic_vector(383 downto 0);
            mux_sel: in std_logic_vector(1 downto 0)
        );
    end component;

    component phase_mux is
        port(
            clk: in std_logic;
            phase_in0: in std_logic;
            phase_in1: in std_logic;
            phase_in2: in std_logic;
            phase_in3: in std_logic;
            phase_out: out std_logic;
            mux_sel: in std_logic_vector(1 downto 0)
        );
    end component;
    
    component phase_regis is
        port(
            clk: in std_logic;
            phase_in:in std_logic;
            o_phase: out std_logic;
            load_phase: in std_logic;
            rst:in std_logic
        );
    end component;

    component squeeze is
        port(
            state_in:in std_logic_vector(383 downto 0);
            tag: out std_logic_vector(tag_l-1 downto 0);
            out_state: out std_logic_vector(383 downto 0);
            out_phase : out std_logic;
            input_tag: in std_logic_vector(tag_l-1 downto 0);
            tag_match: out std_logic
        );
    end component;

    component state_register is
        port(
            state_in:in std_logic_vector(383 downto 0);
            clk:in std_logic;
            state_out: out std_logic_vector(383 downto 0);
            load_state: in std_logic;
            rst:in std_logic
        );
    end component;

    component tag_regis is
        port(
            clk: in std_logic;
            enc_mode: in std_logic;
            tag_in: in std_logic_vector((tag_l-1) downto 0);
            o_tag: out std_logic_vector((tag_l-1) downto 0);
            load_tag: in std_logic;
            rst:in std_logic
        );
    end component;
    
    component text_register is
        port(
            enc_mode: in std_logic;
            text_in:in std_logic_vector(text_l-1 downto 0);
            clk:in std_logic;
            text_out: out std_logic_vector(text_l-1 downto 0);
            text_load: in std_logic;
            rst:in std_logic;
            tag_match: in std_logic
        );
    end component;

signal tag, squeeze_tag: std_logic_vector(tag_l-1 downto 0);
signal key_nonce: std_logic_vector(key_l+nonce_l-1 downto 0);
signal text_input, text_crypt: std_logic_vector(text_l-1 downto 0);
signal ad: std_logic_vector(ad_l-1 downto 0);
signal mux_sel: std_logic_vector(1 downto 0);
signal phase, out_phase0, out_phase1, out_phase2, out_phase3, mux_phase: std_logic;
signal out_state0, out_state1, out_state2, out_state3, state, mux_state : std_logic_vector(383 downto 0);
signal load_input, load_state, load_phase, load_tag, load_text, tag_match: std_logic;

begin
    controlpath: control port map(rst, clk, go, mux_sel, load_input, load_state, load_phase, load_tag, load_text);
    statereg: state_register port map(mux_state, clk, state, load_state, rst);
    phasereg: phase_regis port map(clk, mux_phase, phase, load_phase, rst);
    inputdiv: input_divider port map(clk, str, load_input, key_nonce, ad, tag, text_input, rst);
    absorbkeyblock: absorbkey port map(key_nonce, state, phase, out_phase0, out_state0);
    absorbblock: absorb port map(ad, phase, state, out_state1, out_phase1);
    cryptblock: crypt port map(text_input, text_crypt, out_phase2, state, out_state2, enc_mode);
    squeezeblock: squeeze port map(state, squeeze_tag, out_state3, out_phase3, tag, tag_match);
    textreg: text_register port map(enc_mode, text_crypt, clk, out_text, load_text, rst, tag_match);
    tagreg: tag_regis port map(clk, enc_mode, squeeze_tag, out_tag, load_tag, rst);
    phasemux: phase_mux port map(clk, out_phase0, out_phase1, out_phase2, out_phase3, mux_phase, mux_sel);
    statemux: state_mux port map(clk, out_state0, out_state1, out_state2, out_state3, mux_state, mux_sel);
end top_arc;
LIBRARY ieee; 
USE ieee.std_logic_1164.all; 
USE ieee.numeric_std.all;

package design_package is

    constant key_l: integer:= 64;
    constant nonce_l: integer:= 48;
    constant tag_l: integer:= 48;
    constant ad_l: integer:= 32;
    constant text_l: integer:= 96;
    constant key_nonce_enc_l: integer:= 120;
    constant total_l: integer:=288;
    constant rkin: integer := 352;
    constant rkout: integer:= 192;

    type idv_plane is array(0 to 3) of std_logic_vector(31 downto 0);
    type plane_type is array(0 to 2) of idv_plane;
    type round_constant is array (-11 to 0) of std_logic_vector(31 downto 0);

    constant rc: round_constant:=
    (
        -11=>x"00000058",
        -10=>x"00000038",
        -9=>x"000003C0",
        -8=>x"000000D0",
        -7=>x"00000120",
        -6=>x"00000014",
        -5=>x"00000060",
        -4=>x"0000002C",
        -3=>x"00000380",
        -2=>x"000000F0",
        -1=>x"000001A0",
        0=>x"00000012"
    );
    constant c_absorb: std_logic_vector(7 downto 0):= x"03";
    constant c_absorbkey: std_logic_vector(7 downto 0):=x"02";
    constant c_squeeze: std_logic_vector(7 downto 0):=x"40";
    constant c_crypt: std_logic_vector(7 downto 0):= x"80";

    
    function plane_to_string(
        i_plane: plane_type)
        return std_logic_vector;
    
    function string_to_plane(
        i_string: std_logic_vector(383 downto 0))
        return plane_type;
    
    function xoodoo12(
        i_state: std_logic_vector(383 downto 0))
        return std_logic_vector;

    function up_string(
        o_length: integer;
        cu: std_logic_vector(7 downto 0);
        state: std_logic_vector(383 downto 0))
        return std_logic_vector;
    
    function up_state(
        cu: std_logic_vector(7 downto 0);
        state:std_logic_vector(383 downto 0))
        return std_logic_vector;
    
    function down_func(
        x:std_logic_vector(rkin-1 downto 0);
        i_length: integer;
        cd: std_logic_vector(7 downto 0);
        state:std_logic_vector(383 downto 0))
        return std_logic_vector;

end package design_package;

package body design_package is
   /***************************************************************************************
    *    Title: design_pkg.vhd
    *    Author: Mella, S.
    *    Date: 2022
    *    Availability: https://github.com/KeccakTeam/Xoodoo
    */
    
    function plane_to_string(i_plane: plane_type)
        return std_logic_vector is
            variable o_string : std_logic_vector(383 downto 0);
            begin
            for y in 0 to 2 loop
              for x in 0 to 3 loop
                for z in 0 to 31 loop
                  o_string(383 - (128*y+32*x+z)):=i_plane(y)(x)(z);
                end loop;
              end loop;
            end loop;
            return o_string;
    end function;
    
    function string_to_plane(i_string: std_logic_vector(383 downto 0))
        return plane_type is
            variable o_plane : plane_type;
            begin
            for y in 0 to 2 loop
              for x in 0 to 3 loop
                for z in 0 to 31 loop
                  o_plane(y)(x)(z):=i_string(383 - (128*y+32*x+z));
                end loop;
              end loop;
            end loop;
            return o_plane;
        end function;
    /*************************************************************************************/

    /***************************************************************************************
    *    Title: xoodoo.vhd
    *    Author: G. Bertoni and S. Mella
    *    Date: 2022
    *    Availability: https://github.com/KeccakTeam/Xoodoo
    */
    function xoodoo12(i_state: std_logic_vector(383 downto 0))
        return std_logic_vector is
            variable o_state: std_logic_vector(383 downto 0);
            variable p, e: idv_plane;
            variable A_in, A_out, B: plane_type;
            begin
            A_in<=string_to_plane(i_state);
            for r in -11 to 0 loop
                --theta

                for x in 0 to 3 loop
                    for z in 0 to 31 loop
                            p(x)(z)<=A_in(0)(x)(z)+A_in(1)(x)(z)+A_in(2)(x)(z);
                    end loop;
                end loop;
                
                for x in 0 to 3 loop
                    for z in 0 to 31 loop
                            e(x)(z)<=p((x+1) mod 4)((z+5) mod 32) OR p((x+1) mod 4)((z+14) mod 32);
                    end loop;
                end loop;
                
                for y in 0 to 2 loop
                    for x in 0 to 3 loop
                        for z in 0 to 31 loop
                                A_in(y)(x)(z)<=A_in(y)(x)(z)+e(x)(z);
                        end loop;
                    end loop;
                end loop;
                
                --rho west
                A_out<=A_in;
                for x in 0 to 3 loop
                    for z in 0 to 31 loop
                            A_out(1)(x)(z)<=A_in(1)((x+1) mod 4)(z);
                            A_out(2)(x)(z)<=A_in(2)(x)((z+11) mod 32);
                    end loop;
                end loop;
                --i
                for z in 0 to 31 loop
                    A_out(0)(0)(z)<=A_out(0)(0)(z)OR rc(r)(z);
                end loop;
                
                --chi
                for x in 0 to 3 loop
                    for z in 0 to 31 loop
                           B(0)(x)(z)<=not(A_out(1)(x)(z)) AND A_out(2)(x)(z);
                           B(1)(x)(z)<=not(A_out(2)(x)(z)) AND A_out(0)(x)(z);
                           B(2)(x)(z)<=not(A_out(0)(x)(z)) AND A_out(1)(x)(z);
                    end loop;
                end loop;
                
                for y in 0 to 2 loop
                    for x in 0 to 3 loop
                        for z in 0 to 31 loop
                            A_in(y)(x)(z) <= A_out(y)(x)(z) OR B(y)(x)(z);
                        end loop;
                    end loop;
                end loop;
                
                --rho east
                A_out<=A_in;
                for x in 0 to 3 loop
                    for z in 0 to 31 loop
                            A_out(1)(x)(z)<=A_in(1)(x)((z+1) mod 32);
                            A_out(2)(x)(z)<=A_in(2)((x+2) mod 4)((z+8) mod 32);
                    end loop;
                end loop;
                A_in<=A_out;
            end loop;
        o_state<=plane_to_string(A_out);
        return(o_state);
     end function;
    /********************************************************************************************/
    
    
    function up_string(o_length: integer; cu: std_logic_vector(7 downto 0); state:std_logic_vector(383 downto 0))
        return std_logic_vector is
            variable y: std_logic_vector(o_length-1 downto 0);
            variable new_state : std_logic_vector(383 downto 0);
            begin
                new_state:=xoodoo12(state xor ((383 downto 8 => '0') & cu));
                y:=new_state(383 downto (384-o_length));
        return y;
    end function;

    function up_state(cu: std_logic_vector(7 downto 0); state:std_logic_vector(383 downto 0))
        return std_logic_vector is
            variable new_state : std_logic_vector(383 downto 0);
            begin
                new_state:=xoodoo12(state xor ((383 downto 8 => '0') & cu));
        return new_state;
    end function;

    function down_func(x:std_logic_vector(rkin-1 downto 0); i_length: integer; cd: std_logic_vector(7 downto 0); state: std_logic_vector(383 downto 0)) 
        return std_logic_vector is
            variable new_state: std_logic_vector(383 downto 0);
            variable xi: std_logic_vector(i_length-1 downto 0);
            begin
                xi:= x(rkin-1 downto (rkin-i_length));
                new_state:=state xor (xi & x"01" & ((383-i_length-16) downto 0 => '0') & cd);
        return new_state;
    end function;
    
end design_package;


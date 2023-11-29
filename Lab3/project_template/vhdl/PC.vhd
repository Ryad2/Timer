library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PC is
    port(
        clk          : in  std_logic;
        reset_n      : in  std_logic;
        en           : in  std_logic;
        sel_a        : in  std_logic;
        sel_imm      : in  std_logic;
        sel_ihandler : in  std_logic;
        add_imm      : in  std_logic;
        imm          : in  std_logic_vector(15 downto 0);
        a            : in  std_logic_vector(15 downto 0);
        addr         : out std_logic_vector(31 downto 0)
    );
end PC;

architecture synth of PC is
    
    signal curr_addr : std_logic_vector(15 downto 0) := (others => '0');
    signal next_addr : std_logic_vector(15 downto 0) := (others => '0');
    signal mux_in0 : std_logic_vector(15 downto 0) := (others => '0');
    signal mux_in1 : std_logic_vector(15 downto 0) := (others => '0');
    constant handler_addr : std_logic_vector(15 downto 0) := "0000000000000100";

begin
    
    addr(31 downto 16) <= (others => '0');
    addr(15 downto 0) <= curr_addr;

    process (clk, reset_n)
    begin

        if reset_n = '0' then
            -- async reset
            curr_addr <= (others => '0');

        elsif rising_edge (clk) and en = '1' then
            -- address new value
            curr_addr <= next_addr;
            
        end if;

    end process;

    mux_in0 <= std_logic_vector(unsigned(curr_addr) + unsigned(imm)) when add_imm = '1'
        else std_logic_vector(unsigned(curr_addr) + 4);

    mux_in1 <= a(15 downto 2) & "00" when sel_a = '1'
        else imm(13 downto 0) & "00" when sel_imm = '1'
        else handler_addr when sel_ihandler = '1'
        else mux_in0;
    
    next_addr <= mux_in1 when (sel_a = '1' or sel_imm = '1' or sel_ihandler = '1') else mux_in0;
    
end synth;

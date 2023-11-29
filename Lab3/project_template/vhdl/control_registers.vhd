library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control_registers is
    port(
        clk       : in  std_logic;
        reset_n   : in  std_logic;
        write_n   : in  std_logic;
        backup_n  : in  std_logic;
        restore_n : in  std_logic;
        address   : in  std_logic_vector(2 downto 0);
        irq       : in  std_logic_vector(31 downto 0);
        wrdata    : in  std_logic_vector(31 downto 0);

        ipending  : out std_logic;
        rddata    : out std_logic_vector(31 downto 0)
    );
end control_registers;

architecture synth of control_registers is
    
    signal  s_PIE  : std_logic := '0';
    signal  s_EPIE : std_logic := '0';
    signal  s_ienable : std_logic_vector(31 downto 0) := (others => '0');
    signal  s_ipending : std_logic_vector(31 downto 0) := (others => '0');

begin

    process(clk, reset_n)
    begin
        
        if reset_n = '0' then
            -- async reset
            s_PIE <= '0';
            s_EPIE <= '0';
            s_ienable <= (others => '0');

        elsif rising_edge(clk) then
            -- write
            if write_n = '0' then
                if address = "000" then
                    s_PIE <= wrdata(0);
                elsif address = "011" then
                    s_ienable <= wrdata;
                end if;
            -- backup
            elsif backup_n = '0' then
                s_EPIE <= s_PIE;
                s_PIE <= '0';
            -- restore
            elsif restore_n = '0' then
                s_PIE <= s_EPIE; 
            end if;
            
        end if;
    end process;

    -- async read
    rddata <= 
        "000" & X"000_0000" & s_PIE when address = "000"
        else "000" & X"000_0000" & s_EPIE when address = "001"
        else s_ienable when address = "011"
        else s_ipending when address = "100"
        else (others => '0');

    s_ipending <= irq and s_ienable; 

    ipending <= '1' when (s_PIE = '1' and not (s_ipending = x"0000_0000")) else '0';

end synth;  

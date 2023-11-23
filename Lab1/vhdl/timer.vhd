library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity timer is
    port(
        -- bus interface
        clk     : in  std_logic;
        reset_n : in  std_logic;
        cs      : in  std_logic;
        read    : in  std_logic;
        write   : in  std_logic;
        address : in  std_logic_vector(1 downto 0);
        wrdata  : in  std_logic_vector(31 downto 0);

        irq     : out std_logic;
        rddata  : out std_logic_vector(31 downto 0)
    );
end timer;

architecture synth of timer is

    signal counter : unsigned(31 downto 0) := (others => '0');
    signal period : std_logic_vector(31 downto 0) := (others => '0');
    signal control : std_logic_vector(31 downto 0) := (others => '0');
    signal CONT : std_logic := '0';
    signal ITO : std_logic := '0';
    signal status : std_logic_vector(31 downto 0) := (others => '0');
    signal RUN : std_logic := '0';
    signal TOb : std_logic := '0';

    signal s_read : std_logic := '0';
    signal s_cs : std_logic := '0';
    signal s_address : std_logic_vector(1 downto 0) := (others => '0');
    
begin

    -- write
    process(clk, reset_n)
    begin
        -- async reset
        if reset_n = '0' then
            
            counter <= (others => '0');
            period <= (others => '0');
            CONT <= '0';
            ITO <= '0';
            RUN <= '0';
            TOb <= '0';

        elsif rising_edge(clk) then

            -- count
            if RUN = '1' then
                if counter = 0 then
                    TOb <= '1';
                    counter <= unsigned(period);
                    RUN <= CONT;
                else
                    counter <= counter - 1;
                end if;
            end if;

            -- read delay
            s_read <= read;
            s_cs <= cs;
            s_address <= address;

            -- write
            if cs = '1' and write = '1' then
                    -- period write
                if address = "01" then
                    RUN <= '0';
                    period <= wrdata;
                    counter <= unsigned(wrdata);
                -- control write
                elsif address = "10" then
                    CONT <= wrdata(0);
                    ITO <= wrdata(1);
                    if RUN = '0' and wrdata(3) = '1' then
                        RUN <= '1';
                    end if;
                    if RUN = '1' and wrdata(2) = '1' then
                        RUN <= '0';
                    end if;
                -- status write
                elsif address = "11" and wrdata(1) = '0' then
                    TOb <= '0';
                end if;
            end if;

        end if;
    end process;

    control(0) <= CONT;
    control(1) <= ITO;
    status(1) <= TOb;
    status(0) <= RUN;

    irq <= TOb and ITO;

    -- read
    rddata <= 
        std_logic_vector(counter) when (s_cs = '1' and s_read = '1' and s_address = "00") else
        period when (s_cs = '1' and s_read = '1' and s_address = "01") else
        control when (s_cs = '1' and s_read = '1' and s_address = "10") else
        status when (s_cs = '1' and s_read = '1' and s_address = "11") else
        (others => 'Z');

end synth;

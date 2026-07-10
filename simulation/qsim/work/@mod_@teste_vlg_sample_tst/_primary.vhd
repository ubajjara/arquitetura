library verilog;
use verilog.vl_types.all;
entity Mod_Teste_vlg_sample_tst is
    port(
        CLOCK_27        : in     vl_logic;
        CLOCK_50        : in     vl_logic;
        GPIO_0          : in     vl_logic_vector(35 downto 0);
        GPIO_1          : in     vl_logic_vector(35 downto 0);
        KEY             : in     vl_logic_vector(3 downto 0);
        LCD_DATA        : in     vl_logic_vector(7 downto 0);
        SW              : in     vl_logic_vector(17 downto 0);
        UART_RXD        : in     vl_logic;
        sampler_tx      : out    vl_logic
    );
end Mod_Teste_vlg_sample_tst;

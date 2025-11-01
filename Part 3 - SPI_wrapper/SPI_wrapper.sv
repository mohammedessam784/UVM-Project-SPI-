module WRAPPER (SPI_wrapper_if.DUT SPI_wrapperif);

wire MOSI, SS_n, clk, rst_n;
wire MISO;

assign SPI_wrapperif.MISO = MISO;

assign MOSI = SPI_wrapperif.MOSI;
assign SS_n = SPI_wrapperif.SS_n;
assign clk = SPI_wrapperif.clk;
assign rst_n = SPI_wrapperif.rst_n;

wire [9:0] rx_data_din;
wire       rx_valid;
wire       tx_valid;
wire [7:0] tx_data_dout;

RAM_   RAM_instance   (rx_data_din,clk,rst_n,rx_valid,tx_data_dout,tx_valid);
SLAVE SLAVE_instance (MOSI,MISO,SS_n,clk,rst_n,rx_data_din,rx_valid,tx_data_dout,tx_valid);
`ifdef SIM
reset_a :assert property (@(posedge SPI_wrapperif.clk) !SPI_wrapperif.rst_n |-> 
  ##1 !SPI_wrapperif.MISO && !rx_valid &&rx_valid==0);

`endif  // SIM
endmodule
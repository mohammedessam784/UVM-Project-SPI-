module WRAPPER_Golden (SPI_wrapper_if.REF SPI_wrapperif);

wire MOSI, SS_n, clk, rst_n;
wire MISO;

assign SPI_wrapperif.MISO_ref = MISO;

assign MOSI = SPI_wrapperif.MOSI;
assign SS_n = SPI_wrapperif.SS_n;
assign clk = SPI_wrapperif.clk;
assign rst_n = SPI_wrapperif.rst_n;

wire [9:0] rx_data_din;
wire       rx_valid;
wire       tx_valid;
wire [7:0] tx_data_dout;

RAM_ref   RAM_inst   (rx_data_din,clk,rst_n,rx_valid,tx_data_dout,tx_valid);
SPI_Slave_Golden SLAVE_inst(MOSI,MISO,SS_n,clk,rst_n,rx_data_din,rx_valid,tx_data_dout,tx_valid);

endmodule
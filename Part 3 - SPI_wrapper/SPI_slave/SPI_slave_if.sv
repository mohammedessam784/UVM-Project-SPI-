interface SPI_slave_if (input bit clk);
  // TODO: Replace/add signals to match your DUT interface.
logic           MOSI,  rst_n, SS_n, tx_valid;
logic     [7:0] tx_data;
logic     [9:0] rx_data;
 bit [9:0] rx_data_ref;
  bit      rx_valid_ref;
logic           rx_valid, MISO;

  
  bit      MISO_ref;

  modport DUT (
    input clk,  MOSI,  rst_n, SS_n, tx_valid,tx_data,
    output rx_data,rx_valid, MISO
  );
  modport REF (
    input clk,  MOSI,  rst_n, SS_n, tx_valid,tx_data,
    output rx_data_ref,rx_valid_ref, MISO_ref
  );


endinterface : SPI_slave_if
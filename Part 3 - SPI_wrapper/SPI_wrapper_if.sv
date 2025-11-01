interface SPI_wrapper_if (input logic clk);
  // TODO: Replace/add signals to match your DUT interface.

bit MOSI, SS_n, rst_n;
bit MISO;
bit MISO_ref;

  modport DUT (
    input clk,
    input rst_n,
    input SS_n,
    input MOSI,
    output MISO
  );
  modport REF (
    input clk,
    input rst_n,
    input SS_n,
    input MOSI,
    output MISO_ref
  );

endinterface : SPI_wrapper_if
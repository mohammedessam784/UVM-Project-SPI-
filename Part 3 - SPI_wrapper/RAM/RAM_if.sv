interface RAM_if (input logic clk);
  // TODO: Replace/add signals to match your DUT interface.
  logic [9:0] din;
  logic  rst_n, rx_valid;
  bit [7:0] dout;
  bit tx_valid;
  bit [7:0] dout_ref;
  bit tx_valid_ref;
  modport DUT (
    input clk,
    input rst_n,
    input rx_valid,
    input din,
    output dout,
    output tx_valid
  );

  modport REF (
    input clk,
    input rst_n,
    input rx_valid,
    input din,
    output dout_ref,
    output tx_valid_ref
  );


endinterface : RAM_if
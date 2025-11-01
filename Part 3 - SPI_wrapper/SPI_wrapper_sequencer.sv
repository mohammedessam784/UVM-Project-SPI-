package SPI_wrapper_sequencer_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import SPI_wrapper_seq_item_pkg::*;

  class SPI_wrapper_sequencer extends uvm_sequencer#(SPI_wrapper_seq_item);
    `uvm_component_utils(SPI_wrapper_sequencer)
    function new(string name = "SPI_wrapper_sequencer", uvm_component parent = null);
      super.new(name, parent);
    endfunction
  endclass

endpackage : SPI_wrapper_sequencer_pkg
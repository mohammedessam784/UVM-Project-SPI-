package SPI_slave_rst_seq_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import SPI_slave_seq_item_pkg::*;

  class SPI_slave_rst_seq extends uvm_sequence #(SPI_slave_seq_item);
    `uvm_object_utils(SPI_slave_rst_seq)

    function new(string name = "SPI_slave_rst_seq");
      super.new(name);
    endfunction

    task body;
      SPI_slave_seq_item tx = SPI_slave_seq_item::type_id::create("tx");
      start_item(tx);
        tx.rst_n = 0;
      finish_item(tx);
      // TODO: allow DUT to settle after reset
    endtask

  endclass : SPI_slave_rst_seq

endpackage : SPI_slave_rst_seq_pkg
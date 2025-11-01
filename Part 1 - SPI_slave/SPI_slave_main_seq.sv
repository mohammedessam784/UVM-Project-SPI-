package SPI_slave_main_seq_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import SPI_slave_seq_item_pkg::*;

  class SPI_slave_main_seq extends uvm_sequence #(SPI_slave_seq_item);
    `uvm_object_utils(SPI_slave_main_seq)

    function new(string name = "SPI_slave_main_seq");
      super.new(name);
    endfunction

    task body;
      SPI_slave_seq_item tx;
      repeat (1000) begin
        tx = SPI_slave_seq_item::type_id::create("tx");
        start_item(tx);
        assert(tx.randomize()) else `uvm_fatal("RANDOMIZE_FAIL","randomization failed");
        finish_item(tx);
      end
    endtask
  endclass : SPI_slave_main_seq

endpackage : SPI_slave_main_seq_pkg

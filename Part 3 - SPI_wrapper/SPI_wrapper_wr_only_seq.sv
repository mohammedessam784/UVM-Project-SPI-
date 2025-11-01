package SPI_wrapper_wr_only_seq_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import SPI_wrapper_seq_item_pkg::*;

  class SPI_wrapper_wr_only_seq extends uvm_sequence #(SPI_wrapper_seq_item);
    `uvm_object_utils(SPI_wrapper_wr_only_seq)
     SPI_wrapper_seq_item tx;
    function new(string name = "SPI_wrapper_wr_only_seq");
      super.new(name);
    endfunction

    task body;
     
      repeat (500) begin
        tx = SPI_wrapper_seq_item::type_id::create("tx");
        start_item(tx);
        tx.constraint_mode(1);
        tx.write_only_seq.constraint_mode(1);
        tx.rw_rd_seq.constraint_mode(0);
        tx.read_only_seq.constraint_mode(0);
        assert(tx.randomize()) else `uvm_fatal("RANDOMIZE_FAIL","randomization failed");
        finish_item(tx);
      end
    endtask
  endclass : SPI_wrapper_wr_only_seq

endpackage : SPI_wrapper_wr_only_seq_pkg
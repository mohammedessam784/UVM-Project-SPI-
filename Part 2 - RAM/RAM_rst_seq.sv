package RAM_rst_seq_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import RAM_seq_item_pkg::*;

  class RAM_rst_seq extends uvm_sequence #(RAM_seq_item);
    `uvm_object_utils(RAM_rst_seq)

    function new(string name = "RAM_rst_seq");
      super.new(name);
    endfunction

    task body;
      RAM_seq_item tx = RAM_seq_item::type_id::create("tx");
      start_item(tx);
      tx.rst_n    = 0; // Assert reset
      finish_item(tx);
      // TODO: allow DUT to settle after reset
    endtask

  endclass : RAM_rst_seq

endpackage : RAM_rst_seq_pkg
package RAM_driver_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import RAM_seq_item_pkg::*;
  import RAM_config_pkg::*;

  class RAM_driver extends uvm_driver#(RAM_seq_item);
    `uvm_component_utils(RAM_driver)
    virtual RAM_if vif;

    function new(string name = "RAM_driver", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
      RAM_seq_item tx;
      forever begin
        seq_item_port.get_next_item(tx);
        // TODO: Drive DUT signals using tx fields
        vif.rst_n       = tx.rst_n;
        vif.rx_valid    = tx.rx_valid;
        vif.din        = tx.din;
      
        @(negedge vif.clk);
        seq_item_port.item_done();
      end
    endtask
  endclass : RAM_driver

endpackage : RAM_driver_pkg
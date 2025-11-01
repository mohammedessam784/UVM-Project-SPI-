package SPI_wrapper_driver_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import SPI_wrapper_seq_item_pkg::*;
  import SPI_wrapper_config_pkg::*;

  class SPI_wrapper_driver extends uvm_driver#(SPI_wrapper_seq_item);
    `uvm_component_utils(SPI_wrapper_driver)
    virtual SPI_wrapper_if vif;
    SPI_wrapper_seq_item tx;

    function new(string name = "SPI_wrapper_driver", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
      
      forever begin
        seq_item_port.get_next_item(tx);
        // TODO: Drive DUT signals using tx fields
        vif.rst_n      = tx.rst_n;
        vif.SS_n       = tx.SS_n;
        vif.MOSI       = tx.MOSI;
        @(negedge vif.clk);
        seq_item_port.item_done();
      end
    endtask
  endclass : SPI_wrapper_driver

endpackage : SPI_wrapper_driver_pkg
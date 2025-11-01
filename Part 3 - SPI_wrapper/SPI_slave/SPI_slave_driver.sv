package SPI_slave_driver_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import SPI_slave_seq_item_pkg::*;
  import SPI_slave_config_pkg::*;

  class SPI_slave_driver extends uvm_driver#(SPI_slave_seq_item);
    `uvm_component_utils(SPI_slave_driver)
    virtual SPI_slave_if vif;
     SPI_slave_seq_item tx;
    function new(string name = "SPI_slave_driver", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
      
      forever begin
         tx = SPI_slave_seq_item::type_id::create("tx");
        seq_item_port.get_next_item(tx);
        // TODO: Drive DUT signals using tx fields
        vif.rst_n    = tx.rst_n;
        vif.MOSI     = tx.MOSI;
        vif.SS_n     = tx.SS_n;
        vif.tx_valid = tx.tx_valid;
        vif.tx_data  = tx.tx_data;
        @(negedge vif.clk);
        seq_item_port.item_done();
      end
    endtask
  endclass : SPI_slave_driver

endpackage : SPI_slave_driver_pkg
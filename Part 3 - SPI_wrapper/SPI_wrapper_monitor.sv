package SPI_wrapper_monitor_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import SPI_wrapper_seq_item_pkg::*;

  class SPI_wrapper_monitor extends uvm_monitor;
    `uvm_component_utils(SPI_wrapper_monitor)

    virtual SPI_wrapper_if vif;
    SPI_wrapper_seq_item tx;
    uvm_analysis_port#(SPI_wrapper_seq_item) mon_ap;

    function new(string name = "SPI_wrapper_monitor", uvm_component parent = null);
      super.new(name, parent);
    endfunction
function void build_phase(uvm_phase phase);
     super.build_phase(phase);
        mon_ap=new("mon_ap",this);
    endfunction   
    task run_phase(uvm_phase phase);
      
      forever begin
        tx = SPI_wrapper_seq_item::type_id::create("tx");
        @(negedge vif.clk);
        // TODO: sample DUT outputs and fill tx fields
        tx.MOSI       = vif.MOSI;
        tx.SS_n      = vif.SS_n;
        tx.rst_n    = vif.rst_n;
        tx.MISO      = vif.MISO;
        tx.MISO_ref  = vif.MISO_ref;
        `uvm_info("MONITOR", $sformatf("Observed: %s", tx.convert2string()), UVM_LOW)
        mon_ap.write(tx);
      end
    endtask
  endclass : SPI_wrapper_monitor

endpackage : SPI_wrapper_monitor_pkg
package SPI_slave_monitor_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import SPI_slave_seq_item_pkg::*;
  
  class SPI_slave_monitor extends uvm_monitor;
    `uvm_component_utils(SPI_slave_monitor)

    virtual SPI_slave_if vif;
    SPI_slave_seq_item tx;
    uvm_analysis_port#(SPI_slave_seq_item) mon_ap;

    function new(string name = "SPI_slave_monitor", uvm_component parent = null);
      super.new(name, parent);
    endfunction
    function void build_phase(uvm_phase phase);
     super.build_phase(phase);
        mon_ap=new("mon_ap",this);
    endfunction   
    task run_phase(uvm_phase phase);
      
     forever begin
       tx = SPI_slave_seq_item::type_id::create("tx");
       @(negedge vif.clk);
       // TODO: sample DUT outputs and fill tx fields
        tx.rst_n    = vif.rst_n   ;
        tx.MOSI     = vif.MOSI    ;
        tx.SS_n     = vif.SS_n    ;
        tx.tx_valid = vif.tx_valid;
        tx.tx_data  = vif.tx_data ;
        tx.rx_valid = vif.rx_valid;
        tx.rx_data  = vif.rx_data ;
        tx.MISO    = vif.MISO   ;

        tx.rx_valid_ref = vif.rx_valid_ref ;
        tx.rx_data_ref  = vif.rx_data_ref ;
        tx.MISO_ref    = vif.MISO_ref   ;
      
       mon_ap.write(tx);
       //`uvm_info("SEQ_ITEM", tx.convert2string(), UVM_MEDIUM)
      end
    endtask
  endclass : SPI_slave_monitor

endpackage : SPI_slave_monitor_pkg

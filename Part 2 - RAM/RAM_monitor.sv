package RAM_monitor_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import RAM_seq_item_pkg::*;

  class RAM_monitor extends uvm_monitor;
    `uvm_component_utils(RAM_monitor)

    virtual RAM_if vif;
    uvm_analysis_port#(RAM_seq_item) mon_ap;
    RAM_seq_item tx;
    function new(string name = "RAM_monitor", uvm_component parent = null);
      super.new(name, parent);
    endfunction
function void build_phase(uvm_phase phase);
     super.build_phase(phase);
        mon_ap=new("mon_ap",this);
    endfunction   
    task run_phase(uvm_phase phase);
      forever begin
        tx = RAM_seq_item::type_id::create("tx");
        @(negedge vif.clk);
        // TODO: sample DUT outputs and fill tx fields
        tx.dout     = vif.dout;
        tx.tx_valid = vif.tx_valid;
        tx.dout_ref = vif.dout_ref;
        tx.tx_valid_ref = vif.tx_valid_ref;
        tx.rst_n    = vif.rst_n;
        tx.rx_valid = vif.rx_valid;
        tx.din      = vif.din;
        `uvm_info("MONITOR", $sformatf("Observed: %s", tx.convert2string()), UVM_LOW)
        mon_ap.write(tx);
      end
    endtask
  endclass : RAM_monitor

endpackage : RAM_monitor_pkg

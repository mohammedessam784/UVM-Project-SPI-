package SPI_wrapper_agent_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import SPI_wrapper_config_pkg::*;
  import SPI_wrapper_driver_pkg::*;
  import SPI_wrapper_monitor_pkg::*;
  import SPI_wrapper_sequencer_pkg::*;
  import SPI_wrapper_seq_item_pkg::*;

  class SPI_wrapper_agent extends uvm_agent;
    `uvm_component_utils(SPI_wrapper_agent)

    SPI_wrapper_config cfg;
    SPI_wrapper_driver drv;
    SPI_wrapper_sequencer sqr;
    SPI_wrapper_monitor mon;
    uvm_analysis_port#(SPI_wrapper_seq_item) agt_ap;

    function new(string name = "SPI_wrapper_agent", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(SPI_wrapper_config)::get(this, "", "CFG", cfg))
        `uvm_fatal("CFG_NOT_FOUND", "You must set the CFG before building the agent")

      if (cfg.is_active == UVM_ACTIVE) begin
        drv = SPI_wrapper_driver::type_id::create("drv", this);
        sqr = SPI_wrapper_sequencer::type_id::create("sqr", this);
      end
      mon = SPI_wrapper_monitor::type_id::create("mon", this);
      agt_ap = new("agt_ap", this);
    endfunction

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      if (cfg.is_active == UVM_ACTIVE) begin
        drv.seq_item_port.connect(sqr.seq_item_export);
        // TODO: set driver's virtual interface
        drv.vif = cfg.SPI_wrappervif;
      end
      // TODO: connect monitor vif
      mon.vif = cfg.SPI_wrappervif;
      mon.mon_ap.connect(agt_ap);
    endfunction
  endclass : SPI_wrapper_agent

endpackage : SPI_wrapper_agent_pkg
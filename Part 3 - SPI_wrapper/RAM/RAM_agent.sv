package RAM_agent_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import RAM_config_pkg::*;
  import RAM_driver_pkg::*;
  import RAM_monitor_pkg::*;
  import RAM_sequencer_pkg::*;
  import RAM_seq_item_pkg::*;

  class RAM_agent extends uvm_agent;
    `uvm_component_utils(RAM_agent)

    RAM_config cfg;
    RAM_driver drv;
    RAM_sequencer sqr;
    RAM_monitor mon;
    uvm_analysis_port#(RAM_seq_item) agt_ap;

    function new(string name = "RAM_agent", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(RAM_config)::get(this, "", "CFG", cfg))
        `uvm_fatal("CFG_NOT_FOUND", "You must set the CFG before building the agent")

      if (cfg.is_active == UVM_ACTIVE) begin
        drv = RAM_driver::type_id::create("drv", this);
        sqr = RAM_sequencer::type_id::create("sqr", this);
      end
      mon = RAM_monitor::type_id::create("mon", this);
      agt_ap = new("agt_ap", this);
    endfunction

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      if (cfg.is_active == UVM_ACTIVE) begin
        drv.seq_item_port.connect(sqr.seq_item_export);
        // TODO: set driver's virtual interface
        drv.vif = cfg.RAMvif;
      end
      // TODO: connect monitor vif
      mon.vif = cfg.RAMvif;
      mon.mon_ap.connect(agt_ap);
    endfunction
  endclass : RAM_agent

endpackage : RAM_agent_pkg
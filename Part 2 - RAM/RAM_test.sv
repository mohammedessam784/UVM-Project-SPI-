package RAM_test_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
import RAM_shared_pkg::*;
  import RAM_env_pkg::*;
  import RAM_agent_pkg::*;
  import RAM_config_pkg::*;

  import RAM_rst_seq_pkg::*;
  import RAM_rd_only_seq_pkg::*;
  import RAM_wr_only_seq_pkg::*;
  import RAM_wr_rd_seq_pkg::*;

  class RAM_test extends uvm_test;
    `uvm_component_utils(RAM_test)

    RAM_env env;
    RAM_config cfg;
    RAM_rst_seq rst_seq;
    RAM_rd_only_seq rd_only_seq;
    RAM_wr_only_seq wr_only_seq;
    RAM_wr_rd_seq wr_rd_seq;

    function new(string name = "RAM_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env = RAM_env::type_id::create("env", this);
      cfg = RAM_config::type_id::create("cfg");
        
      if(!uvm_config_db#(virtual RAM_if)::get(this, "", "RAM_if", cfg.RAMvif))begin
        `uvm_fatal("VIF_NOT_FOUND", "You must set the VIF before building the agent")
     end
      cfg.is_active = UVM_ACTIVE;
      uvm_config_db#(RAM_config)::set(this, "*", "CFG", cfg);
      rst_seq  = RAM_rst_seq::type_id::create("rst_seq");
     
      rd_only_seq = RAM_rd_only_seq::type_id::create("rd_only_seq");
      wr_only_seq = RAM_wr_only_seq::type_id::create("wr_only_seq");
      wr_rd_seq   = RAM_wr_rd_seq::type_id::create("wr_rd_seq");

    endfunction

    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      `uvm_info("RUN_PHASE", "Starting reset sequence", UVM_LOW)
      rst_seq.start(env.agt.sqr);

      `uvm_info("RUN_PHASE", "Starting read-only sequence", UVM_LOW)
       rd_only_seq.start(env.agt.sqr);

      `uvm_info("RUN_PHASE", "Starting write-only sequence", UVM_LOW)
      wr_only_seq.start(env.agt.sqr);

      `uvm_info("RUN_PHASE", "Starting write-read sequence", UVM_LOW)
      wr_rd_seq.start(env.agt.sqr);

      `uvm_info("RUN_PHASE", "Test finished", UVM_LOW)
      `uvm_info("RUN_PHASE", $sformatf("Errors: %0d, Correct: %0d", error_count, correct_count), UVM_LOW)
      phase.drop_objection(this);
    endtask
  endclass : RAM_test

endpackage : RAM_test_pkg
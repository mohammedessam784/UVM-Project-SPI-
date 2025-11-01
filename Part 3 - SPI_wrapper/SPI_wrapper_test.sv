package SPI_wrapper_test_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import SPI_wrapper_env_pkg::*;
  import SPI_wrapper_agent_pkg::*;
  import SPI_wrapper_config_pkg::*;
  
  import SPI_slave_env_pkg::*;
  import SPI_slave_agent_pkg::*;
  import SPI_slave_config_pkg::*;

  import RAM_env_pkg::*;
  import RAM_agent_pkg::*;
  import RAM_config_pkg::*;



  
  import SPI_wrapper_seq_item_pkg::*;
  import SPI_wrapper_wr_rd_seq_pkg::*;
  import SPI_wrapper_wr_only_seq_pkg::*;
  import SPI_wrapper_rd_only_seq_pkg::*;
  import SPI_wrapper_rst_seq_pkg::*;

  class SPI_wrapper_test extends uvm_test;
    `uvm_component_utils(SPI_wrapper_test)

    SPI_wrapper_env env;
    SPI_wrapper_config cfg;

    SPI_slave_env slave_env;
    SPI_slave_config slave_cfg;
    RAM_env ram_env;
    RAM_config ram_cfg;

    SPI_wrapper_wr_rd_seq wr_rd_seq;
    SPI_wrapper_wr_only_seq wr_only_seq;
    SPI_wrapper_rd_only_seq rd_only_seq;
    SPI_wrapper_rst_seq rst_seq;

    function new(string name = "SPI_wrapper_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env = SPI_wrapper_env::type_id::create("env", this);
      cfg = SPI_wrapper_config::type_id::create("cfg");
      slave_env = SPI_slave_env::type_id::create("slave_env", this);
      slave_cfg = SPI_slave_config::type_id::create("slave_cfg");
      ram_env = RAM_env::type_id::create("ram_env", this);
      ram_cfg = RAM_config::type_id::create("ram_cfg");
      if(!uvm_config_db#(virtual SPI_wrapper_if)::get(this, "", "SPI_wrapper_if", cfg.SPI_wrappervif))begin
        `uvm_fatal("VIF_NOT_FOUND", "You must set the VIF before building the agent")
       end
       if(!uvm_config_db#(virtual SPI_slave_if)::get(this, "", "SPI_slave_if", slave_cfg.SPI_slavevif))begin
        `uvm_fatal("VIF_NOT_FOUND", "You must set the VIF before building the agent")
       end
        if(!uvm_config_db#(virtual RAM_if)::get(this, "", "RAM_if", ram_cfg.RAMvif))begin
          `uvm_fatal("VIF_NOT_FOUND", "You must set the VIF before building the agent")
        end

       
      cfg.is_active = UVM_ACTIVE;
      slave_cfg.is_active = UVM_PASSIVE;
      ram_cfg.is_active = UVM_PASSIVE;
      uvm_config_db#(SPI_wrapper_config)::set(this, "*", "CFG", cfg);
      uvm_config_db#(SPI_slave_config)::set(this, "*", "CFG", slave_cfg);
      uvm_config_db#(RAM_config)::set(this, "*", "CFG", ram_cfg);
      rst_seq  = SPI_wrapper_rst_seq::type_id::create("rst_seq");
      wr_rd_seq = SPI_wrapper_wr_rd_seq::type_id::create("wr_rd_seq");
      wr_only_seq = SPI_wrapper_wr_only_seq::type_id::create("wr_only_seq");
      rd_only_seq = SPI_wrapper_rd_only_seq::type_id::create("rd_only_seq");
    endfunction

    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      `uvm_info("RUN_PHASE", "Starting reset sequence", UVM_LOW)
      rst_seq.start(env.agt.sqr);

      `uvm_info("RUN_PHASE", "Starting main sequence", UVM_LOW)
     
      
      wr_only_seq.start(env.agt.sqr);
      rst_seq.start(env.agt.sqr);
      rd_only_seq.start(env.agt.sqr); 
      rst_seq.start(env.agt.sqr);
      wr_rd_seq.start(env.agt.sqr);
     
      `uvm_info("RUN_PHASE", "Test finished", UVM_LOW)
      phase.drop_objection(this);
    endtask
  endclass : SPI_wrapper_test

endpackage : SPI_wrapper_test_pkg
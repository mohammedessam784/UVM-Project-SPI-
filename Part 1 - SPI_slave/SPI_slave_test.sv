package SPI_slave_test_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import SPI_slave_env_pkg::*;
  import SPI_slave_agent_pkg::*;
  import SPI_slave_config_pkg::*;
  import SPI_slave_main_seq_pkg::*;
  import SPI_slave_rst_seq_pkg::*;
  import SPI_slave_shared_pkg::*;
  class SPI_slave_test extends uvm_test;
    `uvm_component_utils(SPI_slave_test)

    SPI_slave_env env;
    SPI_slave_config cfg;
    SPI_slave_main_seq main_seq;
    SPI_slave_rst_seq rst_seq;

    function new(string name = "SPI_slave_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env = SPI_slave_env::type_id::create("env", this);
      cfg = SPI_slave_config::type_id::create("cfg");

    if(!uvm_config_db #(virtual SPI_slave_if)::get(this,"","SPI_slave_if",cfg.SPI_slavevif)) begin
     `uvm_fatal("build_phase","test - unable to get the virtual interface")
    end
      cfg.is_active = UVM_ACTIVE;
      uvm_config_db#(SPI_slave_config)::set(this, "*", "CFG", cfg);
      rst_seq  = SPI_slave_rst_seq::type_id::create("rst_seq");
      main_seq = SPI_slave_main_seq::type_id::create("main_seq");
    endfunction

    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      `uvm_info("RUN_PHASE", "Starting reset sequence", UVM_LOW)
      rst_seq.start(env.agt.sqr);

      `uvm_info("RUN_PHASE", "Starting main sequence", UVM_LOW)
       main_seq.start(env.agt.sqr);

      `uvm_info("RUN_PHASE", "Test finished", UVM_LOW)
      `uvm_info("RUN_PHASE", $sformatf("Total errors: %0d", error_count), UVM_LOW)
      `uvm_info("RUN_PHASE", $sformatf("Total correct: %0d", correct_count), UVM_LOW)
      phase.drop_objection(this);
    endtask
  endclass : SPI_slave_test

endpackage : SPI_slave_test_pkg
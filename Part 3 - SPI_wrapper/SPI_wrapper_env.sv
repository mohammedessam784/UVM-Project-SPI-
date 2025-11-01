package SPI_wrapper_env_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import SPI_wrapper_agent_pkg::*;
  import SPI_wrapper_scoreboard_pkg::*;
  import SPI_wrapper_coverage_pkg::*;

  class SPI_wrapper_env extends uvm_env;
    `uvm_component_utils(SPI_wrapper_env)
    SPI_wrapper_agent agt;
    SPI_wrapper_scoreboard sb;
    SPI_wrapper_coverage cov;

    function new(string name = "SPI_wrapper_env", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      agt = SPI_wrapper_agent::type_id::create("agt", this);
      sb  = SPI_wrapper_scoreboard::type_id::create("sb", this);
      cov = SPI_wrapper_coverage::type_id::create("cov", this);
    endfunction

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      agt.agt_ap.connect(sb.sb_export);
      agt.agt_ap.connect(cov.cov_export);
    endfunction
  endclass : SPI_wrapper_env

endpackage : SPI_wrapper_env_pkg
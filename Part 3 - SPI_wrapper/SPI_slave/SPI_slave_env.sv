package SPI_slave_env_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import SPI_slave_agent_pkg::*;
  import SPI_slave_scoreboard_pkg::*;
  import SPI_slave_coverage_pkg::*;

  class SPI_slave_env extends uvm_env;
    `uvm_component_utils(SPI_slave_env)
    SPI_slave_agent agt;
    SPI_slave_scoreboard sb;
    SPI_slave_coverage cov;

    function new(string name = "SPI_slave_env", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      agt = SPI_slave_agent::type_id::create("agt", this);
      sb  = SPI_slave_scoreboard::type_id::create("sb", this);
      cov = SPI_slave_coverage::type_id::create("cov", this);
    endfunction

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      agt.agt_ap.connect(sb.sb_export);
      agt.agt_ap.connect(cov.cov_export);
    endfunction
  endclass : SPI_slave_env

endpackage : SPI_slave_env_pkg
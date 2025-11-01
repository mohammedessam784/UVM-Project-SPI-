package SPI_wrapper_coverage_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import SPI_wrapper_seq_item_pkg::*;

  class SPI_wrapper_coverage extends uvm_component;
    `uvm_component_utils(SPI_wrapper_coverage)
    uvm_analysis_port#(SPI_wrapper_seq_item) cov_export;
    uvm_tlm_analysis_fifo#(SPI_wrapper_seq_item) cov_fifo;
    SPI_wrapper_seq_item cov_item;

    covergroup cg;

coverpoint cov_item.MOSI {
       bins low = {0};
       bins high = {1};
     }

     coverpoint cov_item.SS_n {
       bins inactive = {1};
       bins active = {0};
     }

     coverpoint cov_item.rst_n {
       bins deasserted = {1};
       bins asserted = {0};
     }

     coverpoint cov_item.MISO {
       bins low = {0};
       bins high = {1};
     }

    

      
    endgroup : cg

    function new(string name = "SPI_wrapper_coverage", uvm_component parent = null);
      super.new(name, parent);
      cg = new();
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      cov_export = new("cov_export", this);
      cov_fifo   = new("cov_fifo", this);
    endfunction
    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      cov_export.connect(cov_fifo.analysis_export);
    endfunction

    task run_phase(uvm_phase phase);
      forever begin
        cov_fifo.get(cov_item);
        cg.sample();
      end
    endtask
  endclass : SPI_wrapper_coverage

endpackage : SPI_wrapper_coverage_pkg
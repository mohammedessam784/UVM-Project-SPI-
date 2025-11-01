package SPI_slave_coverage_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import SPI_slave_seq_item_pkg::*;

  class SPI_slave_coverage extends uvm_component;
    `uvm_component_utils(SPI_slave_coverage)
    uvm_analysis_port#(SPI_slave_seq_item) cov_export;
    uvm_tlm_analysis_fifo#(SPI_slave_seq_item) cov_fifo;
    SPI_slave_seq_item cov_item;

    covergroup cg;
     rx_data_cp: coverpoint cov_item.rx_data[9:8];
     SS_n_cp: coverpoint cov_item.SS_n {bins Write_bin_trans= (1=> 0 [*13]);
                                        bins Read_bin_trans= (1=> 0 [*23]);}
    MOSI_cp: coverpoint cov_item.temp_MO_data[10:8]
    {bins write_addr  = {3'b000};
    bins write_data  = {3'b001};
    bins read_addr   = {3'b110};
    bins read_data   = {3'b111};
     illegal_bins invalid_cmds = default;
    }
    SSN_cp : coverpoint cov_item.SS_n {
    bins high = {1'b1};
    bins low  = {1'b0};
  }
  // Cross coverage between SS_n and MOSI patterns
  SSN_MOSI_cross : cross SSN_cp, MOSI_cp {

    // Legal cases: SS_n high before valid MOSI commands
    bins write_addr_valid = binsof(SSN_cp.low) && binsof(MOSI_cp.write_addr);
    bins write_data_valid = binsof(SSN_cp.low) && binsof(MOSI_cp.write_data);
    bins read_addr_valid  = binsof(SSN_cp.low) && binsof(MOSI_cp.read_addr);
    bins read_data_valid  = binsof(SSN_cp.low) && binsof(MOSI_cp.read_data);

    // Exclude illegal or irrelevant cases (e.g., SS_n=1 with commands)
    ignore_bins irrelevant = binsof(SSN_cp.high) && binsof(MOSI_cp);
  }
    endgroup : cg

    function new(string name = "SPI_slave_coverage", uvm_component parent = null);
      super.new(name, parent);
      cg = new();
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      cov_export = new("cov_export", this);
      cov_fifo   = new("cov_fifo", this);
      `uvm_info("coverage","coverage build_phase", UVM_MEDIUM)
    endfunction
      function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      cov_export.connect(cov_fifo.analysis_export);
    endfunction 

    task run_phase(uvm_phase phase);
    super.run_phase( phase);
      forever begin
        // cov_item= SPI_slave_seq_item::type_id::create("cov_item");
        cov_fifo.get(cov_item);
         cg.sample();
        // `uvm_info("coverage", cov_item.convert2string(), UVM_MEDIUM)
      end
    endtask
  endclass : SPI_slave_coverage

endpackage : SPI_slave_coverage_pkg
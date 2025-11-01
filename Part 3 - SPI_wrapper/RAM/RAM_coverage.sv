package RAM_coverage_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import RAM_seq_item_pkg::*;
  import RAM_shared_pkg ::*;

  class RAM_coverage extends uvm_component;
    `uvm_component_utils(RAM_coverage)
    uvm_analysis_port#(RAM_seq_item) cov_export;
    uvm_tlm_analysis_fifo#(RAM_seq_item) cov_fifo;
    RAM_seq_item cov_item;
/**
1- Write Coverpoint to check transaction ordering for din[9:8]:  
• Check din[9:8] takes 4 possible values 
• Check write data after write address 
• Check read data after read address 
• Check write address => write data => read address => read data
3- Cross coverage: 
• Between all bins of din[9:8] and rx_valid signal when it is high 
• Between din[9:8] when it equals read data and tx_valid when it is high
*/
    covergroup cg;
    din_cp: coverpoint cov_item.din[9:8] {
       bins val0 = {WRITE_ADDR};
       bins val1 = {WRITE_DATA};
       bins val2 = {READ_ADDR};
       bins val3 = {READ_DATA};
     }

     din_trans: coverpoint cov_item.din[9:8] {
       bins wr_d_after_wr_addr = (WRITE_ADDR => WRITE_DATA);
       bins rd_d_after_rd_addr = (READ_ADDR => READ_DATA);
       bins trans_all= (WRITE_ADDR => WRITE_DATA => READ_ADDR => READ_DATA);
     }
     rx_valid_cp: coverpoint cov_item.rx_valid {
       bins valid = {1'b1};
      // bins invalid = {1'b0};
     }

     cross_rx_din: cross din_cp, rx_valid_cp{
      
     }
    tx_valid_cp: coverpoint cov_item.tx_valid {
       bins valid = {1'b1};
      // bins invalid = {1'b0};
     } 
     cross_tx_din:cross din_cp,tx_valid_cp{
      bins tx_read_data =binsof(din_cp.val3) && binsof(tx_valid_cp.valid);
      option.cross_auto_bin_max=0;
     }

    endgroup : cg

    function new(string name = "RAM_coverage", uvm_component parent = null);
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
  endclass : RAM_coverage

endpackage : RAM_coverage_pkg
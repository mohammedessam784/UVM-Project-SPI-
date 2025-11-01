package SPI_wrapper_scoreboard_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import SPI_wrapper_seq_item_pkg::*;

  class SPI_wrapper_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(SPI_wrapper_scoreboard)
    uvm_analysis_port#(SPI_wrapper_seq_item) sb_export;
    uvm_tlm_analysis_fifo#(SPI_wrapper_seq_item) sb_fifo;
    SPI_wrapper_seq_item received;

    function new(string name = "SPI_wrapper_scoreboard", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sb_export = new("sb_export", this);
      sb_fifo   = new("sb_fifo", this);
    endfunction
     function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      sb_export.connect(sb_fifo.analysis_export);
    endfunction

    task run_phase(uvm_phase phase);
      forever begin
        sb_fifo.get(received);
        golden_model(received);
      end
    endtask

    // TODO: Implement golden_model tailored to your DUT's expected behavior
    task automatic golden_model(input SPI_wrapper_seq_item tx);
      // Example: simple pass-through model (replace with actual model logic)
      if (tx.MISO !== tx.MISO_ref) begin
        `uvm_error("SCOREBOARD", $sformatf("Mismatch detected! MISO=%0d, Expected MISO_ref=%0d", tx.MISO, tx.MISO_ref))
      end else begin
        `uvm_info("SCOREBOARD", "Match confirmed between MISO and MISO_ref", UVM_LOW)
      end
     // `uvm_info("SCOREBOARD", $sformatf("Golden model called for: %s", tx.convert2string()), UVM_LOW)
    endtask
  endclass : SPI_wrapper_scoreboard

endpackage : SPI_wrapper_scoreboard_pkg
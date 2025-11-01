package RAM_scoreboard_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import RAM_seq_item_pkg::*;
  import RAM_shared_pkg::*;
  class RAM_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(RAM_scoreboard)
    uvm_analysis_port#(RAM_seq_item) sb_export;
    uvm_tlm_analysis_fifo#(RAM_seq_item) sb_fifo;
    RAM_seq_item received;

    function new(string name = "RAM_scoreboard", uvm_component parent = null);
      super.new(name, parent);
    endfunction
   function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      sb_export.connect(sb_fifo.analysis_export);
    endfunction
    
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sb_export = new("sb_export", this);
      sb_fifo   = new("sb_fifo", this);
    endfunction

    task run_phase(uvm_phase phase);
      forever begin
        sb_fifo.get(received);
       golden_model(received);
      end
    endtask

    // TODO: Implement golden_model tailored to your DUT's expected behavior
    task automatic golden_model(input RAM_seq_item tx);
      // Example: Compare DUT outputs with expected values
      if (tx.dout !== tx.dout_ref || tx.tx_valid !== tx.tx_valid_ref) begin
        error_count++;
        `uvm_error("SCOREBOARD", $sformatf("Mismatch detected! Expected dout=%0h, tx_valid=%0d but got dout=%0h, tx_valid=%0d",
          tx.dout_ref, tx.tx_valid_ref, tx.dout, tx.tx_valid))
      end else begin
        correct_count++;
        `uvm_info("SCOREBOARD", "Match: DUT outputs match expected values.", UVM_LOW)
      end
    //  `uvm_info("SCOREBOARD", $sformatf("Golden model called for: %s", tx.convert2string()), UVM_LOW)
    endtask
  endclass : RAM_scoreboard

endpackage : RAM_scoreboard_pkg
package SPI_slave_scoreboard_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import SPI_slave_seq_item_pkg::*;
  import SPI_slave_shared_pkg::*;

  class SPI_slave_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(SPI_slave_scoreboard)
    uvm_analysis_port#(SPI_slave_seq_item) sb_export;
    uvm_tlm_analysis_fifo#(SPI_slave_seq_item) sb_fifo;
    SPI_slave_seq_item rx;

    function new(string name = "SPI_slave_scoreboard", uvm_component parent = null);
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
        sb_fifo.get(rx);
        golden_model(rx);
      end
    endtask

    // TODO: Implement golden_model tailored to your DUT's expected behavior
    task automatic golden_model(input SPI_slave_seq_item tx);
       // Example: Log the received transaction
       if(tx.rx_valid_ref!=tx.rx_valid || tx.MISO_ref!=tx.MISO) begin
          error_count++;
          `uvm_error("SCOREBOARD", $sformatf("Mismatch in rx_valid: expected %0b, got %0b", tx.rx_valid_ref, tx.rx_valid))
       end else begin
          `uvm_info("SCOREBOARD", $sformatf("rx_valid matches: %0b", tx.rx_valid), UVM_LOW)
             if(tx.rx_valid==1) begin
                if(tx.rx_data_ref!=tx.rx_data) begin
                   error_count++;
                   `uvm_error("SCOREBOARD", $sformatf("Mismatch in rx_data: expected %0h, got %0h", tx.rx_data_ref, tx.rx_data))
                end else begin
                   correct_count++;
                   `uvm_info("SCOREBOARD", $sformatf("rx_data matches: %0h", tx.rx_data), UVM_LOW)
             end
        end
      end  
     // `uvm_info("SCOREBOARD", $sformatf("Golden model called for: %s", tx.convert2string()), UVM_LOW)
    endtask
  endclass : SPI_slave_scoreboard

endpackage : SPI_slave_scoreboard_pkg
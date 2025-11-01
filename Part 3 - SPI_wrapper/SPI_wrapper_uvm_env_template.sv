//============================================================
// File: XXX_uvm_env_template.sv
// Description: Generic UVM Environment Template
// Author: Mohamed Essam
//============================================================


//============================================================
// PACKAGE: XXX_shared_pkg
//============================================================
package SPI_wrapper_shared_pkg;
  // Generic shared types & enums used across the environment.
  // TODO: Add/replace enums and typedefs that match your DUT.
  
int error_count;
int correct_count;

typedef enum  {WRITE_ADDR=2'b00, WRITE_DATA=2'b01, READ_ADDR=2'b10, READ_DATA=2'b11} addr_type_e;
endpackage : SPI_wrapper_shared_pkg


//============================================================
// PACKAGE: RAM_config_pkg
//============================================================
package SPI_wrapper_config_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class SPI_wrapper_config extends uvm_object;
    `uvm_object_utils(SPI_wrapper_config)

    // TODO: Add your virtual interface handle(s) here
    // Example:
     virtual SPI_wrapper_if SPI_wrappervif;
    // TODO: Add other config fields (e.g. is_active, clock_period, time_scale...)
    uvm_active_passive_enum is_active;

    function new (string name = "SPI_wrapper_config");
      super.new(name);
    endfunction
  endclass

endpackage : SPI_wrapper_config_pkg


//============================================================
// INTERFACE: SPI_wrapper_if
//============================================================
interface SPI_wrapper_if (input logic clk);
  // TODO: Replace/add signals to match your DUT interface.

bit MOSI, SS_n, rst_n;
bit MISO;
bit MISO_ref;

  modport DUT (
    input clk,
    input rst_n,
    input SS_n,
    input MOSI,
    output MISO
  );
  modport REF (
    input clk,
    input rst_n,
    input SS_n,
    input MOSI,
    output MISO_ref
  );

endinterface : SPI_wrapper_if


//============================================================
// PACKAGE: XXX_seq_item_pkg
//============================================================
package SPI_wrapper_seq_item_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import SPI_wrapper_shared_pkg::*;

  class SPI_wrapper_seq_item extends uvm_sequence_item;
    `uvm_object_utils(SPI_wrapper_seq_item)

    // TODO: add randomized stimulus fields that match your DUT
   rand bit MOSI, SS_n, rst_n;
   bit MISO;
   bit MISO_ref;


  function new(string name = "SPI_wrapper_seq_item");
      super.new(name);
    endfunction

    function string convert2string();
      return $sformatf("%s MOSI=%0d SS_n=%0d rst_n=%0d MISO=%0d MISO_ref=%0d",
        super.convert2string(), MOSI, SS_n, rst_n, MISO, MISO_ref);
    endfunction

    // TODO: Add constraints tailored to DUT behavior
    constraint rst_n_mostly_deasserted{ rst_n dist{1:=97,0:=3};}

    rand bit [10:0] MO_data; // 11-bit array for MOSI data
    static bit [10:0] temp_MO_data;
   // static bit [1:0] cmd_type; // Example command type (write/read)
     static int cycle_count = 0;
    constraint valid_comb {
      MO_data[10:8] inside {3'b000, 3'b001, 3'b110, 3'b111};
    }
      constraint c2{ if (!rst_n){SS_n == 1; MOSI == 0;cycle_count==0;}
                     if (cycle_count==0) {SS_n == 1; MOSI == 0; }
                     if (cycle_count>=1 && cycle_count<=13) {SS_n == 0;}
                     if (cycle_count>=2 && cycle_count<=12) {MOSI == temp_MO_data[12-cycle_count];}
                     if (cycle_count==23&& temp_MO_data[9:8]==2'b11) {cycle_count==0;}
                     if (cycle_count==13&& temp_MO_data[9:8]!=2'b11) {cycle_count==0;}
                 } 

      


     // constraint write_only_seq { MO_data[10:8] inside {3'b000, 3'b001}; }
     //constraint read_only_seq  { MO_data[10:8] inside {3'b110, 3'b111}; }
      
        bit[1:0] wr_op[] = '{WRITE_ADDR, WRITE_DATA};
        bit[1:0] rd_op[] = '{READ_ADDR, READ_DATA};

        constraint rw_rd_seq {

         (prev_din[9:8] == WRITE_ADDR) -> din[9:8] inside {wr_op};
         (prev_din[9:8] == READ_ADDR)  -> din[9:8] inside {rd_op};
         (prev_din[9:8] == WRITE_DATA)  -> din[9:8]  dist {READ_ADDR:=60 , WRITE_ADDR:=40};
         (prev_din[9:8] == READ_DATA)   -> din[9:8]  dist {WRITE_ADDR:=60 , READ_ADDR:=40};
       
    }

 


    function void post_randomize();
     
     if (cycle_count == 0) begin
        temp_MO_data = MO_data;
        `uvm_info("POST_RANDOMIZE", $sformatf("Generated MO_data: 0x%0h", temp_MO_data), UVM_LOW)
     end
      cycle_count++;
      `uvm_info("POST_RANDOMIZE", $sformatf("Generated MO_data: 0x%0h, cycle_count=%0d", temp_MO_data,cycle_count), UVM_LOW)
      
    endfunction


  endclass : SPI_wrapper_seq_item

endpackage : SPI_wrapper_seq_item_pkg


//============================================================
// PACKAGE: SPI_wrapper_main_seq_pkg
//============================================================
package SPI_wrapper_main_seq_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import SPI_wrapper_seq_item_pkg::*;

  class SPI_wrapper_main_seq extends uvm_sequence #(SPI_wrapper_seq_item);
    `uvm_object_utils(SPI_wrapper_main_seq)
     SPI_wrapper_seq_item tx;
    function new(string name = "SPI_wrapper_main_seq");
      super.new(name);
    endfunction

    task body;
     
      repeat (500) begin
        tx = SPI_wrapper_seq_item::type_id::create("tx");
        start_item(tx);
        tx.constraint_mode(1);
        tx.write_only_seq.constraint_mode(1);
        tx.rw_rd_seq.constraint_mode(0);
        tx.read_only_seq.constraint_mode(0);
        assert(tx.randomize()) else `uvm_fatal("RANDOMIZE_FAIL","randomization failed");
        finish_item(tx);
      end
    endtask
  endclass : SPI_wrapper_main_seq

endpackage : SPI_wrapper_main_seq_pkg



//============================================================
// PACKAGE: SPI_wrapper_rst_seq_pkg
//============================================================
package SPI_wrapper_rst_seq_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import SPI_wrapper_seq_item_pkg::*;

  class SPI_wrapper_rst_seq extends uvm_sequence #(SPI_wrapper_seq_item);
    `uvm_object_utils(SPI_wrapper_rst_seq)

    function new(string name = "SPI_wrapper_rst_seq");
      super.new(name);
    endfunction

    task body;
      SPI_wrapper_seq_item tx = SPI_wrapper_seq_item::type_id::create("tx");
      start_item(tx);
      tx.rst_n    = 0; // Assert reset
      finish_item(tx);
      // TODO: allow DUT to settle after reset
    endtask

  endclass : SPI_wrapper_rst_seq

endpackage : SPI_wrapper_rst_seq_pkg


//============================================================
// PACKAGE: SPI_wrapper_sequencer_pkg
//============================================================
package SPI_wrapper_sequencer_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import SPI_wrapper_seq_item_pkg::*;

  class SPI_wrapper_sequencer extends uvm_sequencer#(SPI_wrapper_seq_item);
    `uvm_component_utils(SPI_wrapper_sequencer)
    function new(string name = "SPI_wrapper_sequencer", uvm_component parent = null);
      super.new(name, parent);
    endfunction
  endclass

endpackage : SPI_wrapper_sequencer_pkg


//============================================================
// PACKAGE: SPI_wrapper_driver_pkg
//============================================================
package SPI_wrapper_driver_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import SPI_wrapper_seq_item_pkg::*;
  import SPI_wrapper_config_pkg::*;

  class SPI_wrapper_driver extends uvm_driver#(SPI_wrapper_seq_item);
    `uvm_component_utils(SPI_wrapper_driver)
    virtual SPI_wrapper_if vif;
    SPI_wrapper_seq_item tx;

    function new(string name = "SPI_wrapper_driver", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
      
      forever begin
        seq_item_port.get_next_item(tx);
        // TODO: Drive DUT signals using tx fields
        vif.rst_n      = tx.rst_n;
        vif.SS_n       = tx.SS_n;
        vif.MOSI       = tx.MOSI;
        @(negedge vif.clk);
        seq_item_port.item_done();
      end
    endtask
  endclass : SPI_wrapper_driver

endpackage : SPI_wrapper_driver_pkg


//============================================================
// PACKAGE: SPI_wrapper_monitor_pkg
//============================================================
package SPI_wrapper_monitor_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import SPI_wrapper_seq_item_pkg::*;

  class SPI_wrapper_monitor extends uvm_monitor;
    `uvm_component_utils(SPI_wrapper_monitor)

    virtual SPI_wrapper_if vif;
    SPI_wrapper_seq_item tx;
    uvm_analysis_port#(SPI_wrapper_seq_item) mon_ap;

    function new(string name = "SPI_wrapper_monitor", uvm_component parent = null);
      super.new(name, parent);
    endfunction
function void build_phase(uvm_phase phase);
     super.build_phase(phase);
        mon_ap=new("mon_ap",this);
    endfunction   
    task run_phase(uvm_phase phase);
      
      forever begin
        tx = SPI_wrapper_seq_item::type_id::create("tx");
        @(negedge vif.clk);
        // TODO: sample DUT outputs and fill tx fields
        tx.MOSI       = vif.MOSI;
        tx.SS_n      = vif.SS_n;
        tx.rst_n    = vif.rst_n;
        tx.MISO      = vif.MISO;
        tx.MISO_ref  = vif.MISO_ref;
        `uvm_info("MONITOR", $sformatf("Observed: %s", tx.convert2string()), UVM_LOW)
        mon_ap.write(tx);
      end
    endtask
  endclass : SPI_wrapper_monitor

endpackage : SPI_wrapper_monitor_pkg


//============================================================
// PACKAGE: SPI_wrapper_agent_pkg
//============================================================
package SPI_wrapper_agent_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import SPI_wrapper_config_pkg::*;
  import SPI_wrapper_driver_pkg::*;
  import SPI_wrapper_monitor_pkg::*;
  import SPI_wrapper_sequencer_pkg::*;
  import SPI_wrapper_seq_item_pkg::*;

  class SPI_wrapper_agent extends uvm_agent;
    `uvm_component_utils(SPI_wrapper_agent)

    SPI_wrapper_config cfg;
    SPI_wrapper_driver drv;
    SPI_wrapper_sequencer sqr;
    SPI_wrapper_monitor mon;
    uvm_analysis_port#(SPI_wrapper_seq_item) agt_ap;

    function new(string name = "SPI_wrapper_agent", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(SPI_wrapper_config)::get(this, "", "CFG", cfg))
        `uvm_fatal("CFG_NOT_FOUND", "You must set the CFG before building the agent")

      if (cfg.is_active == UVM_ACTIVE) begin
        drv = SPI_wrapper_driver::type_id::create("drv", this);
        sqr = SPI_wrapper_sequencer::type_id::create("sqr", this);
      end
      mon = SPI_wrapper_monitor::type_id::create("mon", this);
      agt_ap = new("agt_ap", this);
    endfunction

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      if (cfg.is_active == UVM_ACTIVE) begin
        drv.seq_item_port.connect(sqr.seq_item_export);
        // TODO: set driver's virtual interface
        drv.vif = cfg.SPI_wrappervif;
      end
      // TODO: connect monitor vif
      mon.vif = cfg.SPI_wrappervif;
      mon.mon_ap.connect(agt_ap);
    endfunction
  endclass : SPI_wrapper_agent

endpackage : SPI_wrapper_agent_pkg


//============================================================
// PACKAGE: SPI_wrapper_scoreboard_pkg
//============================================================
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
      `uvm_info("SCOREBOARD", $sformatf("Golden model called for: %s", tx.convert2string()), UVM_LOW)
    endtask
  endclass : SPI_wrapper_scoreboard

endpackage : SPI_wrapper_scoreboard_pkg


//============================================================
// PACKAGE: SPI_wrapper_coverage_pkg
//============================================================
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


//============================================================
// PACKAGE: SPI_wrapper_env_pkg
//============================================================
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


//============================================================
// PACKAGE: SPI_wrapper_test_pkg
//============================================================
package SPI_wrapper_test_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import SPI_wrapper_env_pkg::*;
  import SPI_wrapper_agent_pkg::*;
  import SPI_wrapper_config_pkg::*;
  import SPI_wrapper_main_seq_pkg::*;
  import SPI_wrapper_rst_seq_pkg::*;

  class SPI_wrapper_test extends uvm_test;
    `uvm_component_utils(SPI_wrapper_test)

    SPI_wrapper_env env;
    SPI_wrapper_config cfg;
    SPI_wrapper_main_seq main_seq;
    SPI_wrapper_rst_seq rst_seq;

    function new(string name = "SPI_wrapper_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env = SPI_wrapper_env::type_id::create("env", this);
      cfg = SPI_wrapper_config::type_id::create("cfg");
       if(!uvm_config_db#(virtual SPI_wrapper_if)::get(this, "", "SPI_wrapper_if", cfg.SPI_wrappervif))begin
        `uvm_fatal("VIF_NOT_FOUND", "You must set the VIF before building the agent")
     end
      cfg.is_active = UVM_ACTIVE;
      uvm_config_db#(SPI_wrapper_config)::set(this, "*", "CFG", cfg);
      rst_seq  = SPI_wrapper_rst_seq::type_id::create("rst_seq");
      main_seq = SPI_wrapper_main_seq::type_id::create("main_seq");
    endfunction

    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      `uvm_info("RUN_PHASE", "Starting reset sequence", UVM_LOW)
      rst_seq.start(env.agt.sqr);

      `uvm_info("RUN_PHASE", "Starting main sequence", UVM_LOW)
      main_seq.start(env.agt.sqr);

      `uvm_info("RUN_PHASE", "Test finished", UVM_LOW)
      phase.drop_objection(this);
    endtask
  endclass : SPI_wrapper_test

endpackage : SPI_wrapper_test_pkg



//top

import uvm_pkg::*;
`include "uvm_macros.svh"
import SPI_wrapper_test_pkg::*;
import SPI_wrapper_shared_pkg::*;

module top();

  bit clk;
  // Clock generation
  initial begin
    forever begin
      #5 clk=~clk;
    end
  end
  // Instantiate the interface and DUT
   SPI_wrapper_if SPI_wrapperif(clk);
   //SPI_wrapper dut (.SPI_wrapperif(SPI_wrapperif) );
   //SPI_wrapper_ref dut_ref (.SPI_wrapperif(SPI_wrapperif) );

  //  bind the SVA module to the design, and pass the interface
   //bind SPI_wrapper SPI_wrapper_sva inst_sva (SPI_wrapperif);


 initial begin
  uvm_config_db #(virtual SPI_wrapper_if)::set(null,"uvm_test_top","SPI_wrapper_if",SPI_wrapperif);
  run_test("SPI_wrapper_test");
 end
  
endmodule

//============================================================
// END OF FILE
//============================================================

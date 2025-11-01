package RAM_seq_item_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import RAM_shared_pkg::*;

  class RAM_seq_item extends uvm_sequence_item;
    `uvm_object_utils(RAM_seq_item)

    // TODO: add randomized stimulus fields that match your DUT
  rand logic [9:0] din;
  rand logic  rst_n, rx_valid;

   bit [7:0] dout;
   bit tx_valid;
   bit [7:0] dout_ref;
   bit tx_valid_ref;
static bit [9:0] prev_din;
  function new(string name = "RAM_seq_item");
      super.new(name);
    endfunction

    function string convert2string();
      return $sformatf("%s  rst_n=%0d rx_valid=%0d din=%0h dout=%0h dout_ref=%0h tx_valid=%0d tx_valid_ref=%0d",
        super.convert2string(),rst_n, rx_valid, din, dout, dout_ref, tx_valid, tx_valid_ref);
    endfunction

    // TODO: Add constraints tailored to DUT behavior
       constraint rst_n_mostly_deasserted{ rst_n dist{1:=97,0:=3};}
       
      constraint rx_valid_mostly_asserted{ rx_valid dist{1:=90,0:=10};} 
      // Constraint: din[9:8] == 2'b00 (Write Address) must be followed by 2'b00 or 2'b01 (Write Address/Data)
      
      
      constraint write_only_seq { din[9] inside {0}; 
                                //  if (prev_din[9:8] == 2'b00){
                                //  din[9:8] inside {2'b00, 2'b01};}
      } // only write operation
      // Sequence constraint for Write Address followed by Write Address/Data
      

      constraint read_only_seq { din[9:8] inside {2'b10, 2'b11};
                                //  if (prev_din[9:8] == 2'b10){
                                //  din[9:8] inside {2'b10, 2'b11};}
      } // only  read operations
        // Sequence constraint for Read Address followed by Read Address/Data
     
        bit[1:0] wr_op[] = '{WRITE_ADDR, WRITE_DATA};
        bit[1:0] rd_op[] = '{READ_ADDR, READ_DATA};

        constraint rw_rd_seq { 
                              
       
         (prev_din[9:8] == WRITE_ADDR) -> din[9:8] inside {wr_op};
         (prev_din[9:8] == READ_ADDR)  -> din[9:8] inside {rd_op};
         (prev_din[9:8] == WRITE_DATA)  -> din[9:8]  dist {READ_ADDR:=60 , WRITE_ADDR:=40};
         (prev_din[9:8] == READ_DATA)   -> din[9:8]  dist {WRITE_ADDR:=60 , READ_ADDR:=40};
       
    }
      
 



      function void post_randomize();
        prev_din = din;
        $display("prev_din=%0h", prev_din);
      endfunction
  endclass : RAM_seq_item

endpackage : RAM_seq_item_pkg
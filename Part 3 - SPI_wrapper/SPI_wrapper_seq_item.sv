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
    constraint rst_n_mostly_deasserted{ rst_n dist{1:=99,0:=1};}

    rand bit [10:0] MO_data; // 11-bit array for MOSI data
    static bit [10:0] temp_MO_data;
    static bit [10:0] prev_MO_data;
    static int cycle_count = 0;
    constraint valid_comb1 {
      MO_data[10:8] inside {3'b000, 3'b001, 3'b110, 3'b111}; 
    }
      constraint valid_comb2{ 
                    MOSI inside {0};
                    SS_n inside {1};
                 } 

     constraint write_only_seq { MO_data[10:8] inside {3'b000, 3'b001}; }
     constraint read_only_seq  { 
      MO_data[10:8] inside {3'b110, 3'b111};
      (prev_MO_data[8]==0)-> MO_data[8]==1;
      (prev_MO_data[8]==1)-> MO_data[8]==0;
       }
      
        bit[1:0] wr_op[] = '{WRITE_ADDR, WRITE_DATA};
        bit[1:0] rd_op[] = '{READ_ADDR, READ_DATA};

        constraint rw_rd_seq {
         (prev_MO_data[9:8] == WRITE_ADDR) -> MO_data[9:8] inside {wr_op};
         (prev_MO_data[9:8] == READ_ADDR)  -> MO_data[9:8] inside {rd_op};
         (prev_MO_data[9:8] == WRITE_DATA) -> MO_data[9:8]  dist {READ_ADDR:=60 , WRITE_ADDR:=40};
         (prev_MO_data[9:8] == READ_DATA)  -> MO_data[9:8]  dist {WRITE_ADDR:=60 , READ_ADDR:=40};
          }

 


    function void post_randomize();
     //MO_data[7:0] = 8'h54;
    if (cycle_count>=1 && cycle_count<=23) begin SS_n = 0; end
    if (cycle_count>=2 && cycle_count<=12) begin MOSI = temp_MO_data[12-cycle_count]; end
      prev_MO_data = temp_MO_data;
     `uvm_info("POST_RANDOMIZE", $sformatf("Generated MO_data: 0x%0h, cycle_count=%0d", temp_MO_data,cycle_count), UVM_LOW)
      `uvm_info("POST_RANDOMIZE", $sformatf("MOSI=%0d SS_n=%0d rst_n=%0d", MOSI, SS_n, rst_n), UVM_LOW)
     if (cycle_count == 0) begin
        temp_MO_data = MO_data;
        SS_n = 1; MOSI = 0;
        cycle_count++;
      end
      else if (cycle_count==13&& temp_MO_data[9:8]!=2'b11) begin
         cycle_count = 0;
      end
      else if (cycle_count==23&& temp_MO_data[9:8]==2'b11) begin
         cycle_count = 0;
      end
      else begin
         cycle_count++;
      end
      
      if (!rst_n)
      begin 
        MOSI = 0;
        SS_n = 1;
        cycle_count=0;
        prev_MO_data[10:8]=3'b111;
        temp_MO_data[10:8]=3'b111;
      end
      

    endfunction


  endclass : SPI_wrapper_seq_item

endpackage : SPI_wrapper_seq_item_pkg

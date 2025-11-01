package SPI_slave_seq_item_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import SPI_slave_shared_pkg::*;

  class SPI_slave_seq_item extends uvm_sequence_item;
    `uvm_object_utils(SPI_slave_seq_item)

    // TODO: add randomized stimulus fields that match your DUT
  rand logic    rst_n;
  rand logic  MOSI , SS_n, tx_valid;
  rand logic  [7:0] tx_data;

  rand bit [10:0] MO_data; // 11-bit array for MOSI data
  static bit [10:0] temp_MO_data;
  static bit [1:0] cmd_type; // Example command type (write/read)
    // Observed fields (from monitor)
   logic     [9:0] rx_data;
   logic           rx_valid, MISO;
   bit [9:0] rx_data_ref;
  bit      rx_valid_ref;
   bit      MISO_ref;

    function new(string name = "SPI_slave_seq_item");
      super.new(name);
    endfunction

    function string convert2string();
    return $sformatf(
    "%s SS_n=%0b | MOSI=%0b | tx_valid=%0b | tx_data=0x%0h | MO_data=0x%0h | cmd_type=%0b | rx_data=0x%0h | rx_valid=%0b | MISO=%0b",
    super.convert2string(),
    SS_n,
    MOSI,
    tx_valid,
    tx_data,
    temp_MO_data,
    cmd_type,
    rx_data,
    rx_valid,
    MISO
  );
endfunction


    // TODO: Add constraints tailored to DUT behavior
    constraint rst_n_mostly_deasserted{ rst_n dist{1:=97,0:=3};}
    constraint c3 {
      MO_data[10:8] inside {3'b000, 3'b001, 3'b110, 3'b111};
      MO_data[7:0]   inside {8'h00,8'hFF,8'hA5};
    }
    static bit [10:0] prev_MO_data;
     constraint my_c{
      MOSI     inside {0};
      SS_n     inside {1};
      tx_valid inside {0};
      (prev_MO_data[8]==0)-> MO_data[8]==1;
      (prev_MO_data[8]==1)-> MO_data[8]==0;
     }

   function void post_randomize();
   
      static int cycle_count = 0;
      prev_MO_data = temp_MO_data;
        tx_data = temp_MO_data [7:0];
      if (!rst_n) begin
        cycle_count = 0;
        SS_n        = 1;
        tx_valid    = 0;
        MOSI        = 0;
        return;
      end

          $display("temp_MO_data=%0h cycle_count=%0d",temp_MO_data ,cycle_count);
        if (cycle_count == 0)begin
          SS_n = 1;
          tx_valid=0;
          temp_MO_data=MO_data;
          cmd_type =MO_data[9:8];
          end
       else begin
          SS_n = 0;
          $display("cycle_count=%0d  SS_n = 0;",cycle_count);
        if(cycle_count>=2 && cycle_count<=12)
           MOSI=temp_MO_data[12-cycle_count];
        else if(cycle_count>=15)
         tx_valid=1;
        // else   
        //   tx_valid=0;
       end
    //////////////  

      if (cmd_type == 2'b11) begin
        if(cycle_count ==23)
         cycle_count=0;
         else
        cycle_count++;
      end
      else begin
        if(cycle_count == 13)
         cycle_count=0;
         else
         cycle_count++;
      end


      
      
    endfunction
 

  endclass : SPI_slave_seq_item

  

endpackage : SPI_slave_seq_item_pkg
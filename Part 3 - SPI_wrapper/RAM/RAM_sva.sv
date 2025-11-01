

import RAM_shared_pkg::*;
module RAM_sva(RAM_if.DUT RAMif);
  reset_a :assert property (@(posedge RAMif.clk) !RAMif.rst_n |-> ##1 !RAMif.tx_valid &&RAMif.tx_valid==0);
  
  
   _2a: assert property (@(posedge RAMif.clk) disable iff (!RAMif.rst_n)
    RAMif.rx_valid && (RAMif.din[9:8]==2'b00 || RAMif.din[9:8]==2'b01 || RAMif.din[9:8]==2'b10) 
    |->##1 (RAMif.tx_valid==0));
  
   _3a: assert property (@(posedge RAMif.clk) disable iff (!RAMif.rst_n)
   RAMif.rx_valid && (RAMif.din[9:8]==2'b11) |=> RAMif.tx_valid ##[1:$] $fell(RAMif.tx_valid));
  
   _4b: assert property (@(posedge RAMif.clk) disable iff (!RAMif.rst_n)
    (RAMif.din[9:8]==2'b00) |-> ##[1:$] (RAMif.din[9:8]==2'b01));
   _5a: assert property (@(posedge RAMif.clk) disable iff (!RAMif.rst_n)
    (RAMif.din[9:8]==2'b10) |-> ##[1:$] (RAMif.din[9:8]==2'b11));
 


endmodule
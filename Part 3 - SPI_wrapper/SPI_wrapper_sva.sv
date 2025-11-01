

import SPI_wrapper_shared_pkg::*;
module SPI_wrapper_sva(SPI_wrapper_if.DUT SPI_wrapperif);


  


  MISO_stable_a: assert property (@(posedge SPI_wrapperif.clk) disable iff (!SPI_wrapperif.rst_n)
    $fell (SPI_wrapperif.SS_n)|=>$stable(SPI_wrapperif.MISO)[*13]);

endmodule
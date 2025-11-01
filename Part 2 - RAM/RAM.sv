module RAM (RAM_if.DUT RAMif);




 wire[9:0] din;
 wire      clk, rst_n, rx_valid;
 reg [7:0] dout;
 reg       tx_valid;

assign RAMif.dout = dout;
assign RAMif.tx_valid = tx_valid;
assign din = RAMif.din;
assign clk = RAMif.clk;
assign rst_n = RAMif.rst_n;
assign rx_valid = RAMif.rx_valid;


reg [7:0] MEM [255:0];

reg [7:0] Rd_Addr, Wr_Addr;

always @(posedge clk) begin
    if (~rst_n) begin
        dout <= 0;
        tx_valid <= 0;
        Rd_Addr <= 0;
        Wr_Addr <= 0;
    end
    else  begin                                         
        if (rx_valid) begin
            case (din[9:8])
                2'b00 : Wr_Addr <= din[7:0];
                2'b01 : MEM[Wr_Addr] <= din[7:0];
                2'b10 : Rd_Addr <= din[7:0];
                2'b11 : dout <= MEM[Rd_Addr];//edit
                default : dout <= 0;
            endcase
            tx_valid <= (din[9] && din[8] && rx_valid)? 1'b1 : 1'b0;//edit
        end
      end  
end

endmodule
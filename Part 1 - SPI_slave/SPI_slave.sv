module SLAVE (SPI_slave_if.DUT SPI_slaveif);

localparam IDLE      = 3'b000;
localparam CHK_CMD   = 3'b001;
localparam WRITE     = 3'b010;//edit
localparam READ_ADD  = 3'b011;
localparam READ_DATA = 3'b100;

 wire       MOSI, clk, rst_n, SS_n, tx_valid;
 wire [7:0] tx_data;
 reg [9:0] rx_data;
 reg       rx_valid, MISO;

assign MOSI    = SPI_slaveif.MOSI;
assign rst_n = SPI_slaveif.rst_n;
assign clk   = SPI_slaveif.clk;
assign SS_n  = SPI_slaveif.SS_n;
assign tx_valid= SPI_slaveif.tx_valid;
assign tx_data = SPI_slaveif.tx_data;

///////
always @(*) begin
 SPI_slaveif.rx_data = rx_data;
 SPI_slaveif.rx_valid = rx_valid;
 SPI_slaveif.MISO = MISO;
end


reg [3:0] counter;
reg       received_address;

reg [2:0] cs, ns;

always @(posedge clk) begin
    if (~rst_n) begin
        cs <= IDLE;
    end
    else begin
        cs <= ns;
    end
end

always @(*) begin

    case (cs)
        IDLE : begin
            if (SS_n)
                ns = IDLE;
            else
                ns = CHK_CMD;
        end
        CHK_CMD : begin
            if (SS_n)
                ns = IDLE;
            else begin
                if (~MOSI)
                    ns = WRITE;
                else begin
                    if (!received_address) //edit
                        ns = READ_ADD; 
                    else
                        ns = READ_DATA;
                end
            end
        end
        WRITE : begin
            if (SS_n)
                ns = IDLE;
            else
                ns = WRITE;
        end
        READ_ADD : begin
            if (SS_n)
                ns = IDLE;
            else
                ns = READ_ADD;
        end
        READ_DATA : begin
            if (SS_n)
                ns = IDLE;
            else
                ns = READ_DATA;
        end
    endcase
end

always @(posedge clk) begin
    if (~rst_n) begin 
        rx_data <= 0;
        rx_valid <= 0;
        received_address <= 0;
        MISO <= 0;
    end
    else begin
        case (cs)
            IDLE : begin
                rx_valid <= 0;
            end
            CHK_CMD : begin
                counter <= 10;      
            end
            WRITE : begin
                if (counter > 0) begin
                    rx_data[counter-1] <= MOSI;
                    counter <= counter - 1;
                end
                else begin
                    rx_valid <= 1;
                end
            end
            READ_ADD : begin
                if (counter > 0) begin
                    rx_data[counter-1] <= MOSI;
                    counter <= counter - 1;
                end
                else begin
                    rx_valid <= 1;
                    received_address <= 1;
                end
            end
            READ_DATA : begin
                if (tx_valid) begin
                    rx_valid <= 0;
                    if (counter > 0) begin
                        MISO <= tx_data[counter-1];
                        counter <= counter - 1;
                    end
                    else begin
                        received_address <= 0;
                    end
                end
                else begin
                    if (counter > 0) begin
                        rx_data[counter-1] <= MOSI;
                        counter <= counter - 1;
                    end
                    else begin
                        rx_valid <= 1;
                        counter <= 9;//edit
                    end
                end
            end
        endcase
    end
end


`ifdef SIM

assert_rst_a: assert property (@(posedge clk)
 !rst_n |=> (MISO==0)&&(rx_valid==0)&&(rx_data==0)
) ;


assert property 
(@(posedge clk) disable iff(!rst_n) 
(cs==IDLE)&&$fell(SS_n)|=>(cs==CHK_CMD)
);

assert property 
(@(posedge clk) disable iff(!rst_n) 
(cs==CHK_CMD) |=> (cs==WRITE)||(cs==READ_ADD)||(cs==READ_DATA)
);

assert property 
(@(posedge clk) disable iff(!rst_n)
((cs==READ_DATA)||(cs==READ_ADD)||(cs==WRITE))&&$rose(SS_n) |=> (cs==IDLE)
);


sequence write_add_seq;
    $fell(SS_n) ##1(MOSI==0) ##1 (MOSI==0) ##1 (MOSI==0);
endsequence

write_add_a:assert property 
(@(posedge clk)
disable iff(!rst_n) write_add_seq |-> ##10  $rose(rx_valid)
);

sequence write_data_seq;
    $fell(SS_n) ##1(MOSI==0) ##1 (MOSI==0) ##1 (MOSI==1);
endsequence

write_data_a:assert property 
(@(posedge clk) 
disable iff(!rst_n) write_data_seq |-> ##10  $rose(rx_valid)
);

sequence read_add_seq;
    $fell(SS_n) ##1(MOSI==1) ##1 (MOSI==1) ##1 (MOSI==0);
endsequence

read_add_a:assert property 
(@(posedge clk)
 disable iff(!rst_n) read_add_seq |-> ##10  $rose(rx_valid)
);

sequence read_data_seq;
    $fell(SS_n) ##1(MOSI==1) ##1 (MOSI==1) ##1 (MOSI==1);
endsequence
read_data_a:assert property 
(@(posedge clk)
 disable iff(!rst_n) read_data_seq |-> ##10  $rose(rx_valid)
);



`endif  // SIM
endmodule
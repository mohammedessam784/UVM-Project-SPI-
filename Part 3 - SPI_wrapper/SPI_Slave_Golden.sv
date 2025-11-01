

module SPI_Slave_Golden (MOSI,MISO,SS_n,clk,rst_n,rx_data,rx_valid,tx_data,tx_valid);

parameter IDLE      = 3'b000 ;
parameter CHK_CMD   = 3'b001 ;
parameter WRITE     = 3'b010 ;
parameter READ_ADD  = 3'b011 ;
parameter READ_DATA = 3'b100 ;


input            MOSI, clk, rst_n, SS_n, tx_valid;
input      [7:0] tx_data;
output reg [9:0] rx_data;
output reg       rx_valid, MISO;


(* fsm_encoding = "gray" *) 
reg [2:0] cs , ns ;
reg read_data_or_address ;
reg [3:0] counter ;

// next state logic 
always @(*) begin
    case (cs) 
    // case IDLE 
        IDLE :
            if(SS_n)
                ns = IDLE ;
            else 
                ns = CHK_CMD ;
    
    // case CHK_CMD 
        CHK_CMD :
            if(SS_n)
                ns = IDLE ;
            else if ( MOSI == 0 ) 
                ns = WRITE ;
            else if (~read_data_or_address)
                ns = READ_ADD ;
            else
                ns = READ_DATA ;

    // case WRITE             
        WRITE :
            if(SS_n)
                ns = IDLE ;
            else
                ns = WRITE ;

    // case READ_ADD
        READ_ADD :
            if(SS_n)
                ns = IDLE ;
            else 
                ns = READ_ADD ;

    // case READ_DATA 
        READ_DATA :
            if(SS_n)
                ns = IDLE ;
            else 
                ns = READ_DATA ;

    endcase
end

// state memory 
always @(posedge clk) begin
    if(~rst_n)
        cs <= IDLE ;
    else 
        cs <= ns ;
end

// output logic 
always @(posedge clk) begin
    if(~rst_n) begin
        MISO                 <= 0 ;
        rx_data              <= 10'b0 ;
        rx_valid             <= 0 ;
        read_data_or_address <= 0 ;
        counter              <= 0 ;
    end
    else begin 
        case(cs)
            IDLE :
                rx_valid <= 0 ;
            CHK_CMD :
                counter <= 10 ;
            WRITE :
                if (counter > 0) begin
                    rx_data[counter-1] <= MOSI ;
                    counter <= counter - 1 ; 
                end
                else begin
                    rx_valid <= 1 ;
                end
            READ_ADD :
                if (counter > 0) begin
                    rx_data[counter-1] <= MOSI ;
                    counter <= counter - 1 ; 
                end
                else begin
                    rx_valid <= 1 ;
                    read_data_or_address <= 1 ;
                end
            READ_DATA :
                if (tx_valid) begin
                    rx_valid <= 0 ;
                    if(counter == 0) begin
                        read_data_or_address <= 0 ;
                    end
                    else begin
                        MISO <= tx_data[counter-1];
                        counter <= counter - 1 ;
                    end 
                    
                end
                else begin
                    //// dummmy ;
                    if (counter > 0) begin
                        rx_data[counter-1] <= MOSI ;
                        counter <= counter - 1 ; 
                        rx_valid <= 0;///
                    end
                    else begin
                        rx_valid <= 1 ;
                        counter <= 9  ;
                    end


                end
        endcase
    end
end


endmodule

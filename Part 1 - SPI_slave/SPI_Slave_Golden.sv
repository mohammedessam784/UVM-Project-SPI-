

module SPI_Slave_Golden (SPI_slave_if.REF SPI_slaveif );

parameter IDLE      = 3'b000 ;
parameter CHK_CMD   = 3'b001 ;
parameter WRITE     = 3'b010 ;
parameter READ_ADD  = 3'b011 ;
parameter READ_DATA = 3'b100 ;


wire clk , SS_n , rst_n , MOSI ;
wire [7:0] tx_data ;
wire tx_valid ;

 reg MISO ;
 reg [9:0] rx_data ;
 reg rx_valid ; 
 
assign rst_n = SPI_slaveif.rst_n ;
assign clk   = SPI_slaveif.clk ;
assign SS_n  = SPI_slaveif.SS_n ;
assign tx_valid= SPI_slaveif.tx_valid ;
assign tx_data = SPI_slaveif.tx_data ;
assign MOSI    = SPI_slaveif.MOSI ;
always @(*) begin
    SPI_slaveif.rx_data_ref = rx_data ;
    SPI_slaveif.rx_valid_ref = rx_valid ;
    SPI_slaveif.MISO_ref = MISO ;
end


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

  /*
    input  clk,
    input  rst_n,
    input SS_n,
    input MOSI,
    output reg MISO,
    input        tx_valid,
    input  [7:0] tx_data,    
    output reg      rx_valid,
    output reg [9:0] rx_data
    );
 localparam IDLE=3'd0;
 localparam CHK_CMD=3'd1;  
 localparam WRITE=3'd2;
 localparam READ=3'd3;
 localparam READ_DATA=3'd4;
 
   reg [2:0] current_state,next_state;
   reg [3:0] wr_counter, wr_counter_next; // counter up to 8 or 10
   reg [9:0]  rx_data_next;   // MOSI data
   reg [7:0] shift_reg_out, shift_reg_out_next; // MISO data;

   reg rx_valid_next;
   reg rd_addr_flag;


  always@(posedge clk or negedge rst_n) begin
     if(~rst_n) begin
            wr_counter    <= 4'd0;
            rx_data <= 10'd0;
            shift_reg_out <= 8'd1;
     end
     else begin
          wr_counter    <= wr_counter_next;
          rx_data  <= rx_data_next;
          rx_valid <= rx_valid_next;
          shift_reg_out <= shift_reg_out_next;
     end 
   end  
     
     //current_state
     always@(posedge clk or negedge rst_n) begin
     if(~rst_n) begin
            current_state<=IDLE;
     end else begin
          current_state <=next_state;
     end
     end 

// Next state logic
always@(*) begin
            next_state = current_state;
        if(SS_n==1'b1) next_state=IDLE;

        case(current_state)
          IDLE: begin
                if(SS_n==1'b0)
                 next_state=CHK_CMD;
               end
          CHK_CMD: begin
                     if(MOSI==1'b0)
                     next_state=WRITE;
                     else 
                     next_state=READ;
                    end 
           WRITE : begin
                    if (wr_counter == 4'd10) begin 
                     next_state = IDLE; 
                    end    
                   end  
            READ : begin
                    rx_data_next = {rx_data[8:0], MOSI};
                    wr_counter_next   = wr_counter + 1;
                    if (wr_counter == 4'd10) begin
                       rx_valid_next = 1'b1;
                       wr_counter_next =4'b0;
                       if(rx_data[9:8]==2'd2 ) begin
                         rd_addr_flag = 1'b1;
                         next_state = IDLE;
                       end else if(rx_data[9:8]==2'd3&&rd_addr_flag==1'b1) begin
                         rd_addr_flag = 1'b0;
                         next_state = READ_DATA;
                       end
                     end         
                    end                     
              READ_DATA : begin 
                            if(tx_valid==1'b1) begin
                               MISO = tx_data[7-wr_counter]; 
                               wr_counter_next = wr_counter + 1;
                              if (wr_counter == 4'd7) begin
                                next_state = IDLE;
                               end       
                            end
                         end        
          endcase 

       end


     always@(*) begin
            next_state = current_state;
            wr_counter_next   = wr_counter;
            rx_data_next = rx_data;
            shift_reg_out_next= shift_reg_out;
            rx_valid          = 1'b0;
            MISO              = 1'b1;
        if(SS_n==1'b1) next_state=IDLE;

        case(current_state)
          IDLE: begin
                wr_counter_next =4'b0;
                if(SS_n==1'b0)
                next_state=CHK_CMD;
               end
          CHK_CMD: begin
                     wr_counter_next =4'b0;
                     if(MOSI==1'b0)
                     next_state=WRITE;
                     else 
                     next_state=READ;
                    end 
           WRITE : begin
                  // Shift in from MOSI
                     rx_data_next = {rx_data[8:0], MOSI};
                     wr_counter_next   = wr_counter + 1;
                    if (wr_counter == 4'd10) begin 
                     rx_valid_next = 1'b1;
                      wr_counter_next =4'b0;
                     next_state = IDLE; 
                     end    
                   end  
            READ : begin
                    rx_data_next = {rx_data[8:0], MOSI};
                    wr_counter_next   = wr_counter + 1;
                    if (wr_counter == 4'd10) begin
                       rx_valid_next = 1'b1;
                       wr_counter_next =4'b0;
                       if(rx_data[9:8]==2'd2 ) begin
                         rd_addr_flag = 1'b1;
                         next_state = IDLE;
                       end else if(rx_data[9:8]==2'd3&&rd_addr_flag==1'b1) begin
                         rd_addr_flag = 1'b0;
                         next_state = READ_DATA;
                       end
                     end         
                    end                     
              READ_DATA : begin 
                            if(tx_valid==1'b1) begin
                               MISO = tx_data[7-wr_counter]; 
                               wr_counter_next = wr_counter + 1;
                              if (wr_counter == 4'd7) begin
                                next_state = IDLE;
                               end       
                            end
                         end        
          endcase 

       end
endmodule     
    */
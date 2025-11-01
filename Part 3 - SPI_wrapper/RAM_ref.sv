


// Verilog module for a synchronous single-port RAM.
// This module handles read and write operations based on the SPI commands.
module RAM_ref(din,clk,rst_n,rx_valid,dout,tx_valid);

input      [9:0] din;
input            clk, rst_n, rx_valid;

output reg [7:0] dout;
output reg       tx_valid;


   localparam  MEM_DEPTH = 256;
   localparam  ADDR_SIZE = 8;
    // --- Internal Registers and Memory Declaration ---
    // RAM memory array. We use a block RAM style for better synthesis.
    (* ram_style = "block" *)
    reg [7:0] mem[255:0];

    // Registers to hold the read and write addresses
    reg [7:0] wr_addr;
    reg [7:0] rd_addr;

    // --- Synchronous Logic (Register Updates and Memory Operations) ---
    // All operations happen on the rising edge of the clock.
    always@(posedge clk ) begin
        if (~rst_n) begin
            // Asynchronous reset
            wr_addr    <= {ADDR_SIZE{1'b0}};
            rd_addr    <= {ADDR_SIZE{1'b0}};
            tx_valid   <= 1'b0;
            dout       <= 8'd0;
        end else begin
            // Default assignments
           // tx_valid <= 1'b0;

            // Check if the SPI Slave module has a valid command
            if (rx_valid) begin
                // Decode the command from the two most significant bits of din
                case(din[9:8])
                    // Command: '00' (Write Address)
                    2'b00: begin
                        wr_addr <= din[7:0]; // Store the new write address
                        tx_valid <= 1'b0;
                    end
                    // Command: '01' (Write Data)
                    2'b01: begin
                        // Write the data to the previously stored address
                        mem[wr_addr] <= din[7:0];
                        tx_valid <= 1'b0;
                    end
                    // Command: '10' (Read Address)
                    2'b10: begin
                        rd_addr <= din[7:0]; // Store the new read address
                        tx_valid <= 1'b0;
                    end
                    // Command: '11' (Read Data)
                    2'b11: begin
                        tx_valid <= 1'b1;     // Assert tx_valid to signal data is ready
                        dout <= mem[rd_addr]; // Read data from the previously stored address
                    end
                    default: begin
                        // Do nothing for invalid commands
                    end
                endcase
                
            end
        end
    end

endmodule

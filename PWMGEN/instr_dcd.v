`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/18/2025 06:30:05 PM
// Design Name: 
// Module Name: instr_dcd
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module instr_dcd(
        // peripheral clock signals
    input clk,
    input rst_n,
    // towards SPI slave interface signals
    input byte_sync,
    input[7:0] data_in,
    output[7:0] data_out,
    // register access signals
    output read,
    output write,
    output[5:0] addr,
    input[7:0] data_read,
    output[7:0] data_write
    );
    //Creem registri pentru blocurile always si countere pentru a numara cati biti mai avem de citit/scris
    reg[7:0] data_out_r;
    assign data_out=data_out_r;
    reg read_r;
    assign read=read_r;
    reg write_r;
    assign write=write_r;
    reg[5:0] addr_r;
    assign addr=addr_r;
    reg[7:0] data_write_r;
    assign data_write=data_write_r;
    //Folosim un AFD pentru implementare
   parameter S0 = 2'b00;
parameter S1 = 2'b01;
parameter S2 = 2'b10;
reg [1:0] state, next_state;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin state <= S0;
      read_r       = 1'b0;
    write_r      = 1'b0;
    addr_r       = 6'd0;
    data_out_r   = 8'd0;
    data_write_r = 8'd0;
    next_state   = S0;
    end
    else state <= next_state;
end

always @(*) begin
    // default outputs
  

    case (state)
      S0: begin
         if (byte_sync) begin
            if (data_in[7]) begin
               write_r = 1'b1;
               addr_r  = data_in[5:0];
               data_write_r[0] = data_in[6];
               next_state = S1;
            end else begin
               read_r  = 1'b1;
               addr_r  = data_in[5:0];
               next_state = S2;
            end
         end
      end
      S1: begin
         if (byte_sync) begin
            data_write_r = data_in;
             write_r      = 1'b0;
            addr_r       = 6'd0;
            next_state = S0;
         end
      end
      S2: begin
         data_out_r = data_read; // keep stable until next
         read_r       = 1'b0;
          addr_r       = 6'd0;
         next_state = S0;
      end
    endcase
end

endmodule
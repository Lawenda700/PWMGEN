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
    parameter S0=0;
    parameter S1=1;
    parameter S2=2;
    reg state,next_state;
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n)
            state<=S0;
        else state<=next_state;
    end
    always@(*) begin
        case(state)
        S0: 
            if(byte_sync) begin
                if(data_in[7]) begin
                    write_r=1;
                    read_r=data_in[6];
                    
                end
              else begin
              write_r=0;
              read_r=1;
              end
              addr_r=data_in[5:0];
              if(!write_r)
                next_state=S2;
                else next_state=S1;
            end
        S1:   if(byte_sync) begin
                    data_write_r=data_in;
                    next_state=S0;
                end
        S2:    begin
                data_out_r=data_read;
                next_state=S0;
                    end
                
                
        
        endcase
    end
endmodule

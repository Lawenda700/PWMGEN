`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/19/2025 08:07:03 PM
// Design Name: 
// Module Name: spi_bridge
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


module spi_bridge(
        // peripheral clock signals
    input clk,
    input rst_n,
    // SPI master facing signals
    input sclk,
    input cs_n,
    output mosi,
    input miso,
    // internal facing 
    output byte_sync,
    output[7:0] data_in,
    input[7:0] data_out

    );
    //Creem registri pentru blocurile always si countere pentru a numara cati biti mai avem de citit/scris
    reg mosi_n;
    assign mosi=mosi_n;
    reg byte_sync_n;
    assign byte_sync=byte_sync_n;
    reg[7:0] data_in_n;
    assign data_in=data_in_n;
    reg[7:0] data_int;
    reg[2:0] count_rx;
    reg[2:0] count_tx;
    always @(posedge sclk or negedge rst_n) begin
        if (!rst_n) begin //resetarea registrilor
            mosi_n       <= 1'b0;
            byte_sync_n  <= 1'b0;
            data_in_n    <= 8'd0;
            data_int     <= 8'd0;
            count_tx     <= 3'd7;
            count_rx     <= 3'd7;
        end else begin
            

            if (!cs_n) begin
                // citim de la MSB
                mosi_n <= data_out[count_tx];
                if (count_tx == 3'd0) begin
                    count_tx <= 3'd7;
                   
                    end
                else
                    count_tx <= count_tx - 1'b1;

                // receive
                
                
            end else begin
                count_tx <= 3'd7;
                
            end
        end
    end
    always@(negedge sclk or negedge rst_n) begin 
     if (!rst_n) begin //resetarea registrilor
            mosi_n       <= 1'b0;
            byte_sync_n  <= 1'b0;
            data_in_n    <= 8'd0;
            data_int     <= 8'd0;
            count_tx     <= 3'd7;
            count_rx     <= 3'd7;
            end else begin
            byte_sync_n <= 1'b0;  // default
        if(!cs_n) begin  //scriem de la MSB in variabila auxiliara data_int pe care o copiem in data_in_n cand ajungem la bitul final
            data_int[count_rx] <= miso; 
            if (count_rx == 3'd0) begin
                    data_in_n   <= data_int;
                    byte_sync_n <= 1'b1;
                    count_rx    <= 3'd7;
                end else begin
                    count_rx <= count_rx - 1'b1;
                end 
        end else begin
        count_rx <= 3'd7;
        end
        end
    end
   
endmodule
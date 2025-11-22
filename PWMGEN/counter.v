`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/15/2025 02:32:57 PM
// Design Name: 
// Module Name: counter
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


module counter(
     // peripheral clock signals
    input clk,
    input rst_n,
    // register facing signals
    output[15:0] count_val,
    input[15:0] period,
    input en,
    input count_reset,
    input upnotdown,
    input[7:0] prescale
    );
      //Creem registri pentru blocurile always si countere pentru a numara cati biti mai avem de citit/scris
    reg[15:0] count_val_r;
    assign count_val=count_val_r-1;
    //counter pana la atingerea valorii de prescale
    reg[15:0] inner_counter=16'h0000;
    //counter period pentru prescale la semnalul de ceas
    wire[15:0] ss=(16'b0000000000000001<<prescale);
    always@(posedge clk or negedge rst_n) begin
    if(!rst_n | count_reset) begin
        inner_counter<=16'h0000;
        if(upnotdown)
            count_val_r <= 16'h0001;
        else count_val_r<=period;
        end
    else begin
        // Here should be the rest of the implementation
        if(en) begin
            if(upnotdown) begin
            if(count_val_r==period &&inner_counter>=ss-1) begin //resetarea counter-ului de la prima valoare
                count_val_r<=16'h0001;
                inner_counter<=16'h0000;
                end
                else begin
                    if(inner_counter>=ss-1) begin //resetarea counter-ului intern la atingerea valorii prescale
                        count_val_r<=count_val_r+1'b1; //incrementare counter
                        inner_counter<=16'h0000;
                    end
                    else begin  //incrementarea counter intern
                        inner_counter<=inner_counter+1'b1;
                    end
                end
            end
            else begin 
                if(count_val_r==16'h0001 &&inner_counter>=ss-1) begin //resetarea counter-ului de la prima valoare
                count_val_r<=period;
                inner_counter<=16'h0000;
                end
                else begin
                    if(inner_counter>=ss-1) begin //resetarea counter-ului intern la atingerea valorii prescale
                        count_val_r<=count_val_r-1'b1; //decrementare counter
                        inner_counter<=16'h0000;
                    end
                    else begin  //incrementarea counter intern
                        inner_counter<=inner_counter+1'b1;
                    end
                end
            
            end            
             
        end
    end
end

endmodule

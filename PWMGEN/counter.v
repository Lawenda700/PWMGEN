`timescale 1ns / 1ps

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
    
    reg[15:0] count_val_r;
    assign count_val = count_val_r; 
    
    // counter pana la atingerea valorii de prescale
    reg[15:0] inner_counter;
    
    // counter period pentru prescale la semnalul de ceas
    wire[15:0] ss = (16'd1 << prescale);

    always@(posedge clk or negedge rst_n) begin
        if(!rst_n | count_reset) begin
            inner_counter <= 16'h0000;
            count_val_r   <= 16'h0000;
        end
        else begin
            if(en) begin
                if(upnotdown) begin // Count Up
                    // Daca am ajuns la prescale
                    if(inner_counter >= ss - 1) begin
                        inner_counter <= 16'h0000;
                        
                        // Logica Count Up
                        if(count_val_r >= period) 
                            count_val_r <= 16'h0000;
                        else 
                            count_val_r <= count_val_r + 1'b1;
                    end
                    else begin // incrementarea counter intern
                        inner_counter <= inner_counter + 1'b1;
                    end
                end
                else begin // Count Down
                    // Daca am ajuns la prescale
                    if(inner_counter >= ss - 1) begin
                        inner_counter <= 16'h0000;
                        
                        // Logica Count Down
                        if(count_val_r == 16'h0000) 
                            count_val_r <= period;
                        else 
                            count_val_r <= count_val_r - 1'b1;
                    end
                    else begin
                        inner_counter <= inner_counter + 1'b1;
                    end
                end
            end
        end
    end
endmodule

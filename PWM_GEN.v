`timescale 1ns / 1ps

module PWM_GEN(
    // peripheral clock signals
    input clk,
    input rst_n,
    // PWM signal register configuration
    input pwm_en,
    input[15:0] period,
    input[7:0] functions,
    input[15:0] compare1,
    input[15:0] compare2,
    input[15:0] count_val,
    // top facing signals
    output reg pwm_out
);
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin // La reset out e 0
            pwm_out <= 1'b0;
        end
        else if (pwm_en) begin
            if (functions[1:0] == 2'b00) begin // daca functions e 00 => aliniat stanga
                if (count_val < compare1) begin
                    pwm_out <= 1'b1; // activ pana la compare1
                end
                else begin
                    pwm_out <= 1'b0; // dezactivat dupa compare1
                end
            end
            else if (functions[1:0] == 2'b01) begin // daca functions e 01 => aliniat la dreapta
                if (count_val >= compare1) begin
                    pwm_out <= 1'b1; //activat dupa compare1             
                end
                else begin
                    pwm_out <= 1'b0; //dezactivat inainte de compare1
                end
            end
            else if (functions[1:0] == 2'b10) begin // functions 10 => nealiniat
                if (count_val >= compare1 && count_val < compare2) begin
                    pwm_out <= 1'b1; // activat intre compare-uri
                end    
                else begin
                    pwm_out <= 1'b0; // dezactivat in afara intervalului
                end
            end
            else begin
                pwm_out <= 1'b0; // Output pentru orice alt fel de functions
            end
        end
        else begin
            pwm_out <= 1'b0; // Dezactivat complet cand pwm_en = 0
        end
    end         
endmodule

`timescale 1ns / 1ps

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

    // Receptie
    reg [2:0] count_rx;
    reg [7:0] rx_shift; // registru de shift intern
    reg [7:0] data_latch; // buffer de transfer catre clk
    reg flag_toggle; // semnal de comunicare intre domenii

    always @(posedge sclk or posedge cs_n) begin
        if (cs_n) begin
            count_rx    <= 3'd7;
            flag_toggle <= 1'b0;
        end 
        else begin
            // shiftam bitul primit
            rx_shift[count_rx] <= miso;
            if (count_rx == 3'd0) begin
                count_rx    <= 3'd7;
                data_latch  <= {rx_shift[7:1], miso}; // salvam octetul
                flag_toggle <= ~flag_toggle; // schimbam starea
            end
            else begin
                count_rx <= count_rx - 1'b1;
            end
        end
    end

    // Transmisie
    reg [7:0] tx_shift;
    assign mosi = tx_shift[7];

    always @(negedge sclk or posedge cs_n) begin
        if (cs_n) begin
            tx_shift <= data_out;
        end 
        else begin
            // shiftam stanga
            tx_shift <= {tx_shift[6:0], 1'b0};
        end
    end

    // Sincronizare pe clk
    reg flag_sync_1, flag_sync_2, flag_sync_3;
    reg byte_sync_r;
    reg [7:0] data_in_r;

    assign byte_sync = byte_sync_r;
    assign data_in   = data_in_r;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            byte_sync_r <= 1'b0;
            data_in_r   <= 8'd0;
            flag_sync_1 <= 1'b0;
            flag_sync_2 <= 1'b0;
            flag_sync_3 <= 1'b0;
        end 
        else begin
            // sincronizam semnalul flag_toggle care vine de la sclk
            flag_sync_1 <= flag_toggle;
            flag_sync_2 <= flag_sync_1;
            flag_sync_3 <= flag_sync_2; // pastram istoric pentru a detecta schimbarea
            // daca s-a schimbat starea
            if (flag_sync_2 != flag_sync_3) begin
                byte_sync_r <= 1'b1; // generam pulsul valid pentru sistem
                data_in_r   <= data_latch; // preluam datele stabile
            end 
            else begin
                byte_sync_r <= 1'b0;
            end
        end
    end

endmodule

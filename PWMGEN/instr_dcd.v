`timescale 1ns / 1ps

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

    // Registri pentru iesiri
    reg[7:0] data_out_r;
    reg read_r;
    reg write_r;
    reg[5:0] addr_r;
    reg[7:0] data_write_r;

    // Asignare la porturi
    assign data_out   = data_out_r;
    assign read       = read_r;
    assign write      = write_r;
    assign addr       = addr_r;
    assign data_write = data_write_r;

    // Definirea Starilor
    parameter S0 = 2'b00; // IDLE / Command decoding
    parameter S1 = 2'b01; // WRITE_DATA wait
    parameter S2 = 2'b10; // READ_DATA wait

    reg [1:0] state, next_state;

    // --- LOGICA SECVENTIALA (Stare + Iesiri) ---
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state        <= S0;
            read_r       <= 1'b0;
            write_r      <= 1'b0;
            addr_r       <= 6'd0;
            data_out_r   <= 8'd0;
            data_write_r <= 8'd0;
        end
        else begin
            state <= next_state;

            // Resetam semnalele de control pulsate
            read_r  <= 1'b0;
            write_r <= 1'b0; 

            case (state)
                S0: begin
                    if (byte_sync) begin
                        addr_r <= data_in[5:0]; // Salvam adresa
                        
                        // Bitul 7 decide: 0 = Read, 1 = Write
                        if (data_in[7] == 1'b0) begin
                            read_r <= 1'b1; // Activam citirea imediat
                        end
                    end
                end

                S1: begin
                    if (byte_sync) begin
                        data_write_r <= data_in; // Salvam datele venite prin SPI
                        write_r      <= 1'b1;    // Dam comanda de scriere in registri
                    end
                end

                S2: begin
                    data_out_r <= data_read; 
                end
            endcase
        end
    end

    // Aici decidem doar incotro mergem, NU scriem date
    always @(*) begin
        next_state = state; // Default ramane in aceeasi stare

        case (state)
            S0: begin
                if (byte_sync) begin
                    if (data_in[7]) 
                        next_state = S1; // Daca e Write, mergem sa asteptam datele
                    else 
                        next_state = S2; // Daca e Read, mergem sa citim
                end
                else 
                    next_state = S0;
            end

            S1: begin
                if (byte_sync) 
                    next_state = S0; 
                else 
                    next_state = S1;
            end

            S2: begin
                next_state = S0; 
            end
            
            default: next_state = S0;
        endcase
    end

endmodule

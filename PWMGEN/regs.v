module regs (
    // peripheral clock signals
    input clk,
    input rst_n,
    // decoder facing signals
    input read,
    input write,
    input[5:0] addr,
    output[7:0] data_read,
    input[7:0] data_write,
    // counter programming signals
    input[15:0] counter_val,
    output[15:0] period,
    output en,
    output count_reset,
    output upnotdown,
    output[7:0] prescale,
    // PWM signal programming values
    output pwm_en,
    output[7:0] functions,
    output[15:0] compare1,
    output[15:0] compare2
);

    localparam ADDR_PERIOD        = 6'h00; 
    localparam ADDR_COUNTER_EN    = 6'h02;
    localparam ADDR_COMPARE1      = 6'h03; 
    localparam ADDR_COMPARE2      = 6'h05; 
    localparam ADDR_COUNTER_RESET = 6'h07;
    localparam ADDR_COUNTER_VAL   = 6'h08; 
    localparam ADDR_PRESCALE      = 6'h0A;
    localparam ADDR_UPNOTDOWN     = 6'h0B;
    localparam ADDR_PWM_EN        = 6'h0C;
    localparam ADDR_FUNCTIONS     = 6'h0D;

    // Registrii interni
    reg[15:0] period_reg;
    reg counter_en_reg;
    reg[15:0] compare1_reg;
    reg[15:0] compare2_reg;
    reg counter_reset_reg;
    reg[7:0] prescale_reg;
    reg upnotdown_reg;
    reg pwm_en_reg;
    reg[7:0] functions_reg;
    
    // Logica combinationala pentru citire
    reg[7:0] data_read_reg;
    
    // Counter pentru auto-reset
    reg [1:0] reset_counter;

    // Asignare iesiri
    assign period = period_reg;
    assign en = counter_en_reg;
    assign compare1 = compare1_reg;
    assign compare2 = compare2_reg;
    assign count_reset = counter_reset_reg;
    assign prescale = prescale_reg;
    assign upnotdown = upnotdown_reg;
    assign pwm_en = pwm_en_reg;
    assign functions = functions_reg;
    assign data_read = data_read_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset asincron
            period_reg <= 16'h0000;
            counter_en_reg <= 1'b0;
            compare1_reg <= 16'h0000;
            compare2_reg <= 16'h0000;
            counter_reset_reg <= 1'b0;
            prescale_reg <= 8'h00;
            upnotdown_reg <= 1'b0;
            pwm_en_reg <= 1'b0;
            functions_reg <= 8'h00;
            reset_counter <= 2'b00;
        end
        else begin

            if (reset_counter != 2'b00) begin
                if (reset_counter == 2'b10) begin
                    counter_reset_reg <= 1'b0;
                    reset_counter <= 2'b00;
                end else begin
                    reset_counter <= reset_counter + 1'b1;
                end
            end

            // 2. Logica de Scriere (Sincrona)
            if (write) begin
                case (addr)
                    ADDR_PERIOD: begin 
                        period_reg[7:0] <= data_write;
                        period_reg[15:8] <= 8'h00; // Resetam partea de sus
                    end
                    ADDR_COUNTER_EN: counter_en_reg <= data_write[0];
                    ADDR_COMPARE1: begin 
                        compare1_reg[7:0] <= data_write;
                        compare1_reg[15:8] <= 8'h00;
                    end
                    ADDR_COMPARE2: begin 
                        compare2_reg[7:0] <= data_write;
                        compare2_reg[15:8] <= 8'h00;
                    end
                    ADDR_COUNTER_RESET: begin 
                        counter_reset_reg <= data_write[0];
                        if (data_write[0]) reset_counter <= 2'b01; // Pornim numaratoarea de auto-clear
                    end
                    ADDR_PRESCALE: prescale_reg <= data_write;
                    ADDR_UPNOTDOWN: upnotdown_reg <= data_write[0];
                    ADDR_PWM_EN: pwm_en_reg <= data_write[0];
                    ADDR_FUNCTIONS: functions_reg <= data_write; 
                    default: ; 
                endcase
            end
        end 
    end

    always @(*) begin
        case (addr)
            ADDR_PERIOD:        data_read_reg = period_reg[7:0];
            ADDR_COUNTER_EN:    data_read_reg = {7'b0, counter_en_reg};
            ADDR_COMPARE1:      data_read_reg = compare1_reg[7:0];
            ADDR_COMPARE2:      data_read_reg = compare2_reg[7:0];
            ADDR_COUNTER_RESET: data_read_reg = {7'b0, counter_reset_reg};
            ADDR_COUNTER_VAL:   data_read_reg = counter_val[7:0];
            ADDR_PRESCALE:      data_read_reg = prescale_reg;
            ADDR_UPNOTDOWN:     data_read_reg = {7'b0, upnotdown_reg};
            ADDR_PWM_EN:        data_read_reg = {7'b0, pwm_en_reg};
            ADDR_FUNCTIONS:     data_read_reg = {6'b0, functions_reg[1:0]};
            default:            data_read_reg = 8'h00;
        endcase
    end

endmodule

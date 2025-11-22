 module regs (
    // peripheral clock signals
    input clk,
    input rst_n,
    // decoder facing signals
    input read,
    input write,
    input[5:0] addr,
    output reg[7:0] data_read,
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

    // Definirea adreselor conform tabelului din documentație
    localparam ADDR_PERIOD    = 6'h00;  // PERIOD[7:0]
    localparam ADDR_COUNTER_EN  = 6'h02;
    localparam ADDR_COMPARE1  = 6'h03;  // COMPARE1[7:0]
    localparam ADDR_COMPARE2  = 6'h05;  // COMPARE2[7:0]]
    localparam ADDR_COUNTER_RESET = 6'h07;
    localparam ADDR_COUNTER_VAL = 6'h08; // COUNTER_VAL[7:0] - Read only
    localparam ADDR_PRESCALE    = 6'h0A;
    localparam ADDR_UPNOTDOWN   = 6'h0B;
    localparam ADDR_PWM_EN      = 6'h0C;
    localparam ADDR_FUNCTIONS   = 6'h0D;

    // Registrii interni - conform tabelului
    reg[15:0] period_reg;
    reg counter_en_reg;
    reg[15:0] compare1_reg;
    reg[15:0] compare2_reg;
    reg counter_reset_reg;
    reg[7:0] prescale_reg;
    reg upnotdown_reg;
    reg pwm_en_reg;
    reg[7:0] functions_reg;

    // Asignare ieșiri
    assign period = period_reg;
    assign en = counter_en_reg;
    assign compare1 = compare1_reg;
    assign compare2 = compare2_reg;
    assign count_reset = counter_reset_reg;
    assign prescale = prescale_reg;
    assign upnotdown = upnotdown_reg;
    assign pwm_en = pwm_en_reg;
    assign functions = functions_reg;
    parameter S3=0;
    parameter S4=1;
    parameter S5=2;
    reg state,next_state;
    reg sb;
    // Logica de scriere în registrii
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset asincron pentru toți registrii
            period_reg <= 16'h0000;
            counter_en_reg <= 1'b0;
            compare1_reg <= 16'h0000;
            compare2_reg <= 16'h0000;
            counter_reset_reg <= 1'b0;
            prescale_reg <= 8'h00;
            upnotdown_reg <= 1'b0;
            pwm_en_reg <= 1'b0;
            functions_reg <= 8'h00;
             state<=S3;
             end
        else state<=next_state;
        end 
 always @(*) begin
            // COUNTER_RESET se auto-resetează după 2 ciclii de ceas
            // (conform documentației: "se golește după al doilea ciclu de ceas")
            case(state)
            S3: begin
                if(data_write[0]) begin sb=1; end
                    else begin sb=0; end
                if(write) begin next_state=S4; end
                    else next_state=S5;
               end
            S4: begin
            if (counter_reset_reg)
                counter_reset_reg = 1'b0;
            
            // Operații de scriere
           
                case (addr)
                    ADDR_PERIOD: begin if(sb)   period_reg[15:8]= data_write;
                    else period_reg[7:0]= data_write;
                    end
                    ADDR_COUNTER_EN: counter_en_reg = data_write[0];
                    ADDR_COMPARE1: begin if(sb) compare1_reg[15:8]= data_write;
                    else compare1_reg[7:0]= data_write; end
                    ADDR_COMPARE2: begin if(sb) compare2_reg[15:8]= data_write; 
                    else compare2_reg[7:0]= data_write; end
                    ADDR_COUNTER_RESET: counter_reset_reg = data_write[0];
                    ADDR_PRESCALE: prescale_reg = data_write;
                    ADDR_UPNOTDOWN: upnotdown_reg = data_write[0];
                    ADDR_PWM_EN: pwm_en_reg = data_write[0];
                    ADDR_FUNCTIONS: functions_reg= data_write[1:0]; // Doar primii 2 biți sunt relevanți
                    default: ; // Adresele nerecunoscute sunt ignorate
                endcase
                next_state=S3;
            
                end

    // Logica de citire din registrii
   
          S5:
          begin
            case (addr)
                ADDR_PERIOD: begin if(sb) data_read = period_reg[15:8];
                else data_read = period_reg[7:0];  end
                ADDR_COUNTER_EN: data_read = {7'b0, counter_en_reg};
                ADDR_COMPARE1: begin if(sb) data_read = compare1_reg[15:8]; 
                else data_read = compare1_reg[7:0]; end
                ADDR_COMPARE2: begin if(sb) data_read = compare2_reg[15:8];
                else data_read = compare2_reg[7:0]; end
                ADDR_COUNTER_RESET: data_read = {7'b0, counter_reset_reg};
                ADDR_COUNTER_VAL: begin if(sb) data_read = counter_val[15:8];
                else data_read = counter_val[7:0]; end  // Read-only
                ADDR_PRESCALE: data_read = prescale_reg;
                ADDR_UPNOTDOWN: data_read = {7'b0, upnotdown_reg};
                ADDR_PWM_EN: data_read = {7'b0, pwm_en_reg};
                ADDR_FUNCTIONS: data_read = {6'b0, functions_reg[1:0]};
                default: data_read = 8'h00; // Adresele nerecunoscute returnează 0
            endcase
            next_state=S3;
       
            end
    endcase
    end

endmodule

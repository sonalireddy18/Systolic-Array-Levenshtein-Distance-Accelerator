module controller (
    input wire clk,
    input wire rst,
    input wire start,
    input wire [2:0] test_sel, // New input to select test case
    output reg ready,
    output reg [7:0] current_char_a,
    output reg [7:0] d_init_val,
    output reg [3:0] char_index
);

    parameter IDLE = 2'b00, RUN = 2'b01, FLUSH = 2'b10, DONE = 2'b11;
    reg [1:0] state;
    reg [3:0] cycle_count;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            char_index <= 0;
            cycle_count <= 0;
            ready <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (start) state <= RUN;
                    ready <= 0;
                    char_index <= 0;
                    cycle_count <= 0;
                end
                RUN: begin
                    if (char_index == 3) state <= FLUSH;
                    char_index <= char_index + 1;
                end
                FLUSH: begin
                    if (cycle_count == 2) begin 
                        state <= DONE;
                        ready <= 1;
                    end else begin
                        cycle_count <= cycle_count + 1;
                        char_index <= char_index + 1;
                    end
                end
                DONE: begin
                    ready <= 1;
                    if (!start) state <= IDLE; // Wait for start to go low to reset
                end
            endcase
        end
    end

    always @(*) begin
        if (char_index < 4) begin
            d_init_val = char_index + 1;
            case(test_sel)
                3'd0: case(char_index) 0: current_char_a = "K"; 1: current_char_a = "I"; 2: current_char_a = "T"; 3: current_char_a = "T"; default: current_char_a = 0; endcase
                3'd1: case(char_index) 0: current_char_a = "B"; 1: current_char_a = "O"; 2: current_char_a = "O"; 3: current_char_a = "K"; default: current_char_a = 0; endcase
                3'd2: case(char_index) 0: current_char_a = "F"; 1: current_char_a = "A"; 2: current_char_a = "S"; 3: current_char_a = "T"; default: current_char_a = 0; endcase
                3'd3: case(char_index) 0: current_char_a = "C"; 1: current_char_a = "H"; 2: current_char_a = "A"; 3: current_char_a = "T"; default: current_char_a = 0; endcase
                3'd4: case(char_index) 0: current_char_a = "C"; 1: current_char_a = "O"; 2: current_char_a = "O"; 3: current_char_a = "L"; default: current_char_a = 0; endcase
                default: current_char_a = 0;
            endcase
        end else begin
            current_char_a = 8'h00;
            d_init_val = 8'hFF;
        end
    end
endmodule

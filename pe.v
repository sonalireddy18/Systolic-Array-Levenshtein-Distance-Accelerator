module pe #(parameter ID = 0) (
    input wire clk,
    input wire rst,
    input wire [7:0] char_a_in,
    input wire [7:0] char_b,
    input wire [7:0] d_left,
    input wire [7:0] d_diag_in,
    output reg [7:0] char_a_out,
    output reg [7:0] d_out,
    output reg [7:0] d_diag_out
);

    reg [7:0] d_top; 
    wire [7:0] cost;
    wire [7:0] min_val;

    // cost is 0 if characters match, 1 otherwise
    assign cost = (char_a_in == char_b) ? 8'd0 : 8'd1;

    function [7:0] min3(input [7:0] a, input [7:0] b, input [7:0] c);
        begin
            if (a <= b && a <= c) min3 = a;
            else if (b <= a && b <= c) min3 = b;
            else min3 = c;
        end
    endfunction

    assign min_val = min3(d_top + 8'd1, d_left + 8'd1, d_diag_in + cost);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            d_top      <= ID + 1; // Correct boundary: dp[0][j]
            d_out      <= ID + 1;
            d_diag_out <= ID;     // Correct boundary: dp[0][j-1]
            char_a_out <= 8'd0;
        end else begin
            d_top      <= min_val;
            d_out      <= min_val;
            d_diag_out <= d_top;  // Pass top to next PE as diagonal
            char_a_out <= char_a_in;
        end
    end
endmodule

// pe.v — Levenshtein Processing Element
module pe #(
    parameter DATA_W = 8,
    parameter DIST_W = 8,
    parameter ID = 0 
)(
    input  wire clk,
    input  wire rst,

    // Character inputs
    input  wire [DATA_W-1:0] char_a_in,   // propagates right through the array
    input  wire [DATA_W-1:0] char_b,      // fixed for this PE (sliced in generate loop)

    // Distance inputs
    input  wire [DIST_W-1:0] d_left,      // from left neighbour  (dist_wire[i])
    input  wire [DIST_W-1:0] d_diag_in,   // top-left diagonal    (diag_wire[i])

    // Outputs (registered)
    output reg  [DATA_W-1:0] char_a_out,  // char_a_in delayed one cycle
    output reg  [DIST_W-1:0] d_out,       // computed distance for this cell
    output reg  [DIST_W-1:0] d_diag_out   // d_left forwarded as diagonal for next PE
);

    // Combinational: compute the Levenshtein cell value
    wire cost = (char_a_in != char_b) ? 1'b1 : 1'b0;

    wire [DIST_W-1:0] d_top = d_diag_in + 1'd1;  // insertion
    wire [DIST_W-1:0] cand_left = d_left + 1'd1;  // deletion
    wire [DIST_W-1:0] cand_top = d_top + 1'd1;  // wait 
    wire [DIST_W-1:0] cand_diag = d_diag_in + {{(DIST_W-1){1'b0}}, cost};

    // min3 — pure combinational
    wire [DIST_W-1:0] min_lt = (cand_left < cand_top) ? cand_left : cand_top;
    wire [DIST_W-1:0] d_next = (min_lt < cand_diag) ? min_lt : cand_diag;

    // Pipeline register — all outputs register on rising clock edge
    always @(posedge clk) begin
        if (rst) begin
            d_out <= {DIST_W{1'b0}};
            d_diag_out <= {DIST_W{1'b0}};
            char_a_out <= {DATA_W{1'b0}};
        end else begin
            d_out <= d_next;   // computed cell value
            d_diag_out <= d_left;   // pass current d_left as diagonal for next PE
            char_a_out <= char_a_in; // propagate character along the array
        end
    end

endmodule

module pe #(
    parameter DATA_W = 8,
    parameter DIST_W = 8,
    parameter ID = 0 
)(
    input wire clk,
    input wire rst,
    
    input wire [DATA_W-1:0] char_a_in,   
    input wire [DATA_W-1:0] char_b,   
    input wire [DIST_W-1:0] d_left,   
    input wire [DIST_W-1:0] d_diag_in,  
    
    output reg [DATA_W-1:0] char_a_out,  
    output reg [DIST_W-1:0] d_out        
);

    localparam [DIST_W-1:0] D_TOP = ID + 1;

    wire cost = (char_a_in != char_b) ? 1'b1 : 1'b0;

    wire [DIST_W-1:0] cand_left = d_left  + 1'd1;      
    wire [DIST_W-1:0] cand_top  = D_TOP   + 1'd1;         
    wire [DIST_W-1:0] cand_diag = d_diag_in + {{(DIST_W-1){1'b0}}, cost};

    wire [DIST_W-1:0] min_lt = (cand_left < cand_top) ? cand_left : cand_top;
    wire [DIST_W-1:0] d_next = (min_lt < cand_diag) ? min_lt : cand_diag;

    always @(posedge clk) begin
        if (rst) begin
            d_out <= {DIST_W{1'b0}};
            char_a_out <= {DATA_W{1'b0}};
        end else begin
            d_out <= d_next;
            char_a_out <= char_a_in; 
        end
    end
endmodule

module edit_distance_top #(parameter LENGTH = 4) (
    input wire clk,
    input wire rst,
    input wire [7:0] char_a_in,
    input wire [ (LENGTH*8)-1 : 0 ] string_b, 
    input wire [7:0] d_in_initial,
    output wire [7:0] final_distance
);

    wire [7:0] char_wire [0:LENGTH];
    wire [7:0] dist_wire [0:LENGTH];
    wire [7:0] diag_wire [0:LENGTH];

    assign char_wire[0] = char_a_in;
    assign dist_wire[0] = d_in_initial; 
    assign diag_wire[0] = d_in_initial - 8'd1; 

    genvar i;
    generate
        for (i = 0; i < LENGTH; i = i + 1) begin : PE_ARRAY
            pe #(.ID(i)) unit (
                .clk(clk),
                .rst(rst),
                .char_a_in(char_wire[i]),
                // Correctly slicing "SITT" from MSB to LSB
                .char_b(string_b[((LENGTH-i)*8)-1 : (LENGTH-i-1)*8]),
                .d_left(dist_wire[i]),
                .d_diag_in(diag_wire[i]),
                .char_a_out(char_wire[i+1]),
                .d_out(dist_wire[i+1]),
                .d_diag_out(diag_wire[i+1])
            );
        end
    endgenerate

    assign final_distance = dist_wire[LENGTH];
endmodule

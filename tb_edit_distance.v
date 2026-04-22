`timescale 1ns/1ps

module tb_edit_distance;

parameter LENGTH = 4;

reg clk = 0;
reg rst;
reg [7:0] char_a_in;
reg [(LENGTH*8)-1:0] string_b;
reg [7:0] d_in_initial;

wire [7:0] final_distance;

// Instantiate DUT
edit_distance_top #(LENGTH) uut (
.clk(clk),
.rst(rst),
.char_a_in(char_a_in),
.string_b(string_b),
.d_in_initial(d_in_initial),
.final_distance(final_distance)
);

// Clock generation
always #5 clk = ~clk;

initial begin
// Initialize
rst = 1;
char_a_in = 8'd0;
string_b = 0;
d_in_initial = 8'd0;


// Apply inputs
#10;
char_a_in = "K";                  // character A
string_b  = {"S","I","T","T"};    // string B

// Release reset
#10 rst = 0;

$display("Starting Test...");

// Wait for pipeline computation
#100;

// Output result
$display("Final Distance Output = %d", final_distance);

$finish;


end

endmodule


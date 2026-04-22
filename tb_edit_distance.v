`timescale 1ns/1ps

module tb_edit_distance;

  
parameter LENGTH = 4;

reg clk;
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

// Clock generation (10ns period)
always #5 clk = ~clk;

initial begin
    // Initialize signals
    clk = 0;
    rst = 1;

    // Example test:
    // Comparing 'K' with "SITT"
    char_a_in = "K";
    string_b  = {"S","I","T","T"};
    d_in_initial = 8'd0;

    // Apply reset
    #10 rst = 0;

    $display("Starting Test...");

    // Wait for pipeline propagation
    #100;

    // Print result
    $display("Final Distance Output = %d", final_distance);

    $finish;
end
  

endmodule

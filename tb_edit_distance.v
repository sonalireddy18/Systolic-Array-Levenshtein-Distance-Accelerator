`timescale 1ns/1ps

module tb_edit_distance();
    reg clk, rst, start;
    reg [2:0] test_sel;
    reg [31:0] string_b_in;
    wire [7:0] final_dist;
    wire ready;
    wire [7:0] char_a, d_init;

    edit_distance_top #(.LENGTH(4)) dut (
        .clk(clk), .rst(rst), .char_a_in(char_a),
        .string_b(string_b_in), .d_in_initial(d_init),
        .final_distance(final_dist)
    );

    controller ctrl (
        .clk(clk), .rst(rst), .start(start), .test_sel(test_sel),
        .ready(ready), .current_char_a(char_a), .d_init_val(d_init)
    );

    always #5 clk = ~clk;

    integer i;
    reg [31:0] test_strings_a [0:4];
    reg [31:0] test_strings_b [0:4];

    initial begin
        // Setup Test Names for Display
        test_strings_a[0] = "KITT"; test_strings_b[0] = "SITT";
        test_strings_a[1] = "BOOK"; test_strings_b[1] = "BACK";
        test_strings_a[2] = "FAST"; test_strings_b[2] = "FAST";
        test_strings_a[3] = "CHAT"; test_strings_b[3] = "CATS";
        test_strings_a[4] = "COOL"; test_strings_b[4] = "POOL";

        clk = 0; rst = 1; start = 0; test_sel = 0;
        #20 rst = 0;

        $display("\n--- HARDWARE ACCELERATOR TEST SUITE ---");
        
        for (i = 0; i < 5; i = i + 1) begin
            test_sel = i;
            string_b_in = test_strings_b[i];
            
            #10 start = 1;
            wait(ready == 1);
            #2;
            $display("Test Case %0d: String A: %s | String B: %s | Distance: %0d", 
                      i+1, test_strings_a[i], test_strings_b[i], final_dist);
            
            #10 start = 0; // Reset for next test
            #20;
        end

        $display("---------------------------------------\n");
        $finish;
    end
endmodule

// ==========================================================
// Testbench : Edit Distance Accelerator
// ----------------------------------------------------------
// This testbench verifies the functionality of the
// systolic-array based Levenshtein Distance accelerator.
//
// Features:
// - Generates clock and reset signals
// - Instantiates DUT and controller
// - Applies multiple test cases
// - Displays computed edit distances
// - Verifies end-to-end accelerator operation
// ==========================================================

`timescale 1ns/1ps
module tb_edit_distance();

    // ======================================================
    // Testbench Signals
    // ======================================================

    // Clock signal
    reg clk;

    // Reset signal
    reg rst;

    // Start signal for controller
    reg start;

    // Selects test case
    reg [2:0] test_sel;

    // Input String B
    reg [31:0] string_b_in;

    // Final computed edit distance
    wire [7:0] final_dist;

    // Ready signal from controller
    wire ready;

    // Character stream from controller
    wire [7:0] char_a;

    // Initial DP boundary value
    wire [7:0] d_init;
    
    // ======================================================
    // DUT : Edit Distance Accelerator
    // ======================================================

    edit_distance_top #(.LENGTH(4)) dut (

        .clk(clk),
        .rst(rst),

        .char_a_in(char_a),

        .string_b(string_b_in),

        .d_in_initial(d_init),

        .final_distance(final_dist)
    );
    
    // ======================================================
    // Controller Instance
    // ------------------------------------------------------
    // Feeds characters into the accelerator
    // ======================================================

    controller ctrl (
        .clk(clk),
        .rst(rst),
        .start(start),
        .test_sel(test_sel),
        .ready(ready),
        .current_char_a(char_a),
        .d_init_val(d_init)
    );

    // ======================================================
    // Clock Generation
    // ------------------------------------------------------
    // Clock period = 10 ns
    // ======================================================

    always #5 clk = ~clk;
    // ======================================================
    // Test Data Storage
    // ======================================================

    integer i;

    // String A test cases
    reg [31:0] test_strings_a [0:4];

    // String B test cases
    reg [31:0] test_strings_b [0:4];
    // ======================================================
    // Test Sequence
    // ======================================================
    initial begin

        // --------------------------------------------------
        // Initialize Test Cases
        // --------------------------------------------------

        // Test 1:
        // Expected Distance = 1
        test_strings_a[0] = "KITT";
        test_strings_b[0] = "SITT";
        // Test 2:
        // Expected Distance = 2
        test_strings_a[1] = "BOOK";
        test_strings_b[1] = "BACK";

        // Test 3:
        // Expected Distance = 0
        test_strings_a[2] = "FAST";
        test_strings_b[2] = "FAST";
        // Test 4:
        // Expected Distance = 2
        test_strings_a[3] = "CHAT";
        test_strings_b[3] = "CATS";
        // Test 5:
        // Expected Distance = 1
        test_strings_a[4] = "COOL";
        test_strings_b[4] = "POOL";

        // --------------------------------------------------
        // Initial Signal Values
        // --------------------------------------------------

        clk      = 0;
        rst      = 1;
        start    = 0;
        test_sel = 0;
        // --------------------------------------------------
        // Apply Reset
        // --------------------------------------------------

        #20 rst = 0;
        // ==================================================
        // Begin Test Execution
        // ==================================================

        $display("\n--- HARDWARE ACCELERATOR TEST SUITE ---");
        // --------------------------------------------------
        // Run all test cases
        // --------------------------------------------------

        for (i = 0; i < 5; i = i + 1) begin

            // Select current test case
            test_sel = i;
            // Load String B into DUT
            string_b_in = test_strings_b[i];
            // ----------------------------------------------
            // Start accelerator
            // ----------------------------------------------

            #10 start = 1;
            // ----------------------------------------------
            // Wait until computation completes
            // ----------------------------------------------

            wait(ready == 1);

            #2;
            // ----------------------------------------------
            // Display Results
            // ----------------------------------------------

            $display(
                "Test Case %0d: String A: %s | String B: %s | Distance: %0d",
                i + 1,
                test_strings_a[i],
                test_strings_b[i],
                final_dist
            );
            // ----------------------------------------------
            // Reset controller for next test
            // ----------------------------------------------

            #10 start = 0;

            // Small delay between tests
            #20;
        end
        // ==================================================
        // End Simulation
        // ==================================================
        $display("---------------------------------------\n");
        $finish;
    end
endmodule

// ==========================================================
// Processing Element (PE)
// ----------------------------------------------------------
// This module represents one cell of the systolic array
// used for Levenshtein Distance computation.
//
// Functionality:
// - Compares characters from two strings
// - Computes local DP cell value
// - Propagates values through the systolic array
//
// DP Relation:
//
// dp[i][j] = min(
//                  dp[i-1][j]   + 1,   // deletion
//                  dp[i][j-1]   + 1,   // insertion
//                  dp[i-1][j-1] + cost // substitution
//               )
//
// where:
// cost = 0 if characters match
// cost = 1 otherwise
// ==========================================================

module pe #(parameter ID = 0) (

    // System clock
    input wire clk,

    // Reset signal
    input wire rst,

    // Character from String A
    input wire [7:0] char_a_in,

    // Fixed character from String B
    input wire [7:0] char_b,

    // Left DP value
    input wire [7:0] d_left,

    // Diagonal DP value
    input wire [7:0] d_diag_in,

    // Forward propagated character
    output reg [7:0] char_a_out,

    // Computed DP value output
    output reg [7:0] d_out,

    // Forward propagated diagonal value
    output reg [7:0] d_diag_out
);

    // ======================================================
    // Internal Registers and Wires
    // ======================================================

    // Stores the top DP value
    // Represents dp[i-1][j]
    reg [7:0] d_top;

    // Cost of substitution
    wire [7:0] cost;

    // Minimum computed DP value
    wire [7:0] min_val;



    // ======================================================
    // Character Comparison
    // ------------------------------------------------------
    // cost = 0 if characters match
    // cost = 1 if characters differ
    // ======================================================

    assign cost =
        (char_a_in == char_b) ? 8'd0 : 8'd1;



    // ======================================================
    // Minimum of Three Function
    // ------------------------------------------------------
    // Returns smallest among:
    // - deletion
    // - insertion
    // - substitution
    // ======================================================

    function [7:0] min3(

        input [7:0] a,
        input [7:0] b,
        input [7:0] c
    );

        begin

            if (a <= b && a <= c)
                min3 = a;

            else if (b <= a && b <= c)
                min3 = b;

            else
                min3 = c;

        end

    endfunction



    // ======================================================
    // DP Cell Computation
    // ------------------------------------------------------
    // Computes:
    //
    // min(
    //      top  + 1,
    //      left + 1,
    //      diag + cost
    // )
    // ======================================================

    assign min_val = min3(

        // Deletion
        d_top + 8'd1,

        // Insertion
        d_left + 8'd1,

        // Substitution / Match
        d_diag_in + cost
    );



    // ======================================================
    // Sequential Logic
    // ------------------------------------------------------
    // Updates PE outputs every clock cycle
    // ======================================================

    always @(posedge clk or posedge rst) begin

        // --------------------------------------------------
        // Reset State
        // --------------------------------------------------
        if (rst) begin

            // Boundary initialization:
            // dp[0][j]
            d_top <= ID + 1;

            d_out <= ID + 1;

            // dp[0][j-1]
            d_diag_out <= ID;

            // Clear propagated character
            char_a_out <= 8'd0;
        end


        // --------------------------------------------------
        // Normal Operation
        // --------------------------------------------------
        else begin

            // Update top value
            d_top <= min_val;

            // Output computed DP value
            d_out <= min_val;

            // Pass previous top value
            // as diagonal to next PE
            d_diag_out <= d_top;

            // Forward input character
            // to neighboring PE
            char_a_out <= char_a_in;
        end
    end

endmodule

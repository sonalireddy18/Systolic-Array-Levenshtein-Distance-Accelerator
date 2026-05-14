// ==========================================================
// Top Module : Edit Distance Accelerator
// ----------------------------------------------------------
//
// Functionality:
// - Accepts one input character stream from String A
// - Stores String B as a fixed parallel input
// - Instantiates a chain of Processing Elements (PEs)
// - Each PE computes one DP cell update
// - Final output gives the edit distance
//
// Architecture:
//     PE0 -> PE1 -> PE2 -> PE3
//
// Data propagated through array:
// - Character stream
// - Distance values
// - Diagonal values
// ==========================================================

module edit_distance_top #(parameter LENGTH = 4) (

    // System clock
    input wire clk,

    // Reset signal
    input wire rst,

    // Current input character from String A
    input wire [7:0] char_a_in,

    // Entire String B packed into one bus
    // Example:
    // "SITT" = 32'h53_49_54_54
    input wire [ (LENGTH*8)-1 : 0 ] string_b,

    // Initial distance value for left boundary
    input wire [7:0] d_in_initial,

    // Final computed edit distance
    output wire [7:0] final_distance
);

    // ======================================================
    // Internal Interconnect Wires
    // ------------------------------------------------------
    // These wires connect neighboring Processing Elements
    // ======================================================

    // Propagated characters from left to right
    wire [7:0] char_wire [0:LENGTH];

    // Distance values propagated horizontally
    wire [7:0] dist_wire [0:LENGTH];

    // Diagonal DP values propagated diagonally
    wire [7:0] diag_wire [0:LENGTH];


    // ======================================================
    // Initial Boundary Conditions
    // ======================================================

    // First PE receives external input character
    assign char_wire[0] = char_a_in;

    // Initial left distance value
    assign dist_wire[0] = d_in_initial;

    // Initial diagonal value
    // Example:
    // if d_in_initial = 3
    // then diagonal = 2
    assign diag_wire[0] = d_in_initial - 8'd1;


    // ======================================================
    // Generate Systolic Array of Processing Elements
    // ======================================================

    genvar i;

    generate

        // Instantiate LENGTH number of PEs
        for (i = 0; i < LENGTH; i = i + 1) begin : PE_ARRAY

            // --------------------------------------------------
            // Processing Element Instance
            // --------------------------------------------------

            pe #(.ID(i)) unit (

                .clk(clk),
                .rst(rst),

                // Input character stream from previous PE
                .char_a_in(char_wire[i]),

                // Character from String B
                //
                // Example for "SITT":
                // PE0 -> 'S'
                // PE1 -> 'I'
                // PE2 -> 'T'
                // PE3 -> 'T'
                //
                // Slicing extracts one byte per PE
                .char_b(
                    string_b[((LENGTH-i)*8)-1 :
                             (LENGTH-i-1)*8]
                ),

                // Left DP value
                .d_left(dist_wire[i]),

                // Diagonal DP value
                .d_diag_in(diag_wire[i]),

                // Forward propagated character
                .char_a_out(char_wire[i+1]),

                // Computed distance output
                .d_out(dist_wire[i+1]),

                // Forward propagated diagonal value
                .d_diag_out(diag_wire[i+1])
            );

        end

    endgenerate


    // ======================================================
    // Final Edit Distance Output
    // ------------------------------------------------------
    // Last PE produces the final distance
    // ======================================================

    assign final_distance = dist_wire[LENGTH];

endmodule

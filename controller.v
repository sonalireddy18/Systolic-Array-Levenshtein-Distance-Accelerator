// ==========================================================
// Controller Module
// ----------------------------------------------------------
// This module controls the input flow for a systolic-array
// based Levenshtein Distance accelerator.
//
// Functionality:
// - Selects one of multiple predefined test strings
// - Feeds characters sequentially into the datapath
// - Generates initialization values for DP computation
// - Controls processing states using an FSM
// - Signals completion using the `ready` signal
// ==========================================================

module controller (

    // Clock and reset
    input wire clk,
    input wire rst,

    // Start signal to begin processing
    input wire start,

    // Selects which test string to use
    input wire [2:0] test_sel,

    // Goes HIGH when processing is complete
    output reg ready,

    // Current character being streamed into datapath
    output reg [7:0] current_char_a,

    // Initial DP column value
    output reg [7:0] d_init_val,

    // Tracks current character position
    output reg [3:0] char_index
);

    // ======================================================
    // FSM State Definitions
    // ======================================================

    parameter IDLE  = 2'b00; // Waiting for start signal
    parameter RUN   = 2'b01; // Feeding input characters
    parameter FLUSH = 2'b10; // Allow systolic pipeline to flush
    parameter DONE  = 2'b11; // Computation complete

    reg [1:0] state;

    // Used during FLUSH state to wait extra cycles
    reg [3:0] cycle_count;

    // ======================================================
    // Sequential FSM Logic
    // ======================================================

    always @(posedge clk or posedge rst) begin

        // Asynchronous reset
        if (rst) begin
            state       <= IDLE;
            char_index  <= 0;
            cycle_count <= 0;
            ready       <= 0;
        end

        else begin

            case (state)

                // --------------------------------------------------
                // IDLE STATE
                // Wait for `start` signal
                // --------------------------------------------------
                IDLE: begin

                    if (start)
                        state <= RUN;

                    ready       <= 0;
                    char_index  <= 0;
                    cycle_count <= 0;
                end


                // --------------------------------------------------
                // RUN STATE
                // Feed characters one-by-one
                // --------------------------------------------------
                RUN: begin

                    // After sending 4 characters,
                    // move to FLUSH state
                    if (char_index == 3)
                        state <= FLUSH;

                    // Advance to next character
                    char_index <= char_index + 1;
                end


                // --------------------------------------------------
                // FLUSH STATE
                // Wait extra cycles so pipeline finishes computation
                // --------------------------------------------------
                FLUSH: begin

                    // Wait for 2 extra cycles
                    if (cycle_count == 2) begin

                        state <= DONE;
                        ready <= 1;

                    end

                    else begin

                        cycle_count <= cycle_count + 1;

                        // Continue incrementing index
                        // (optional depending on design)
                        char_index <= char_index + 1;
                    end
                end


                // --------------------------------------------------
                // DONE STATE
                // Hold ready HIGH until start goes LOW
                // --------------------------------------------------
                DONE: begin

                    ready <= 1;

                    // Return to IDLE after start deasserts
                    if (!start)
                        state <= IDLE;
                end

            endcase
        end
    end


    // ======================================================
    // Combinational Logic
    // Generates:
    // - current input character
    // - initial DP value
    // ======================================================

    always @(*) begin

        // Valid character indices: 0 to 3
        if (char_index < 4) begin

            // DP initialization value
            // Example:
            // char_index = 0 -> d_init_val = 1
            d_init_val = char_index + 1;

            // --------------------------------------------------
            // Select test string based on test_sel
            // --------------------------------------------------

            case(test_sel)

                // ==============================================
                // Test Case 0 : "KITT"
                // ==============================================
                3'd0:
                    case(char_index)
                        0: current_char_a = "K";
                        1: current_char_a = "I";
                        2: current_char_a = "T";
                        3: current_char_a = "T";
                        default: current_char_a = 0;
                    endcase


                // ==============================================
                // Test Case 1 : "BOOK"
                // ==============================================
                3'd1:
                    case(char_index)
                        0: current_char_a = "B";
                        1: current_char_a = "O";
                        2: current_char_a = "O";
                        3: current_char_a = "K";
                        default: current_char_a = 0;
                    endcase


                // ==============================================
                // Test Case 2 : "FAST"
                // ==============================================
                3'd2:
                    case(char_index)
                        0: current_char_a = "F";
                        1: current_char_a = "A";
                        2: current_char_a = "S";
                        3: current_char_a = "T";
                        default: current_char_a = 0;
                    endcase


                // ==============================================
                // Test Case 3 : "CHAT"
                // ==============================================
                3'd3:
                    case(char_index)
                        0: current_char_a = "C";
                        1: current_char_a = "H";
                        2: current_char_a = "A";
                        3: current_char_a = "T";
                        default: current_char_a = 0;
                    endcase


                // ==============================================
                // Test Case 4 : "COOL"
                // ==============================================
                3'd4:
                    case(char_index)
                        0: current_char_a = "C";
                        1: current_char_a = "O";
                        2: current_char_a = "O";
                        3: current_char_a = "L";
                        default: current_char_a = 0;
                    endcase


                // Default fallback
                default:
                    current_char_a = 0;

            endcase
        end

        // --------------------------------------------------
        // Invalid character index
        // --------------------------------------------------
        else begin

            current_char_a = 8'h00;

            // Special invalid marker
            d_init_val = 8'hFF;
        end
    end

endmodule

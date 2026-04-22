module controller #(
    parameter N         = 8,
    parameter M         = 8,
    parameter DATA_W    = 8,
    parameter DIST_W    = 8
)(
    input  wire                 clk,
    input  wire                 rst_n,
    input  wire                 start,
    input  wire [DATA_W*M-1:0]  string_a,
    input  wire [DATA_W*N-1:0]  string_b,
    output reg                  ready,
    output reg                  done,
    output reg  [DIST_W-1:0]    edit_distance_out,
    output wire [DATA_W-1:0]    col_char_a,
    output reg  [DATA_W*N-1:0]  string_b_out,
    output reg                  col_valid,
    input  wire [DIST_W-1:0]    result_in,
    input  wire                 result_valid
);
    // State definitions for the finite state machine.
    // These manage the sequence from initial idle to data feeding and result capture.
    localparam S_IDLE = 2'b00,
               S_FEED = 2'b01,
               S_WAIT = 2'b10,
               S_DONE = 2'b11;

    reg [1:0]               state;
    reg [$clog2(M+1)-1:0]   feed_cnt;
    reg [DATA_W*M-1:0]      shift_reg_a;

    // Continuously assign the lowest byte of the shift register to the output.
    // This allows the PE array to see the current character without complex multiplexing.
    assign col_char_a = shift_reg_a[DATA_W-1:0];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Initialize all registers to zero or safe default states upon reset.
            // This prevents garbage values from entering the pipeline on startup.
            state             <= S_IDLE;
            feed_cnt          <= 0;
            shift_reg_a       <= 0;
            string_b_out      <= 0;
            ready             <= 1'b0;
            done              <= 1'b0;
            col_valid         <= 1'b0;
            edit_distance_out <= 0;
        end else begin
            case (state)
                S_IDLE: begin
                    // Signal to the external system that the controller is ready for a new task.
                    // If start is asserted, we latch the input strings into local registers.
                    ready <= 1'b1;
                    done  <= 1'b0;
                    if (start) begin
                        shift_reg_a  <= string_a;
                        string_b_out <= string_b;
                        feed_cnt     <= 0;
                        ready        <= 1'b0;
                        state        <= S_FEED;
                    end
                end

                S_FEED: begin
                    // Assert col_valid to tell the PE array that the current character is valid.
                    // We transition to S_WAIT on the final character cycle (M-1).
                    col_valid <= 1'b1;
                    if (feed_cnt == M - 1) begin
                        state     <= S_WAIT;
                        feed_cnt  <= 0;
                    end else begin
                        // Increment the character counter and shift the next byte into position.
                        // Shifting right moves the next character to the [DATA_W-1:0] slice.
                        feed_cnt    <= feed_cnt + 1'b1;
                        shift_reg_a <= shift_reg_a >> DATA_W;
                    end
                end

                S_WAIT: begin
                    // De-assert col_valid as all characters from string A have been presented.
                    // The FSM now waits for the pipeline to drain and signal a valid result.
                    col_valid <= 1'b0;
                    if (result_valid) begin
                        edit_distance_out <= result_in;
                        state             <= S_DONE;
                    end
                end

                S_DONE: begin
                    // Assert the done signal for one clock cycle to notify the user.
                    // The FSM then returns to IDLE to wait for the next comparison request.
                    done  <= 1'b1;
                    state <= S_IDLE;
                end

                default: state <= S_IDLE;
            endcase
        end
    end
endmodule

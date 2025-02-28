// Fade; calculates pwm signals and timing basically

// simple PWM up and down every 200s
// idea: can have third state of not changing
// 1 second / 6 --> 40 ish ms; 66 ms

// start with parameter of where in cycle + timer
// can do a separate case with high and low bundled together (so don't mess with current timer)
   // count 

module fade #(
    parameter INC_DEC_INTERVAL = 12000,     // CLK frequency is 12MHz, so 12,000 cycles is 1ms
    // Transition to next state after 200 increments / decrements, which is 0.2s; pwm value updated 200 times before changing from incr to decr
    // full cycle takes 400 ms 
    parameter INC_DEC_MAX = 200,            
    parameter PWM_INTERVAL = 1200,          // CLK frequency is 12MHz, so 1,200 cycles is 100us
    parameter INC_DEC_VAL = PWM_INTERVAL / INC_DEC_MAX // increment value; by a small step each update 
)(
    input logic clk, 
    output logic [$clog2(PWM_INTERVAL) - 1:0] pwm_value 
);

    // Define state variable values
    localparam PWM_INC = 1'b0;
    localparam PWM_DEC = 1'b1;

    // Declare state variables
    logic current_state = PWM_INC; // current state of FSM; either PWM_INC or PWM_DEC
    logic next_state;

    // Declare variables for timing state transitions
    logic [$clog2(INC_DEC_INTERVAL) - 1:0] count = 0;
    logic [$clog2(INC_DEC_MAX) - 1:0] inc_dec_count = 0;
    logic time_to_inc_dec = 1'b0;
    logic time_to_transition = 1'b0;

    initial begin
        pwm_value = 0;
    end

    // Register the next state of the FSM
    always_ff @(posedge time_to_transition) // transitions between PWM_INC and PWM_DEC
        // LEAVE AS IS
        current_state <= next_state;

    // Compute the next state of the FSM
    always_comb begin
        next_state = 1'bx;
        case (current_state)
            PWM_INC:
                next_state = PWM_DEC;
            PWM_DEC:
                next_state = PWM_INC;
        endcase
    end

    // Implement counter for incrementing / decrementing PWM value
    always_ff @(posedge clk) begin
        if (count == INC_DEC_INTERVAL - 1) begin
            count <= 0;
            time_to_inc_dec <= 1'b1;
        end
        else begin
            count <= count + 1;
            time_to_inc_dec <= 1'b0;
        end
    end

    // Increment / Decrement PWM value as appropriate given current state
    always_ff @(posedge time_to_inc_dec) begin
        // when time_to_inc_dec high, PWM value increases; when low, decreases

        // add two states here: high and low; OR add a separate high level one
        case (current_state)
            PWM_INC:
                pwm_value <= pwm_value + INC_DEC_VAL;
            PWM_DEC:
                pwm_value <= pwm_value - INC_DEC_VAL;
        endcase
    end

    // Implement counter for timing state transitions; handling transition timing
    always_ff @(posedge time_to_inc_dec) begin
        if (inc_dec_count == INC_DEC_MAX - 1) begin
            inc_dec_count <= 0;
            time_to_transition <= 1'b1;
        end
        else begin
            inc_dec_count <= inc_dec_count + 1;
            time_to_transition <= 1'b0;
        end
    end

endmodule
